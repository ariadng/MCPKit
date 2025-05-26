//
//  MCPClient.swift
//  MCPKit
//
//  Created by Cascade on 2025-05-26.
//

import Foundation
import Combine
import MCPSchema
import MCPTransport

/// MCPClient is an actor responsible for managing communication with an MCP server.
/// It handles JSON-RPC 2.0 session management, request sending, and response/notification processing.
public actor MCPClient {
    // MARK: - Nested ConnectionState Enum

    /// Represents the connection state of the MCPClient.
    public enum ConnectionState: Equatable, @unchecked Sendable {
        case disconnected(error: Error? = nil)
        case connecting
        case connected
        case disconnecting
        case reconnecting(attempt: Int, nextAttemptIn: TimeInterval)

        public static func == (lhs: MCPClient.ConnectionState, rhs: MCPClient.ConnectionState) -> Bool {
            switch (lhs, rhs) {
            case (.disconnected(let lError), .disconnected(let rError)):
                // Consider errors equal if both are nil or both are non-nil (basic check)
                // For more precise equality, one might compare error domains and codes.
                return (lError == nil && rError == nil) || (lError != nil && rError != nil)
            case (.connecting, .connecting):
                return true
            case (.connected, .connected):
                return true
            case (.disconnecting, .disconnecting):
                return true
            case (.reconnecting(let lAttempt, let lTime), .reconnecting(let rAttempt, let rTime)):
                return lAttempt == rAttempt && lTime == rTime // Or close enough for TimeInterval
            default:
                return false
            }
        }
    }

    // MARK: - Properties

    /// The current connection state of the client.
    public var connectionState: ConnectionState = .disconnected(error: nil) {
        didSet {
            // Log state change
            print("MCPClient: Connection state changed from \(oldValue) to \(connectionState)")
            Task { // Ensure it runs on the actor's executor
                await self.connectionStateDidChange(from: oldValue, to: connectionState)
            }
            // Notify observers if any (e.g., via a stream)
            // connectionStateStreamContinuation?.yield(connectionState)
        }
    }

    /// The transport mechanism used for sending and receiving data.
    private let transport: MCPTransport

    /// Configuration for the transport, dictating which transport is used and its parameters.
    public let transportConfiguration: MCPTransportConfiguration

    /// Optional interval for sending heartbeat pings.
    private let heartbeatInterval: TimeInterval?

    /// Configuration for automatic reconnection.
    private let enableAutoReconnect: Bool
    private let maxReconnectAttempts: Int
    private let baseReconnectDelay: TimeInterval
    private let maxReconnectDelay: TimeInterval
    private let reconnectDelayJitterFactor: Double

    /// Capabilities of this client, to be sent during initialization.
    private let clientCapabilities: ClientCapabilities

    /// Information about this client implementation.
    private let clientInfo: Implementation

    /// The MCP protocol version this client supports.
    private let protocolVersion: String

    /// Capabilities reported by the server after successful initialization.
    public private(set) var serverCapabilities: ServerCapabilities? = nil

    /// Stores pending requests awaiting a response from the server.
    /// Keyed by request ID.
    private var pendingRequests: [String: PendingRequest] = [:]

    /// Counter for generating unique request IDs.
    private var requestIDCounter: Int = 0

    /// JSON encoder for serializing requests.
    private let jsonEncoder = JSONEncoder()

    /// JSON decoder for deserializing responses and notifications.
    private let jsonDecoder = JSONDecoder()

    /// Task responsible for processing incoming messages from the transport layer.
    private var messageProcessingTask: Task<Void, Error>?

    /// Task responsible for observing the transport's connection state changes.
    private var transportStateObservationTask: Task<Void, Never>?

    /// Task responsible for sending periodic heartbeats.
    private var heartbeatTask: Task<Void, Never>?

    /// Task responsible for automatic reconnection attempts.
    private var reconnectionTask: Task<Void, Never>?
    private var currentReconnectAttempt: Int = 0

    /// Flag to indicate if an MCP handshake is currently in progress.
    private var handshakeInProgress: Bool = false

    // MARK: - Public Callbacks for Server-Initiated Messages

    /// Called when the server sends a 'logging/message' notification.
    public var onLoggingMessage: ((LoggingMessageNotification.Params) -> Void)?

    /// Called when the server sends a 'resources/updated' notification.
    public var onResourceUpdate: ((ResourceUpdatedNotification.Params) -> Void)?

    /// Called when the server sends a 'sampling/createMessage' request. 
    /// The handler should return a `CreateMessageResult` or throw an error.
    public var onSamplingCreateMessage: ((CreateMessageRequest.Params) async throws -> CreateMessageResult)?

    // MARK: - Internal Structures

    /// Represents a pending request, holding its continuation and expected response type.
    private struct PendingRequest {
        let continuation: CheckedContinuation<Any, Error>
        let responseType: Decodable.Type
    }

    private struct JSONRPCMessageBase: Decodable {
        let id: RequestId?
        let method: String?
        let result: AnyCodable?
        let error: MCPSchema.JSONRPCError.ErrorObject? // Ensure this exact type
    }

    // MARK: - Structures for Ping
    private struct NoParams: Encodable {}
    private struct NoResult: Decodable {}

    // MARK: - Initialization and Lifecycle

    /// Initializes a new MCPClient with a specific transport configuration and client capabilities.
    /// - Parameter transportConfiguration: The configuration specifying the transport to use.
    /// - Parameter clientCapabilities: The capabilities of this client.
    /// - Parameter clientInfo: Information about this client implementation.
    /// - Parameter protocolVersion: The MCP protocol version this client supports.
    /// - Parameter heartbeatInterval: Optional interval in seconds for sending heartbeat pings. Defaults to nil (disabled).
    /// - Parameter enableAutoReconnect: Whether to enable automatic reconnection. Defaults to true.
    /// - Parameter maxReconnectAttempts: Maximum number of reconnection attempts. Defaults to 5.
    /// - Parameter baseReconnectDelay: Base delay in seconds for reconnection attempts. Defaults to 1.0.
    /// - Parameter maxReconnectDelay: Maximum delay in seconds for reconnection attempts. Defaults to 30.0.
    /// - Parameter reconnectDelayJitterFactor: Factor for introducing jitter in reconnection delays. Defaults to 0.25.
    /// - Throws: An error if the transport cannot be initialized (though current transport inits don't throw).
    public init(transportConfiguration: MCPTransportConfiguration, 
                clientCapabilities: ClientCapabilities, 
                clientInfo: Implementation, 
                protocolVersion: String, 
                heartbeatInterval: TimeInterval? = nil,
                enableAutoReconnect: Bool = true,
                maxReconnectAttempts: Int = 5,
                baseReconnectDelay: TimeInterval = 1.0,
                maxReconnectDelay: TimeInterval = 30.0,
                reconnectDelayJitterFactor: Double = 0.25
    ) throws {
        self.transportConfiguration = transportConfiguration
        self.clientCapabilities = clientCapabilities
        self.clientInfo = clientInfo
        self.protocolVersion = protocolVersion
        self.heartbeatInterval = heartbeatInterval
        self.enableAutoReconnect = enableAutoReconnect
        self.maxReconnectAttempts = maxReconnectAttempts
        self.baseReconnectDelay = baseReconnectDelay
        self.maxReconnectDelay = maxReconnectDelay
        self.reconnectDelayJitterFactor = reconnectDelayJitterFactor

        switch transportConfiguration {
        #if os(macOS)
        case .stdio(let commandPath, let arguments):
            self.transport = StdioTransport(commandPath: commandPath, arguments: arguments)
        #endif
        case .sse(let url, let maxRetryAttempts, let baseRetryDelay):
            self.transport = SSETransport(serverURL: url, maxRetryAttempts: maxRetryAttempts, baseRetryDelay: baseRetryDelay)
        case .streamableHTTP(let url, let httpMethod):
            self.transport = StreamableHTTPTransport(serverURL: url, httpMethod: httpMethod)
        // If stdio is the only case and it's not macOS, this might lead to a compile error
        // Ensure all cases are handled or provide a default/error for non-macOS stdio if it were possible.
        // Current MCPTransportConfiguration is #if os(macOS) for stdio, so this structure is fine.
        }
    }

    deinit {
        // Ensure tasks are cancelled on deinitialization, though explicit disconnect is preferred.
        messageProcessingTask?.cancel()
        transportStateObservationTask?.cancel()
        heartbeatTask?.cancel()
        reconnectionTask?.cancel()
        // If transport has a synchronous disconnect, call it here.
        // Otherwise, an explicit async disconnect method is better.
    }

    /// Establishes a connection to the server using the configured transport and performs MCP handshake.
    /// This includes establishing the transport connection and performing the MCP handshake.
    /// If called manually, it will cancel any ongoing automatic reconnection attempts.
    /// - Parameter isRetryAttempt: Internal flag to indicate if this call is part of an automatic retry. Defaults to `false`.
    /// - Throws: `MCPClientError` if the client is already connected/connecting or if the connection/handshake fails.
    public func connect(isRetryAttempt: Bool = false) async throws {
        if !isRetryAttempt {
            print("MCPClient: Manual connect() called. Cancelling any ongoing reconnection attempts.")
            await self.cancelReconnectionAttempt()
        }

        // 1. Check Current State and Transition to .connecting
        // Allow connect if disconnected or if it's a retry originating from a reconnecting state.
        switch connectionState {
            case .connected, .connecting, .disconnecting:
                // If it's a retry, this state means something went wrong with the retry loop's state management
                // or an external state change occurred. For a manual call, it's a clear error.
                print("MCPClient: connect(isRetryAttempt: \(isRetryAttempt)) called but client is in state \(connectionState).")
                throw MCPClientError.alreadyConnected // Or a more specific error like .invalidStateForOperation
            case .disconnected, .reconnecting: // .reconnecting is a valid prior state for a retry attempt
                print("MCPClient: connect(isRetryAttempt: \(isRetryAttempt)) - Current state \(connectionState). Transitioning to .connecting.")
                self.connectionState = .connecting
        }

        // Reset handshake in progress flag
        self.handshakeInProgress = false // Reset handshake flag

        // 2. Transition to Connecting
        // self.connectionState = .connecting
        // self.handshakeInProgress = false // Reset handshake flag

        // Cancel any previous observation task before starting a new one
        transportStateObservationTask?.cancel()
        transportStateObservationTask = Task {
            print("MCPClient: Starting transport state observation task.")
            for await transportState in self.transport.stateStream {
                print("MCPClient: Received transport state: \(transportState)")
                await handleTransportStateChange(transportState)
            }
            print("MCPClient: Transport state observation task finished (stream closed).")
            // If the stream closes and we are not already disconnected, transition to disconnected.
            if self.connectionState != .disconnected(error: nil) && !isDisconnectedWithError() {
                print("MCPClient: Transport stream closed, ensuring client is disconnected.")
                let disconnectError = MCPClientError.transportError(NSError(domain: "MCPClient", code: -1, userInfo: [NSLocalizedDescriptionKey: "Transport stream closed unexpectedly"]))
                self.connectionState = .disconnected(error: disconnectError)
                await self.cleanupConnectionTasksAndState(isGraceful: false, error: disconnectError)
            }
        }

        // Start listening to incoming messages from the transport.
        startListeningToTransportInternal()

        do {
            // 3. Connect Transport
            print("MCPClient: Attempting transport.connect()...")
            try await transport.connect()
            // transport.connect() returning doesn't guarantee transport.stateStream has emitted .connected.
            // We rely on the transportStateObservationTask to see the .connected from the stream
            // and then trigger the handshake from handleTransportStateChange.
            // However, if transport.connect() succeeds, we can assume it *intends* to be connected.
            // The actual handshake will only proceed once stateStream confirms .connected.
            print("MCPClient: transport.connect() succeeded. Waiting for transport stateStream to confirm .connected for handshake.")

        } catch {
            print("MCPClient: transport.connect() failed. Error: \(error)")
            self.connectionState = .disconnected(error: error)
            await cleanupConnectionTasksAndState(isGraceful: false, error: error)
            throw error // Rethrow the original transport connection error
        }
    }

    private func handleTransportStateChange(_ transportState: TransportConnectionState) async {
        switch transportState {
        case .connecting:
            // MCPClient initiates its own .connecting state.
            // This is the transport confirming it's also in a connecting phase.
            if self.connectionState != .connecting && self.connectionState != .connected {
                 self.connectionState = .connecting
            }
        case .connected:
            // Transport is connected. If client is in 'connecting' state, proceed with handshake.
            if self.connectionState == .connecting && !self.handshakeInProgress {
                print("MCPClient: Transport connected. Proceeding with MCP handshake.")
                self.handshakeInProgress = true
                Task {
                    do {
                        // 4. Perform MCP Handshake
                        print("MCPClient: Performing initialize handshake...")
                        let initializeResult = try await self.initialize()
                        self.serverCapabilities = initializeResult.capabilities
                        self.handshakeInProgress = false
                        // 5. Transition to Connected (MCP Level)
                        self.connectionState = .connected
                        print("MCPClient: Handshake successful. MCPClient is now connected.")
                        await self.startHeartbeatIfNeeded()
                    } catch {
                        print("MCPClient: MCP Handshake (initialize) failed. Error: \(error)")
                        self.handshakeInProgress = false
                        let handshakeError = MCPClientError.handshakeFailed(underlyingError: error)
                        // Store the error before calling disconnect, as disconnect might clear it if not passed.
                        self.connectionState = .disconnecting // Intermediate state
                        await self.disconnect(triggeredByError: handshakeError) // Disconnect transport and cleanup
                        // disconnect() will set final .disconnected state with the error.
                    }
                }
            } else if self.connectionState == .connected {
                // Already connected, transport might be reconfirming or recovering.
                print("MCPClient: Transport reported connected, client already in .connected state.")
            } else {
                print("MCPClient: Transport reported connected, but client in unexpected state: \(self.connectionState). Ignoring.")
            }

        case .disconnected(let transportError):
            print("MCPClient: Transport reported disconnected via stateStream, error: \(String(describing: transportError)).")
            let effectiveError = transportError ?? MCPClientError.transportError(NSError(domain: "MCPClient", code: -2, userInfo: [NSLocalizedDescriptionKey: "Transport disconnected without specific error."])) 

            if self.connectionState == .disconnecting {
                print("MCPClient: Transport disconnected, client already in .disconnecting state. Allowing disconnect() to finalize.")
                // disconnect() will handle setting the final .disconnected state.
                return
            }
            
            if self.connectionState == .connected || self.connectionState == .connecting {
                print("MCPClient: Client was \(self.connectionState), now disconnected by transport.")
                await self.stopHeartbeat() // Stop heartbeat as connection is lost
                self.connectionState = .disconnected(error: effectiveError)
                if self.handshakeInProgress {
                    print("MCPClient: Handshake was in progress, now cancelled due to transport disconnection.")
                    self.handshakeInProgress = false // Cancel handshake
                }
                // Perform cleanup similar to disconnect, but initiated by transport failure.
                await self.cleanupConnectionTasksAndState(isGraceful: false, error: effectiveError)
            } else if case .disconnected = self.connectionState {
                print("MCPClient: Transport disconnected, client already in .disconnected state.")
            } else {
                print("MCPClient: Transport disconnected, client in unexpected state: \(self.connectionState). Setting to disconnected.")
                self.connectionState = .disconnected(error: effectiveError)
                await self.cleanupConnectionTasksAndState(isGraceful: false, error: effectiveError)
            }
        }
    }

    /// Disconnects from the server and cleans up resources.
    /// - Parameter triggeredByError: Optional error that triggered this disconnection. If nil, it's a normal disconnect.
    public func disconnect(triggeredByError: Error? = nil) async {
        print("MCPClient: disconnect(triggeredByError: \(String(describing: triggeredByError))) called. Current state: \(connectionState)")
        // 1. Check Current State
        // Allow calling disconnect even if already disconnecting to ensure cleanup, or if an error occurs during connecting.
        if connectionState == .disconnected(error: nil) && triggeredByError == nil {
            if !isDisconnectedWithError() { // Only return if truly cleanly disconnected and no new error
                print("MCPClient: Already disconnected cleanly. Nothing to do.")
                return
            }
        }
        // If already disconnecting for the same reason, don't recurse or overlap.
        if connectionState == .disconnecting && triggeredByError == nil { // TODO: better check for same error
             print("MCPClient: Already disconnecting. Ignoring redundant call.")
             // return // Be careful here, might need to allow completion
        }

        // 2. Set State to Disconnecting
        // Preserve existing error if disconnect is called while already disconnected with error
        let previousError: Error? = isDisconnectedWithError() ? connectionStateError() : nil
        self.connectionState = .disconnecting

        // Perform cleanup actions
        await cleanupConnectionTasksAndState(isGraceful: triggeredByError == nil, error: triggeredByError ?? previousError)
        
        print("MCPClient: disconnect() finished. Final state: \(connectionState)")
    }

    /// Helper to check if current state is .disconnected with any error.
    private func isDisconnectedWithError() -> Bool {
        if case .disconnected(let error) = connectionState, error != nil {
            return true
        }
        return false
    }

    /// Helper to get error from .disconnected state.
    private func connectionStateError() -> Error? {
        if case .disconnected(let error) = connectionState {
            return error
        }
        return nil
    }

    /// Centralized cleanup of tasks and state.
    private func cleanupConnectionTasksAndState(isGraceful: Bool, error: Error?) async {
        print("MCPClient: cleanupConnectionTasksAndState(isGraceful: \(isGraceful), error: \(String(describing: error)))")

        await stopHeartbeat()
        await cancelReconnectionAttempt() // Ensure any reconnection attempt is also cancelled

        // 3. Disconnect Transport (if not already disconnected by transport itself)
        // Check transport's own state if possible, or rely on MCPClient's view
        // For now, call transport.disconnect() idempotently or if we think it's needed.
        // If an error triggered this, transport might already be down.
        if connectionState != .disconnected(error: nil) || isDisconnectedWithError() { // Avoid disconnecting transport if we are already cleanly disconnected by client's choice
            // Only call transport.disconnect if we are not already being told by transport it's down
            // This check is tricky. For now, let transport.disconnect() be idempotent.
            print("MCPClient: Calling transport.disconnect() during cleanup.")
            await self.transport.disconnect() // Transport's disconnect should be idempotent
        }

        // 4. Cancel Tasks
        print("MCPClient: Cancelling tasks (transportStateObservationTask, messageProcessingTask).")
        transportStateObservationTask?.cancel()
        transportStateObservationTask = nil
        messageProcessingTask?.cancel()
        messageProcessingTask = nil // Assuming messageProcessingTask is also a property

        // 5. Clear Sensitive/Session-Specific State
        print("MCPClient: Clearing serverCapabilities and pending requests.")
        self.serverCapabilities = nil
        self.handshakeInProgress = false

        // 6. Clear Pending Requests (Fail them - Details in Step 4.5)
        // For now, just clear them. Actual failing logic will be more complex.
        let requestsToFail = pendingRequests
        pendingRequests.removeAll()
        for (_, pending) in requestsToFail {
            pending.continuation.resume(throwing: MCPClientError.operationCancelled) // Or a more specific error
        }

        // 7. Set Final State to Disconnected
        if let err = error {
            // If an error was passed (e.g., from handshake failure or transport notification)
            // or if disconnect was called with an error.
            if !(self.connectionState == .disconnected(error: err)) { // Avoid redundant didSet if already set
                 self.connectionState = .disconnected(error: err)
            }
        } else {
            // Normal disconnect or cleanup after non-error based disconnection
            if !(self.connectionState == .disconnected(error: nil)) { // Avoid redundant didSet
                 self.connectionState = .disconnected(error: nil)
            }
        }
        print("MCPClient: Cleanup complete. Final state: \(connectionState)")
    }

    // MARK: - API Layer (Public Methods)

    /// Initializes the JSON-RPC session with the server.
    /// The client sends its capabilities (provided at MCPClient initialization),
    /// and the server responds with its own.
    /// - Returns: The capabilities of the server.
    public func initialize() async throws -> InitializeResult {
        let params = InitializeRequest.Params(
            protocolVersion: self.protocolVersion,
            capabilities: self.clientCapabilities,
            clientInfo: self.clientInfo
        )
        // The `sendRequest` method handles JSON-RPC wrapping, ID generation, sending, and response matching.
        // It's expected to return the decoded result of the type specified (ServerCapabilities in this case).
        let serverCaps: InitializeResult = try await self.sendRequest(method: "session/initialize", params: params)
        return serverCaps
    }

    // MARK: - Request Handling

    /// Generates the next unique request ID.
    private func nextRequestID() -> String {
        requestIDCounter += 1
        return String(requestIDCounter)
    }

    /// Sends a request to the server and awaits its response.
    /// - Parameters:
    ///   - method: The JSON-RPC method name.
    ///   - params: The parameters for the request, conforming to Encodable.
    /// - Returns: The decoded result of the request.
    /// - Throws: An error if sending or decoding fails, or if the server returns an error.
    private func sendRequest<ParamsType: Encodable, ResultType: Decodable>(
        method: String,
        params: ParamsType,
        customID: String? = nil
    ) async throws -> ResultType {
        let requestIDString = customID ?? nextRequestID()
        let mcpRequestID = RequestId.string(requestIDString)

        let rpcRequest = JSONRPCRequest(id: mcpRequestID, method: method, params: AnyCodable(params)) // Corrected argument order

        let encodedRequest: Data
        do {
            encodedRequest = try self.jsonEncoder.encode(rpcRequest)
        } catch {
            // This error occurs if encoding the request itself fails.
            throw MCPClientError.requestEncodingFailed(error)
        }

        // Create a continuation for this request.
        return try await withCheckedThrowingContinuation { continuation in
            let pendingRequest = PendingRequest(continuation: continuation as! CheckedContinuation<Any, Error>, responseType: ResultType.self)
            self.pendingRequests[requestIDString] = pendingRequest

            Task {
                do {
                    // Ensure client is connected before sending. Transport is non-optional.
                    guard self.connectionState == .connected else {
                        if self.pendingRequests.removeValue(forKey: requestIDString) != nil {
                            continuation.resume(throwing: MCPClientError.notConnected)
                        }
                        return
                    }
                    try await self.transport.send(encodedRequest)
                } catch {
                    // Transport failed to send. Remove pending request and resume continuation with error.
                    if self.pendingRequests.removeValue(forKey: requestIDString) != nil {
                        continuation.resume(throwing: error)
                    }
                }
            }
        }
    }

    // MARK: - Message Dispatch/Session Layer

    /// Starts a task to listen for and process incoming messages from the transport.
    private func startListeningToTransportInternal() {
        // Transport is non-optional, so no need to guard for its existence here.
        // Ensure any existing task is cancelled before starting a new one.
        messageProcessingTask?.cancel()

        messageProcessingTask = Task {
            print("MCPClient: Message processing task started. Awaiting messages from transport...")
            do {
                for try await data in transport.incomingMessages {
                    if Task.isCancelled { break }
                    // print("MCPClient RECV: \(String(data: data, encoding: .utf8) ?? "")")
                    await self.handleIncomingData(data) // Actor re-entrancy ensures sequential processing
                }
                // This ensures the catch block is reachable if the loop exits without an error
                try Task.checkCancellation()
            } catch {
                if Task.isCancelled {
                    print("MCPClient: Message processing task cancelled normally.")
                } else {
                    print("MCPClient: Message processing task ended with error - \(error)")
                    // Handle transport errors, e.g., by attempting to reconnect or transitioning to a disconnected state.
                    await self.disconnect(triggeredByError: error) // Pass the specific error
                }
            }
            print("MCPClient: Message processing task finished.")
        }
    }

    /// Stops the task that listens for incoming messages.
    private func stopListeningToTransportInternal() {
        print("MCPClient: Stopping message processing task.")
        messageProcessingTask?.cancel()
        messageProcessingTask = nil

        print("MCPClient: Stopping transport state observation task.")
        transportStateObservationTask?.cancel()
        transportStateObservationTask = nil
    }

    /// Handles raw incoming data from the transport, decoding it as a JSON-RPC message.
    private func handleIncomingData(_ data: Data) async {
        // Attempt to decode the base message to determine its type
        let baseMessage: JSONRPCMessageBase
        do {
            baseMessage = try self.jsonDecoder.decode(JSONRPCMessageBase.self, from: data)
        } catch {
            print("MCPClient Error: Failed to decode base message: \(error). Data: \(String(data: data, encoding: .utf8) ?? "Invalid UTF8")")
            // Consider how to handle undecipherable messages. For now, just log and ignore.
            return
        }

        // 1. Check for Response (id is present, and result or error is present)
        if let id = baseMessage.id, (baseMessage.result != nil || baseMessage.error != nil) {
            // This is a Response to a client-initiated request
            guard let pending = self.pendingRequests.removeValue(forKey: id.asString) else {
                print("MCPClient Error: Received response for unknown request ID: \(id.asString). Discarding. Data: \(String(data: data, encoding: .utf8) ?? "Non-UTF8 data")")
                // Log MCPClientError.unknownRequestID(id.asString) if you have a logging mechanism
                return
            }

            if let errorObject = baseMessage.error {
                // Server returned an error
                print("MCPClient: Received error response for ID \(id.asString): \(errorObject.code) - \(errorObject.message)")
                let mcpError = MCPClientError.jsonRpcError(errorObject)
                pending.continuation.resume(throwing: mcpError)
            } else if let resultObject = baseMessage.result {
                // Server returned a successful result
                do {
                    // The resultObject is AnyCodable. We need to decode it into the specific PendingRequest.responseType.
                    let resultData = try self.jsonEncoder.encode(resultObject) // Re-encode AnyCodable to Data
                    let typedResult = try self.jsonDecoder.decode(pending.responseType, from: resultData) // Decode to expected type
                    // print("MCPClient: Successfully decoded result for ID \(id.asString) to type \(pending.responseType)")
                    pending.continuation.resume(returning: typedResult)
                } catch {
                    print("MCPClient Error: Failed to decode result for request ID \(id.asString) into type \(pending.responseType). Error: \(error). Result data: \(String(describing: baseMessage.result))")
                    let mcpError = MCPClientError.typeCastingFailed(expectedType: String(describing: pending.responseType), actualValueDescription: "AnyCodable result") // Corrected error case and parameters
                    pending.continuation.resume(throwing: mcpError)
                }
            } else {
                // Should not happen if id is present and it's a response (violates JSON-RPC spec if neither result nor error)
                print("MCPClient Error: Received response for ID \(id.asString) with no result or error. Data: \(String(data: data, encoding: .utf8) ?? "Non-UTF8 data")")
                let mcpError = MCPClientError.unexpectedMessageFormat // Corrected error case
                pending.continuation.resume(throwing: mcpError)
            }

        // 2. Check for Notification (method is present, id is ABSENT)
        } else if let methodName = baseMessage.method, baseMessage.id == nil {
            // This is a Server-to-Client Notification
            // print("MCPClient: Received notification for method \(methodName)")
            do {
                // Decode the full notification including params
                let notification = try self.jsonDecoder.decode(MCPSchema.JSONRPCNotification.self, from: data)
                await self.dispatchNotification(notification)
            } catch {
                print("MCPClient Error: Failed to decode notification for method \(methodName). Error: \(error). Data: \(String(data: data, encoding: .utf8) ?? "Invalid UTF8")")
                // Log MCPClientError.decodingError or .invalidMessageFormat
            }

        // 3. Check for Server-Initiated Request (method is present, id is present, AND no result/error)
        } else if let methodName = baseMessage.method, let requestID = baseMessage.id, baseMessage.result == nil && baseMessage.error == nil {
            // This is a Server-Initiated Request to the Client
            // print("MCPClient: Received server-initiated request (ID: \(requestID.asString), Method: \(methodName))")
            do {
                let serverRequest = try self.jsonDecoder.decode(MCPSchema.JSONRPCRequest.self, from: data)
                await self.dispatchServerRequest(serverRequest)
            } catch {
                print("MCPClient Error: Failed to decode server-initiated request (ID: \(requestID.asString), Method: \(methodName)). Error: \(error). Data: \(String(data: data, encoding: .utf8) ?? "Non-UTF8 data")")
                // Optionally, try to send a parse error response if requestID was parsable
                // let errorResponse = JSONRPCResponse(id: requestID, error: JSONRPCErrorObject.parseError(message: "Failed to parse server request: \(error.localizedDescription)"))
                // try? await self.sendRawResponse(errorResponse)
            }
        } else {
            // Invalid or unknown message structure
            print("MCPClient Error: Received message with unknown structure. Not a valid Response, Notification, or Server Request. Data: \(String(data: data, encoding: .utf8) ?? "Non-UTF8 data")")
            // Log MCPClientError.invalidMessageFormat
        }
    }

    // MARK: - Notification and Server Request Dispatchers

    private func dispatchNotification(_ notification: MCPSchema.JSONRPCNotification) async {
        // Example: Dispatch based on method name
        // You would typically have a dictionary of handlers or a switch statement here.
        // For now, just logging.
        switch notification.method {
        case "logging/message":
            do {
                let params = try decodeParams(notification.params, as: LoggingMessageNotification.Params.self)
                await self.handleLoggingMessageNotification(params: params)
            } catch {
                print("MCPClient Error: Failed to decode params for 'logging/message' notification. Error: \(error)")
            }
        case "resources/updated":
            do {
                let params = try decodeParams(notification.params, as: ResourceUpdatedNotification.Params.self)
                await self.handleResourceUpdateNotification(params: params)
            } catch {
                print("MCPClient Error: Failed to decode params for 'resources/updated' notification. Error: \(error)")
            }
        // Add more cases for other notifications
        default:
            print("MCPClient Warning: Received unhandled notification method: \(notification.method)")
        }
    }

    private func dispatchServerRequest(_ request: MCPSchema.JSONRPCRequest) async {
        // print("MCPClient: Dispatching server request: \(request.method), ID: \(request.id.asString)")
        switch request.method {
        case Constants.MCPMethods.Sampling.createMessage: // Ensure MCPMethods.Sampling.createMessage is defined
            guard let actualParams = request.params else {
                print("MCPClient Error: Missing params for '\(request.method)' request. ID: \(request.id.asString).")
                let errorDetail = MCPSchema.JSONRPCError.ErrorObject(code: -32602, message: "Missing params for method '\(request.method)'")
                let mcpError = MCPSchema.JSONRPCError(id: request.id, error: errorDetail)
                await self.sendRawError(mcpError) // Changed to sendRawError
                return
            }
            await self.handleSamplingCreateMessageRequest(id: request.id, params: actualParams)

        // Add more cases for other server-initiated requests
        default:
            print("MCPClient Warning: Received server-initiated request for unknown method: \(request.method). ID: \(request.id.asString)")
            let errorDetail = MCPSchema.JSONRPCError.ErrorObject(code: -32601, message: "Method not found: \(request.method)")
            let mcpError = MCPSchema.JSONRPCError(id: request.id, error: errorDetail)
            await self.sendRawError(mcpError) // Changed to sendRawError
        }
    }

    /// Specific handler for 'sampling/createMessage' server-initiated request.
    private func handleSamplingCreateMessageRequest(id: RequestId, params: AnyCodable) async {
        guard let appHandler = self.onSamplingCreateMessage else {
            print("MCPClient: '\(Constants.MCPMethods.Sampling.createMessage)' request received, but no onSamplingCreateMessage handler is set.")
            let errorDetail = MCPSchema.JSONRPCError.ErrorObject(code: -32601, message: "Method not found (handler not configured on client): \(Constants.MCPMethods.Sampling.createMessage)")
            let mcpError = MCPSchema.JSONRPCError(id: id, error: errorDetail)
            await self.sendRawError(mcpError) // Changed to sendRawError
            return
        }

        do {
            // Decode params from AnyCodable to the specific type expected by the handler
            let typedParams: CreateMessageRequest.Params = try decodeParams(params, as: CreateMessageRequest.Params.self)
            // Assuming the handler returns a result that can be encoded into AnyCodable for the response.
            let actualResult = try await appHandler(typedParams) // appHandler now takes typedParams
            let resultAsAnyCodable = AnyCodable(actualResult) // Encode result to AnyCodable
            let response = MCPSchema.JSONRPCResponse(id: id, result: resultAsAnyCodable) // For successful response
            await self.sendRawResponse(response)
        } catch {
            print("MCPClient: Application handler for '\(Constants.MCPMethods.Sampling.createMessage)' (ID: \(id.asString)) threw an error: \(error.localizedDescription)")
            let errorDetail = MCPSchema.JSONRPCError.ErrorObject(code: -32603, message: "Internal error in application handler for '\(Constants.MCPMethods.Sampling.createMessage)': \(error.localizedDescription)")
            let mcpError = MCPSchema.JSONRPCError(id: id, error: errorDetail)
            await self.sendRawError(mcpError) // Changed to sendRawError
        }
    }

    /// Helper to send a pre-constructed JSONRPCResponse (typically an error response for server requests).
    private func sendRawResponse(_ response: MCPSchema.JSONRPCResponse) async { // For successful responses
        do {
            let encodedResponse = try self.jsonEncoder.encode(response)
            try await self.transport.send(encodedResponse)
        } catch {
            print("MCPClient Error: Failed to encode or send raw response for ID \(response.id.asString). Error: \(error)")
        }
    }

    /// Helper to send a pre-constructed JSONRPCError.
    private func sendRawError(_ errorResponse: MCPSchema.JSONRPCError) async { // For error responses
        do {
            let encodedError = try self.jsonEncoder.encode(errorResponse)
            try await self.transport.send(encodedError)
        } catch {
            print("MCPClient Error: Failed to encode or send raw error for ID \(errorResponse.id.asString). Error: \(error)")
        }
    }

    /// Helper function to decode AnyCodable parameters into a specific Decodable type.
    private func decodeParams<T: Decodable>(_ anyCodableParams: AnyCodable?, as type: T.Type) throws -> T {
        guard let params = anyCodableParams else {
            // This case depends on whether nil params are valid for T. 
            // If T itself is Optional, this might be fine. If T is non-optional, this is an error.
            // For simplicity, let's assume if params are expected, anyCodableParams shouldn't be nil.
            // Or, T could be an optional type itself e.g. MyParamsType?
            throw MCPClientError.typeCastingFailed(expectedType: String(describing: T.self), actualValueDescription: "nil AnyCodable parameters") // Changed to typeCastingFailed
        }
        let paramsData = try self.jsonEncoder.encode(params) // Re-encode AnyCodable to Data
        return try self.jsonDecoder.decode(T.self, from: paramsData) // Decode to expected type
    }

    // MARK: - Placeholder Notification Handlers

    private func handleLoggingMessageNotification(params: LoggingMessageNotification.Params) async {
        // print("MCPClient [Server Log]: \(params.data)") // Access actual log data via params.data
        if let handler = self.onLoggingMessage {
            handler(params)
        } else {
            print("MCPClient: 'logging/message' notification received, but no onLoggingMessage handler is set.")
        }
    }

    private func handleResourceUpdateNotification(params: ResourceUpdatedNotification.Params) async {
        // print("MCPClient [Resource Update]: Resource \(params.uri) updated.")
        if let handler = self.onResourceUpdate {
            handler(params)
        } else {
            print("MCPClient: 'resources/updated' notification received, but no onResourceUpdate handler is set.")
        }
    }

    // MARK: - Heartbeat Management

    private func isPersistentTransport() -> Bool {
        #if os(macOS)
        if transport is StdioTransport { return true }
        #endif
        if transport is SSETransport { return true }
        // Add StreamableHTTPTransport if it can be used in a persistent streaming mode
        // if transport is StreamableHTTPTransport { return true } 
        return false
    }

    private func startHeartbeatIfNeeded() async {
        guard let interval = self.heartbeatInterval, interval > 0, isPersistentTransport(), self.connectionState == .connected else { 
            // print("MCPClient: Heartbeat not started. Interval: \(String(describing: heartbeatInterval)), Persistent: \(isPersistentTransport()), State: \(connectionState)")
            return
        }

        // Cancel any existing heartbeat task before starting a new one
        await stopHeartbeat() // Ensure previous is stopped

        print("MCPClient: Starting heartbeat with interval \(interval)s.")
        heartbeatTask = Task { [weak self] in
            guard let self = self else { return }
            while !Task.isCancelled {
                // Check connection state before sleeping and before pinging
                // This ensures that if disconnect happens while sleeping, we don't ping.
                guard await self.connectionState == .connected else { 
                    print("MCPClient: Heartbeat: No longer connected, stopping.")
                    break
                }

                do {
                    // Ensure client is connected before sending. Transport is non-optional.
                    guard await self.connectionState == .connected else { 
                        print("MCPClient: Heartbeat: Not connected, stopping.")
                        break
                    }
                    try await Task.sleep(for: .seconds(interval)) // Ensure await is here
                    
                    // Re-check cancellation and connection state after sleep
                    if Task.isCancelled { break }
                    guard await self.connectionState == .connected else { 
                        print("MCPClient: Heartbeat: No longer connected after sleep, stopping.")
                        break
                    }
                    
                    print("MCPClient: Heartbeat: Sending ping...")
                    try await self.performPing() // Ensure await is here
                } catch is CancellationError {
                    print("MCPClient: Heartbeat task cancelled.")
                    break
                } catch {
                    print("MCPClient: Heartbeat: Ping failed: \(error). Connection considered broken.")
                    // Use a non-blocking Task to call handleConnectionFailure to avoid deadlocking the actor
                    // if handleConnectionFailure itself tries to re-acquire actor context in a blocking way.
                    // However, handleConnectionFailure is an async func on the actor, so direct await is fine.
                    await self.handleConnectionFailure(error: MCPClientError.pingFailed(underlyingError: error))
                    break // Exit heartbeat loop
                }
            }
            print("MCPClient: Heartbeat task finished.")
            // Ensure task reference is cleared if it finishes naturally (e.g. due to state change)
            // However, stopHeartbeat() should be the primary way it's cleared.
            // If we are cancelling, the state might need to be adjusted if it was .reconnecting.
            // However, usually, a manual connect/disconnect will set the state appropriately afterwards.
            // If current state is .reconnecting, and we cancel, what should be the state?
            // It should transition to .disconnected(error: nil) if cancelled by a manual disconnect
            // or .connecting if cancelled by a manual connect.
            // This method is primarily for stopping the *task*. State is managed by callers.
        }
    }

    private func stopHeartbeat() async {
        if heartbeatTask != nil {
            print("MCPClient: Stopping heartbeat task.")
            heartbeatTask?.cancel()
            heartbeatTask = nil
        }
    }

    private func performPing() async throws {
        // Assuming sendRequest has its own timeout mechanism or handles transport errors effectively.
        // If sendRequest can hang indefinitely on a broken connection without a timeout,
        // this performPing might need to be wrapped with a timeout, e.g.:
        // try await withTimeout(seconds: 5) { // Hypothetical timeout utility
        //    _ = try await self.sendRequest(method: "mcp/ping", params: NoParams(), responseType: NoResult.self)
        // }
        print("MCPClient: performPing() called")
        let _: NoResult = try await self.sendRequest(method: "mcp/ping", params: NoParams()) // Corrected call with type annotation
        print("MCPClient: Ping successful.")
    }

    // MARK: - Connection Failure Handling

    private func handleConnectionFailure(error: Error) async {
        // Ensure this is only processed if we are in a state that expects a connection.
        guard self.connectionState == .connected || self.connectionState == .connecting else { 
            print("MCPClient: handleConnectionFailure called in state \(self.connectionState) with error \(error). Ignoring as not connected/connecting.")
            return
        }
        
        print("MCPClient: Handling connection failure: \(error)")
        await self.stopHeartbeat() // Stop heartbeat first
        
        // Set the state to disconnected with the error.
        // This state change should be observed by any reconnection logic (Step 4.3).
        self.connectionState = .disconnected(error: error)
        
        // Important: The transportStateObservationTask might also detect the disconnection if it's a transport-level issue.
        // This handleConnectionFailure is more for logical failures like ping timeout or server error on ping.
        // We need to ensure that we also clean up other tasks as if the transport itself reported disconnection.
        // Calling cleanupConnectionTasksAndState ensures transport.disconnect, task cancellations, etc.
        // However, be careful not to cause re-entrant calls if cleanupConnectionTasksAndState itself calls handleConnectionFailure.
        // The guard at the start of this func should prevent simple re-entrancy on state.
        
        // For a ping failure, the transport might still think it's connected.
        // We are declaring the *MCP session* as dead.
        // We should still try to tell the transport to disconnect to clean up its resources.
        print("MCPClient: Connection failure handled. Requesting transport cleanup.")
        // No, don't call full cleanup here as it might be too aggressive if reconnection is desired.
        // The primary role of handleConnectionFailure is to set state to .disconnected(error: error)
        // and stop heartbeats. Reconnection logic (4.3) or explicit disconnect() will do full cleanup.
        // For now, we ensure the transport.disconnect() is called by the main disconnect() path
        // or when the transportStateObservationTask sees the transport truly die.
        // If a ping fails, we mark MCPClient as disconnected. If user calls disconnect(), it will clean up.
        // If reconnection logic kicks in, it will call connect(), which starts fresh.
    }

    // MARK: - Reconnection Management

    private func connectionStateDidChange(from oldState: ConnectionState, to newState: ConnectionState) async {
        if case .disconnected(let error) = newState, error != nil {
            print("MCPClient: connectionStateDidChange - Detected disconnection with error: \(error!).")
            await initiateReconnectionIfNeeded(withError: error!)
        } else if newState == .connected {
            print("MCPClient: connectionStateDidChange - Successfully connected. Resetting reconnection attempts.")
            await cancelReconnectionAttempt() // Clears task and potentially resets state from .reconnecting
            self.currentReconnectAttempt = 0 // Explicitly reset attempt count
        }

        // Stop heartbeat if we are no longer in a connected state and heartbeat was running.
        // This check is important because handleConnectionFailure also calls stopHeartbeat.
        // We want to ensure it's stopped if state moves from .connected for any other reason too.
        if oldState == .connected && newState != .connected {
            if heartbeatTask != nil { // Check if heartbeat was running
                 print("MCPClient: connectionStateDidChange - No longer connected (was \(oldState), now \(newState)), ensuring heartbeat is stopped.")
                await stopHeartbeat()
            }
        }
    }

    private func initiateReconnectionIfNeeded(withError error: Error) async {
        guard enableAutoReconnect else {
            print("MCPClient: Auto-reconnect is disabled. Will not attempt to reconnect.")
            return
        }
        // Ensure we are actually in a disconnected state with an error.
        // The call from connectionStateDidChange already checks this, but good for direct calls if any.
        guard case .disconnected(let currentError) = self.connectionState, currentError != nil else {
            print("MCPClient: initiateReconnectionIfNeeded called but state is not .disconnected with error, or auto-reconnect disabled. Current state: \(self.connectionState)")
            return
        }

        // Don't attempt reconnection if a reconnection task is already running or starting
        guard reconnectionTask == nil else {
            print("MCPClient: Reconnection attempt already in progress or scheduled.")
            return
        }
        
        print("MCPClient: Initiating reconnection process due to error: \(error)")
        self.currentReconnectAttempt = 0 // Reset before starting a new loop
        self.reconnectionTask = Task { [weak self] in
            await self?.runReconnectionLoop()
            // Ensure task reference is cleared when loop finishes or is cancelled externally
            // This is important so that a new reconnection can be initiated if needed later.
            await self?.clearReconnectionTask()
        }
    }

    private func runReconnectionLoop() async {
        while !Task.isCancelled {
            self.currentReconnectAttempt += 1
            if maxReconnectAttempts > 0 && self.currentReconnectAttempt > maxReconnectAttempts {
                print("MCPClient: Max reconnection attempts (\(maxReconnectAttempts)) reached.")
                self.connectionState = .disconnected(error: MCPClientError.maxReconnectAttemptsReached) // Final disconnected state
                break // Exit loop
            }

            var delay = min(maxReconnectDelay, baseReconnectDelay * pow(2.0, Double(currentReconnectAttempt - 1)))
            let jitterRange = delay * reconnectDelayJitterFactor
            let jitter = Double.random(in: -jitterRange...jitterRange)
            delay = max(0.1, delay + jitter) // Ensure delay is not negative or too small

            self.connectionState = .reconnecting(attempt: currentReconnectAttempt, nextAttemptIn: delay)
            print("MCPClient: Reconnecting attempt \(currentReconnectAttempt) of \(maxReconnectAttempts > 0 ? String(maxReconnectAttempts) : "infinity"), next attempt in \(String(format: "%.2f", delay))s.")
            
            do {
                try await Task.sleep(for: .seconds(delay))
                if Task.isCancelled { 
                    print("MCPClient: Reconnection loop sleep cancelled.")
                    break 
                }

                print("MCPClient: Attempting to connect (reconnect attempt \(currentReconnectAttempt))...")
                try await self.connect(isRetryAttempt: true)
                    
                // If connect() succeeds, connectionState becomes .connected.
                // The connectionState.didSet -> connectionStateDidChange logic will:
                // 1. Call cancelReconnectionAttempt() (which cancels this task and nils reconnectionTask).
                // 2. Reset currentReconnectAttempt = 0.
                // So, this loop should effectively terminate if connect() is successful.
                // We add an explicit check for .connected state to break, though cancellation is primary exit.
                if self.connectionState == .connected {
                    print("MCPClient: Reconnection successful on attempt \(currentReconnectAttempt). Loop should terminate via cancellation.")
                    // The task will be cancelled by cancelReconnectionAttempt called from connectionStateDidChange.
                    // No need to break explicitly if cancellation is reliable.
                    // However, if cancellation is not immediate, this break helps exit sooner.
                    break
                }
                // If connect() failed, connectionState will be .disconnected(error), and loop continues.
                // The error from connect() is handled by connect() itself setting the state.
            } catch is CancellationError {
                print("MCPClient: Reconnection task explicitly cancelled.")
                break
            } catch {
                // This catch block handles errors from self.connect(isRetryAttempt: true)
                // connect() itself should set the state to .disconnected(error: connectError)
                print("MCPClient: Reconnect attempt \(currentReconnectAttempt) failed: \(error). State is \(self.connectionState). Will retry if attempts remain.")
                // Loop will continue if attempts remain and task not cancelled.
            }
        }
        print("MCPClient: Exited reconnection loop. Attempt: \(currentReconnectAttempt)")
    }

    private func cancelReconnectionAttempt() async {
        if let task = self.reconnectionTask {
            print("MCPClient: Cancelling ongoing reconnection task.")
            task.cancel()
            // self.reconnectionTask = nil // Do not nil out here, let the task clean itself up via clearReconnectionTask()
            // If we are cancelling, the state might need to be adjusted if it was .reconnecting.
            // However, usually, a manual connect/disconnect will set the state appropriately afterwards.
            // If current state is .reconnecting, and we cancel, what should be the state?
            // It should transition to .disconnected(error: nil) if cancelled by a manual disconnect
            // or .connecting if cancelled by a manual connect.
            // This method is primarily for stopping the *task*. State is managed by callers.
        }
    }
    
    private func clearReconnectionTask() async {
        print("MCPClient: Clearing reconnection task reference.")
        self.reconnectionTask = nil
        // If the loop finished because max attempts were reached, state is already .disconnected(MCPError.maxReconnectAttemptsReached)
        // If it was cancelled by a successful connection, state is .connected.
        // If cancelled by manual disconnect/connect, state is set by those methods.
    }
}
