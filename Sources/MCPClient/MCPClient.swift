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

    /// JSON encoder for serializing requests.
    private let jsonEncoder = JSONEncoder()

    /// JSON decoder for deserializing responses and notifications.
    private let jsonDecoder = JSONDecoder()

    /// Task responsible for processing incoming messages from the transport layer.
    private var messageProcessingTask: Task<Void, Error>?

    /// Task responsible for observing the transport's connection state changes.
    private var transportStateObservationTask: Task<Void, Never>?

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

    /// A helper struct to decode the base fields of a JSON-RPC message
    /// to determine if it's a response, notification, or server request.
    private struct JSONRPCMessageBase: Decodable {
        let id: RequestId?
        let method: String?
        let result: AnyCodable?
        let error: JSONRPCErrorObject?
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
    private func sendRequest<Params: Encodable, ResultType: Decodable>(
        method: String,
        params: Params?
    ) async throws -> ResultType {
        let requestIDString = nextRequestID()
        // Assuming RequestId is a struct/enum from schema that can be initialized with a string value.
        // e.g., if RequestId is struct RequestId { let value: String }, then RequestId(value: requestIDString)
        let mcpRequestID = RequestId(value: requestIDString) // Adjust if RequestId init is different

        // Construct the JSON-RPC request object using schema types.
        // JSONRPCRequest.params expects AnyCodable?, so wrap params if present.
        let jsonRpcRequest = JSONRPCRequest(id: mcpRequestID, method: method, params: params.map { AnyCodable($0) })

        let encodedRequestData: Data
        do {
            encodedRequestData = try self.jsonEncoder.encode(jsonRpcRequest)
            // For debugging:
            // print("MCPClient [Request ID: \(requestIDString)] Sending: \(String(data: encodedRequestData, encoding: .utf8) ?? "Non-UTF8 data")")
        } catch {
            // Encoding failed, no continuation stored yet, just throw.
            throw MCPClientError.encodingError(description: "Failed to encode request for method \(method)", underlyingError: error)
        }

        return try await withCheckedThrowingContinuation { continuation in
            let pendingRequest = PendingRequest(continuation: continuation as! CheckedContinuation<Any, Error>, responseType: ResultType.self)
            self.pendingRequests[requestIDString] = pendingRequest

            Task {
                do {
                    // Ensure client is connected before sending. Transport is non-optional.
                    guard self.connectionState == .connected else {
                        if self.pendingRequests.removeValue(forKey: requestIDString) != nil {
                            (continuation as! CheckedContinuation<ResultType, Error>).resume(throwing: MCPClientError.clientNotConnected)
                        }
                        return
                    }
                    try await self.transport.send(encodedRequestData)
                } catch {
                    // Transport failed to send. Remove pending request and resume continuation with error.
                    if self.pendingRequests.removeValue(forKey: requestIDString) != nil {
                        (continuation as! CheckedContinuation<ResultType, Error>).resume(throwing: error)
                    }
                }
            }
        }
    }

    // MARK: - Message Dispatch/Session Layer

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
            guard let pending = self.pendingRequests.removeValue(forKey: id.stringValue) else { // Assuming RequestId has stringValue or similar
                print("MCPClient Error: Received response for unknown request ID: \(id.stringValue). Discarding. Data: \(String(data: data, encoding: .utf8) ?? "Non-UTF8 data")")
                // Log MCPClientError.unknownRequestID(id.stringValue) if you have a logging mechanism
                return
            }

            if let errorObject = baseMessage.error {
                // Server returned an error
                print("MCPClient: Received error response for ID \(id.stringValue): \(errorObject.code) - \(errorObject.message)")
                let mcpError = MCPClientError.serverError(code: errorObject.code, message: errorObject.message, data: errorObject.data)
                (pending.continuation as! CheckedContinuation<AnyDecodable, MCPClientError>).resume(throwing: mcpError) // Cast to specific error type if not Any
            } else if let resultObject = baseMessage.result {
                // Server returned a successful result
                do {
                    // The resultObject is AnyCodable. We need to decode it into the specific PendingRequest.responseType.
                    let resultData = try self.jsonEncoder.encode(resultObject) // Re-encode AnyCodable to Data
                    let typedResult = try self.jsonDecoder.decode(pending.responseType, from: resultData) // Decode to expected type
                    // print("MCPClient: Successfully decoded result for ID \(id.stringValue) to type \(pending.responseType)")
                    pending.continuation.resume(returning: typedResult)
                } catch {
                    print("MCPClient Error: Failed to decode result for request ID \(id.stringValue) into type \(pending.responseType). Error: \(error). Result data: \(String(describing: baseMessage.result))")
                    let mcpError = MCPClientError.decodingError(description: "Failed to decode result for request ID: \(id.stringValue) into \(pending.responseType)", underlyingError: error)
                    (pending.continuation as! CheckedContinuation<AnyDecodable, MCPClientError>).resume(throwing: mcpError)
                }
            } else {
                // Should not happen if id is present and it's a response (violates JSON-RPC spec if neither result nor error)
                print("MCPClient Error: Received response for ID \(id.stringValue) with no result or error. Data: \(String(data: data, encoding: .utf8) ?? "Non-UTF8 data")")
                let mcpError = MCPClientError.invalidMessageFormat(description: "Response for ID \(id.stringValue) had neither result nor error.")
                (pending.continuation as! CheckedContinuation<AnyDecodable, MCPClientError>).resume(throwing: mcpError)
            }

        // 2. Check for Notification (method is present, id is ABSENT)
        } else if let methodName = baseMessage.method, baseMessage.id == nil {
            // This is a Server-to-Client Notification
            // print("MCPClient: Received notification for method \(methodName)")
            do {
                // Decode the full notification including params
                let notification = try self.jsonDecoder.decode(JSONRPCNotification<AnyCodable>.self, from: data)
                await self.dispatchNotification(notification)
            } catch {
                print("MCPClient Error: Failed to decode notification for method \(methodName). Error: \(error). Data: \(String(data: data, encoding: .utf8) ?? "Invalid UTF8")")
                // Log MCPClientError.decodingError or .invalidMessageFormat
            }

        // 3. Check for Server-Initiated Request (method is present, id is present, AND no result/error)
        } else if let methodName = baseMessage.method, let requestID = baseMessage.id, baseMessage.result == nil && baseMessage.error == nil {
            // This is a Server-Initiated Request to the Client
            // print("MCPClient: Received server-initiated request (ID: \(requestID.stringValue), Method: \(methodName))")
            do {
                let serverRequest = try self.jsonDecoder.decode(JSONRPCRequest<AnyCodable>.self, from: data)
                await self.dispatchServerRequest(serverRequest)
            } catch {
                print("MCPClient Error: Failed to decode server-initiated request (ID: \(requestID.stringValue), Method: \(methodName)). Error: \(error). Data: \(String(data: data, encoding: .utf8) ?? "Non-UTF8 data")")
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

    private func dispatchNotification(_ notification: JSONRPCNotification<AnyCodable>) async {
        // print("MCPClient: Dispatching notification: \(notification.method)")
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

    private func dispatchServerRequest(_ request: JSONRPCRequest<AnyCodable>) async {
        // print("MCPClient: Dispatching server request: \(request.method), ID: \(request.id.stringValue)")
        switch request.method {
        case "sampling/createMessage": // Example for MCP Sampling
            do {
                let params = try decodeParams(request.params, as: CreateMessageRequest.Params.self)
                await self.handleSamplingCreateMessageRequest(id: request.id, params: params)
            } catch {
                print("MCPClient Error: Failed to decode params for 'sampling/createMessage' request. ID: \(request.id.stringValue). Error: \(error)")
                let errorResponse = JSONRPCResponse(id: request.id, error: JSONRPCErrorObject.invalidParams(message: "Failed to decode params: \(error.localizedDescription)"))
                await self.sendRawResponse(errorResponse)
            }
        // Add more cases for other server-initiated requests
        default:
            print("MCPClient Warning: Received server-initiated request for unknown method: \(request.method). ID: \(request.id.stringValue)")
            let errorResponse = JSONRPCResponse(id: request.id, error: JSONRPCErrorObject.methodNotFound(methodName: request.method))
            await self.sendRawResponse(errorResponse)
        }
    }

    /// Helper to send a pre-constructed JSONRPCResponse (typically an error response for server requests).
    private func sendRawResponse<T: Encodable, E: Encodable>(_ response: JSONRPCResponse<T, E>) async {
        do {
            let encodedResponse = try self.jsonEncoder.encode(response)
            try await self.transport.send(encodedResponse)
        } catch {
            print("MCPClient Error: Failed to encode or send raw response for ID \(response.id.stringValue). Error: \(error)")
        }
    }

    /// Helper function to decode AnyCodable parameters into a specific Decodable type.
    private func decodeParams<T: Decodable>(_ anyCodableParams: AnyCodable?, as type: T.Type) throws -> T {
        guard let params = anyCodableParams else {
            // This case depends on whether nil params are valid for T. 
            // If T itself is Optional, this might be fine. If T is non-optional, this is an error.
            // For simplicity, let's assume if params are expected, anyCodableParams shouldn't be nil.
            // Or, T could be an optional type itself e.g. MyParamsType?
            throw MCPClientError.decodingError(description: "Expected parameters of type \(String(describing: T.self)) but received nil AnyCodable.", underlyingError: nil)
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

    // MARK: - Placeholder Server-Initiated Request Handlers

    private func handleSamplingCreateMessageRequest(id: RequestId, params: CreateMessageRequest.Params) async {
        // print("MCPClient [Server Request]: Received 'sampling/createMessage' with ID \(id.stringValue) and params: \(params)")
        
        guard let appHandler = self.onSamplingCreateMessage else {
            print("MCPClient: 'sampling/createMessage' request received, but no onSamplingCreateMessage handler is set.")
            let error = JSONRPCErrorObject.methodNotFound(methodName: "sampling/createMessage (handler not configured on client)")
            let response = JSONRPCResponse<AnyCodable, JSONRPCErrorObject>(id: id, error: error)
            await self.sendRawResponse(response)
            return
        }

        do {
            let result = try await appHandler(params)
            let response = JSONRPCResponse(id: id, result: result)
            await self.sendRawResponse(response)
        } catch {
            print("MCPClient: Application handler for 'sampling/createMessage' (ID: \(id.stringValue)) threw an error: \(error.localizedDescription)")
            // You might want to define a more specific error code for application errors.
            let jsonRpcError = JSONRPCErrorObject.internalError(message: "Application handler for 'sampling/createMessage' failed: \(error.localizedDescription)")
            let response = JSONRPCResponse<AnyCodable, JSONRPCErrorObject>(id: id, error: jsonRpcError)
            await self.sendRawResponse(response)
        }
    }
}
