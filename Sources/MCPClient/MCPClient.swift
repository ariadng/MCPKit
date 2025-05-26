//
//  MCPClient.swift
//  MCPKit
//
//  Created by Cascade on 2025-05-26.
//

import Foundation
// Assuming schema types are accessible from this module, e.g., part of the same target.
// The MCPTransport protocol is now defined in Sources/Transport/MCPTransport.swift

/// MCPClient is an actor responsible for managing communication with an MCP server.
/// It handles JSON-RPC 2.0 session management, request sending, and response/notification processing.
public actor MCPClient {
    // MARK: - Properties

    /// The current connection state of the client.
    public private(set) var connectionState: ConnectionState = .disconnected(reason: .normal)

    /// The transport mechanism used for sending and receiving data.
    private let transport: MCPTransport

    /// Configuration for the transport, dictating which transport is used and its parameters.
    public let transportConfiguration: MCPTransportConfiguration

    /// Capabilities of this client, to be sent during initialization.
    private let clientCapabilities: ClientCapabilities

    /// Capabilities reported by the server after successful initialization.
    public private(set) var serverCapabilities: ServerCapabilities?

    /// Stores pending requests awaiting a response from the server.
    /// Keyed by request ID.
    private var pendingRequests: [String: PendingRequest] = [:]

    /// Counter for generating unique request IDs.
    private var requestIDCounter: Int = 0

    /// Task responsible for processing incoming messages from the transport layer.
    private var messageProcessingTask: Task<Void, Error>?

    /// Task responsible for observing the transport's connection state changes.
    private var transportStateObservationTask: Task<Void, Never>?

    // MARK: - Internal Structures

    /// Represents a pending request, holding its continuation and expected response type.
    private struct PendingRequest {
        let continuation: CheckedContinuation<Any, Error>
        let responseType: Decodable.Type
    }

    /// A helper struct to decode the base fields of a JSON-RPC message
    /// to determine if it's a response, notification, or server request.
    private struct BaseMessage: Decodable {
        let id: String?
        let method: String?
    }

    // MARK: - Initialization and Lifecycle

    /// Initializes a new MCPClient with a specific transport configuration and client capabilities.
    /// - Parameter transportConfiguration: The configuration specifying the transport to use.
    /// - Parameter clientCapabilities: The capabilities of this client.
    /// - Throws: An error if the transport cannot be initialized (though current transport inits don't throw).
    public init(transportConfiguration: MCPTransportConfiguration, clientCapabilities: ClientCapabilities) throws {
        self.transportConfiguration = transportConfiguration
        self.clientCapabilities = clientCapabilities

        switch transportConfiguration {
        #if os(macOS)
        case .stdio(let commandPath, let arguments):
            self.transport = StdioTransport(commandPath: commandPath, arguments: arguments)
        #endif
        case .sse(let url, let maxRetryAttempts, let baseRetryDelay):
            self.transport = SSETransport(url: url, maxRetryAttempts: maxRetryAttempts, baseRetryDelay: baseRetryDelay)
        case .streamableHTTP(let url, let httpMethod):
            self.transport = StreamableHTTPTransport(url: url, httpMethod: httpMethod)
        // If stdio is the only case and it's not macOS, this might lead to a compile error
        // Ensure all cases are handled or provide a default/error for non-macOS stdio if it were possible.
        // Current MCPTransportConfiguration is #if os(macOS) for stdio, so this structure is fine.
        }
    }

    deinit {
        // Ensure tasks are cancelled on deinitialization, though explicit disconnect is preferred.
        messageProcessingTask?.cancel()
        transportStateObservationTask?.cancel()
        // If transport has a synchronous disconnect, call it here.
        // Otherwise, an explicit async disconnect method is better.
    }

    /// Establishes a connection to the server using the configured transport.
    public func connect() async throws {
        // Guard against multiple concurrent connection attempts or connecting when already connected.
        // Allow re-connection if disconnected (even with an error).
        guard connectionState == .disconnected(reason: nil) || 
              connectionState == .disconnected(reason: .normal) || 
              isDisconnectedWithErrorInternal() || 
              connectionState == .disconnecting else {
            print("MCPClient: Already connected or in the process of connecting/disconnecting from a non-error state: \(connectionState).")
            throw MCPClientError.alreadyConnected
        }

        self.connectionState = .connecting
        print("MCPClient: State changed to connecting.")

        // Start observing transport state changes.
        // This task should be managed (e.g., cancelled on disconnect).
        transportStateObservationTask?.cancel() // Cancel any previous observation task
        transportStateObservationTask = Task {
            // Now using the stateStream from the MCPTransport protocol.
            print("MCPClient: Starting transport state observation task.")
            for await transportState in self.transport.stateStream { 
               print("MCPClient: Received transport state: \(transportState)")
               switch transportState {
               case .connecting:
                   // MCPClient itself initiates connecting state, transport confirms.
                   // Only update if not already connecting or connected from client's perspective.
                   if self.connectionState != .connecting && self.connectionState != .connected {
                       self.connectionState = .connecting
                       print("MCPClient: State changed to connecting (from transport stateStream).")
                   }
               case .connected:
                   if self.connectionState != .connected {
                       self.connectionState = .connected
                       print("MCPClient: State changed to connected (from transport stateStream).")
                   }
               case .disconnected(let error):
                   print("MCPClient: Transport reported disconnected via stateStream, error: \(String(describing: error)). Initiating client disconnect.")
                   if let err = error {
                       // Avoid re-disconnecting if already in the process for the same transport error
                       if case .disconnected(reason: .transportError(let existingError)) = self.connectionState, (err as NSError).isEqual(existingError as NSError) {
                           // Already disconnected for this specific transport error
                       } else if case .disconnected(reason: .connectionFailed(let existingError)) = self.connectionState, (err as NSError).isEqual(existingError as NSError) {
                           // Already disconnected for this specific connection failure error
                       } else {
                           await self.disconnect(reason: .transportError(err))
                       }
                   } else {
                       // Avoid re-disconnecting if already disconnected normally
                       if self.connectionState != .disconnected(reason: .normal) {
                           await self.disconnect(reason: .normal)
                       }
                   }
                   return // Exit task as client is disconnecting or already disconnected by transport's report.
               }
            }
            print("MCPClient: Transport state observation task finished (stream closed).")
            // If the stream closes, ensure client is in a disconnected state if not already handled by a .disconnected event.
            if self.connectionState != .disconnected(reason: .normal) && !self.isDisconnectedWithErrorInternal() {
               await self.disconnect(reason: .normal) 
            }
        }

        // Start listening to incoming messages from the transport.
        // This is the messageProcessingTask.
        startListeningToTransportInternal() // Renamed to avoid confusion with a potentially public API

        do {
            try await transport.connect()
            // If connect succeeds, we assume the transport is connected.
            // The stateStream (when implemented) would confirm this.
            // For now, directly set to connected if no error.
            self.connectionState = .connected
            print("MCPClient: transport.connect() succeeded. State changed to connected.")
            
            // If a handshake is required by MCPClient *after* the transport layer connects, trigger it here.
            // e.g., try await self.performHandshake()

        } catch {
            print("MCPClient: transport.connect() failed. Error: \(error)")
            let disconnectReason = DisconnectReason.connectionFailed(error)
            await self.disconnect(reason: disconnectReason)
            throw error
        }
    }

    /// Disconnects from the server and cleans up resources.
    public func disconnect(reason: DisconnectReason = .normal) async {
        guard connectionState == .connected || connectionState == .connecting || connectionState == .disconnecting else {
            // If already disconnected with the same reason, or trying to disconnect normally from an error state, allow.
            if case .disconnected(let currentReason) = connectionState, currentReason == reason { return } // Already disconnected with this reason
            // Allow disconnecting normally even if previously disconnected with error
            if reason == .normal, case .disconnected = connectionState { /* allow */ } 
            else if connectionState != .connecting { // if not connecting, and not one of the above, then it's an invalid state to disconnect from
                 print("MCPClient: Not in a valid state to disconnect (current: \(connectionState), requested reason: \(reason)).")
                 return
            }
        }

        // If already disconnecting, and this call is for a different reason (e.g. error during disconnecting)
        // we might want to update the reason. For now, let's assume disconnect is idempotent if already disconnecting.
        if connectionState == .disconnecting && reason != .normal {
             print("MCPClient: Already disconnecting. New disconnect reason \(reason) requested.")
             // Potentially update a pending disconnect reason if that's a desired feature.
        } else {
            self.connectionState = .disconnecting
        }
        
        stopListeningToTransportInternal() // Renamed to ensure it calls the task canceller
        await transport.disconnect() // MCPTransport.disconnect is async
        // If MCPTransport.disconnect becomes async, this should be `await transport.disconnect()`
        
        self.pendingRequests.forEach { _, value in
            value.continuation.resume(throwing: MCPClientError.transportError(CocoaError(.userCancelled))) // Or a more specific error based on disconnect reason
        }
        self.pendingRequests.removeAll()
        self.connectionState = .disconnected(reason: reason)
        print("MCPClient: Disconnected. Reason: \(reason)")
    }

    // Helper to check if currently disconnected due to an error
    private func isDisconnectedWithError() -> Bool {
        if case .disconnected(let reason) = connectionState, reason != .normal && reason != nil {
            return true
        }
        return false
    }

    // Helper to check if currently disconnected due to an error (internal version)
    private func isDisconnectedWithErrorInternal() -> Bool {
        if case .disconnected(let reason) = connectionState, reason != .normal && reason != nil {
            return true
        }
        return false
    }

    // MARK: - API Layer (Public Methods)

    /// Initializes the JSON-RPC session with the server.
    /// The client sends its capabilities (provided at MCPClient initialization),
    /// and the server responds with its own.
    /// - Returns: The capabilities of the server.
    public func initialize() async throws -> ServerCapabilities {
        let params = InitializeRequestParams(capabilities: self.clientCapabilities)
        // The `sendRequest` method handles JSON-RPC wrapping, ID generation, sending, and response matching.
        // It's expected to return the decoded result of the type specified (ServerCapabilities in this case).
        let serverCaps: ServerCapabilities = try await self.sendRequest(method: "session/initialize", params: params)
        self.serverCapabilities = serverCaps // Store server capabilities upon successful initialization
        return serverCaps
    }

    /// Lists available resources on the server.
    /// Resources are typically documents or data items the server can provide.
    /// - Returns: An array of `Resource` objects, representing available resources.
    public func listResources() async throws -> [Resource] {
        let method = "resources/list"
        // This operation takes no parameters, so we use `EmptyParams`.
        let result: ListResourcesResult = try await self.sendRequest(method: method, params: EmptyParams())
        return result.resources
    }

    /// Retrieves a specific prompt by its ID.
    /// Prompts are typically used to guide language model interactions.
    /// - Parameter id: The ID of the prompt to retrieve.
    /// - Returns: The `Prompt` object.
    public func getPrompt(id: String) async throws -> Prompt {
        let method = "prompts/get"
        let params = GetPromptParams(id: id)
        let result: GetPromptResult = try await self.sendRequest(method: method, params: params)
        return result.prompt
    }

    /// Reads the content of a specific resource, optionally at a specific version.
    /// - Parameters:
    ///   - id: The ID of the resource to read.
    ///   - version: Optional version string for the resource.
    /// - Returns: The content of the resource.
    public func readResource(id: String, version: String?) async throws -> ResourceContent {
        let method = "resources/read"
        let params = ReadResourceParams(id: id, version: version)
        // Assuming ResourceContent is the direct result type from the schema for this call.
        let content: ResourceContent = try await self.sendRequest(method: method, params: params)
        return content
    }

    /// Calls a tool on the server with the given name and arguments.
    /// Tools are server-defined functions that the client can invoke.
    /// - Parameters:
    ///   - name: The name of the tool to call.
    ///   - arguments: Optional arguments for the tool, structured as a dictionary.
    /// - Returns: The result of the tool call, as defined by `CallToolResult`.
    public func callTool(name: String, arguments: [String: AnyCodable]? = nil) async throws -> CallToolResult {
        let method = "tool/call"
        let params = CallToolParams(name: name, arguments: arguments)
        // Assuming CallToolResult is the direct result type from the schema for this call.
        let result: CallToolResult = try await self.sendRequest(method: method, params: params)
        return result
    }

    // MARK: - Message Dispatch/Session Layer

    /// Generates the next unique request ID.
    /// IDs are simple integers converted to strings.
    private func nextRequestID() -> String {
        requestIDCounter += 1
        return String(requestIDCounter)
    }

    /// Sends a JSON-RPC request to the server and awaits its response.
    /// This is a private method used by the public API methods to abstract JSON-RPC details.
    /// - Parameters:
    ///   - method: The name of the JSON-RPC method to call (e.g., "session/initialize").
    ///   - params: The parameters for the method, conforming to `Encodable`.
    /// - Returns: The decoded result of the method call, conforming to `Decodable`.
    private func sendRequest<Params: Encodable, ResultType: Decodable>(method: String, params: Params) async throws -> ResultType {
        guard connectionState == .connected else {
            print("MCPClient: Not connected, cannot send request.")
            throw MCPClientError.notConnected
        }

        let requestID = nextRequestID()
        let rpcRequest = JSONRPCRequest(id: requestID, method: method, params: params)

        let encodedRequestData: Data
        do {
            encodedRequestData = try JSONEncoder().encode(rpcRequest)
            // print("MCPClient SEND [\(requestID)]: \(String(data: encodedRequestData, encoding: .utf8) ?? "")")
        } catch {
            print("MCPClient: Failed to encode request \(requestID) - \(error)")
            throw MCPClientError.requestEncodingFailed(error)
        }

        return try await withCheckedThrowingContinuation { continuation in
            let pending = PendingRequest(continuation: continuation as! CheckedContinuation<Any, Error>, responseType: ResultType.self)
            self.pendingRequests[requestID] = pending

            Task {
                do {
                    try await transport.send(data: encodedRequestData)
                } catch {
                    print("MCPClient: Failed to send request \(requestID) over transport - \(error)")
                    if let removed = self.pendingRequests.removeValue(forKey: requestID) {
                        removed.continuation.resume(throwing: MCPClientError.transportError(error))
                    }
                }
            }
        }
    }

    /// Starts a task to listen for and process incoming messages from the transport.
    private func startListeningToTransportInternal() { // Renamed from startListeningToTransport
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
            } catch {
                if Task.isCancelled {
                    print("MCPClient: Message processing task cancelled normally.")
                } else {
                    print("MCPClient: Message processing task ended with error - \(error)")
                    // Handle transport errors, e.g., by attempting to reconnect or transitioning to a disconnected state.
                    await self.disconnect(reason: .transportError(error)) // Pass the specific error
                }
            }
            print("MCPClient: Message processing task finished.")
        }
    }

    /// Stops the task that listens for incoming messages.
    private func stopListeningToTransportInternal() { // Renamed from stopListeningToTransport
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
        let baseMessage: BaseMessage
        do {
            baseMessage = try JSONDecoder().decode(BaseMessage.self, from: data)
        } catch {
            print("MCPClient Error: Failed to decode base message: \(error). Data: \(String(data: data, encoding: .utf8) ?? "Invalid UTF8")")
            // Consider how to handle undecipherable messages. For now, just log and ignore.
            return
        }

        if let id = baseMessage.id, baseMessage.method == nil { // Response (id present, method absent)
            await handleResponse(id: id, data: data)
        } else if let method = baseMessage.method, baseMessage.id == nil { // Notification (method present, id absent)
            await handleNotification(method: method, data: data)
        } else if let method = baseMessage.method, let id = baseMessage.id { // Server Request (method and id present)
            await handleServerRequest(id: id, method: method, data: data)
        } else {
            print("MCPClient Error: Unexpected message format. Data: \(String(data: data, encoding: .utf8) ?? "Invalid UTF8")")
        }
    }

    /// Handles a JSON-RPC response message.
    private func handleResponse(id: String, data: Data) async {
        guard let pending = pendingRequests.removeValue(forKey: id) else {
            print("MCPClient: Received unsolicited response for ID \(id). Ignoring. Data: \(String(data: data, encoding: .utf8) ?? "")")
            // It's important not to throw here if the continuation is not found,
            // as this method is part of the general message handling loop.
            return
        }

        do {
            // First, try to decode as a successful response for the expected type
            // This requires a generic helper or careful handling of `pending.responseType`
            // For simplicity, let's assume JSONRPCResponse can be decoded with AnyCodable for result first,
            // then attempt to convert to the specific type.
            let genericResponse = try JSONDecoder().decode(JSONRPCResponse<AnyCodable, JSONRPCErrorObject>.self, from: data)

            if let errorObject = genericResponse.error {
                print("MCPClient: Received error response for ID \(id): \(errorObject)")
                pending.continuation.resume(throwing: MCPClientError.jsonRpcError(errorObject))
            } else if let resultValue = genericResponse.result {
                // Now, try to convert AnyCodable to the actual expected Decodable type
                let specificResultData = try resultValue.encode()
                let specificResult = try JSONDecoder().decode(pending.responseType, from: specificResultData)
                pending.continuation.resume(returning: specificResult)
            } else {
                // This case should ideally not happen if JSON-RPC is followed (either result or error must be present)
                print("MCPClient Error: Response for ID \(id) has neither result nor error.")
                pending.continuation.resume(throwing: MCPClientError.unexpectedMessageFormat)
            }
        } catch {
            print("MCPClient Error: Failed to decode or process response for ID \(id): \(error). Data: \(String(data: data, encoding: .utf8) ?? "")")
            pending.continuation.resume(throwing: MCPClientError.responseDecodingFailed(error))
        }
    }

    /// Handles a JSON-RPC notification message.
    private func handleNotification(method: String, data: Data) async {
        print("MCPClient: Received notification: \(method). Data: \(String(data: data, encoding: .utf8) ?? "")")
        // TODO: Implement notification handling logic
        // This might involve delegates, callbacks, or specific notification handler methods.
        // Example: NotificationCenter.default.post(name: .init(method), object: decodedNotificationParams)
    }

    /// Handles a JSON-RPC request message initiated by the server.
    private func handleServerRequest(id: String, method: String, data: Data) async {
        print("MCPClient: Received server request: \(method) (ID: \(id)). Data: \(String(data: data, encoding: .utf8) ?? "")")
        // TODO: Implement server request handling logic
        // This would involve decoding the params, processing the request, and sending a response.
        // For now, send a 'method_not_found' error.
        let error = JSONRPCErrorObject(code: -32601, message: "Method not found", data: nil)
        await sendErrorResponse(forRequestID: id, error: error)
    }

    private func sendErrorResponse(forRequestID id: String, error: JSONRPCErrorObject) async {
        let response = JSONRPCResponse<EmptyCodable, JSONRPCErrorObject>(id: id, result: nil, error: error) // Using EmptyCodable for no result
        do {
            let responseData = try JSONEncoder().encode(response)
            try await transport.send(data: responseData)
        } catch {
            print("MCPClient: Failed to send error response for server request \(id): \(error)")
        }
    }
}
