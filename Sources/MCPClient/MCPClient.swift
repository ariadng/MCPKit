//
//  MCPClient.swift
//  MCPKit
//
//  Created by Cascade on 2025-05-26.
//

import Foundation
// Assuming schema types are accessible from this module, e.g., part of the same target.

/// Represents the connection state of the MCPClient.
public enum ConnectionState {
    case disconnected
    case connecting
    case connected
    case disconnecting
}

/// Custom errors specific to MCPClient operations.
public enum MCPClientError: Error {
    case notConnected
    case requestEncodingFailed(Error)
    case responseDecodingFailed(Error)
    case transportError(Error)
    case unsolicitedResponse(id: String)
    case serverError(code: Int, message: String, data: AnyCodable?) // Assuming AnyCodable for flexible error data
    case unexpectedMessageFormat
    case continuationNotFound(id: String)
    case typeCastingFailed(expectedType: String, actualValue: Any)
    case jsonRpcError(JSONRPCErrorObject) // Assumes JSONRPCErrorObject is defined in schema
    case transportNotAvailable
    case alreadyConnected
    case notImplemented
}

// Placeholder for the transport protocol, to be defined in Phase 2
public protocol MCPTransport {
    func send(data: Data) async throws
    // Conceptual: incomingMessages could be an AsyncStream or use a delegate/callback pattern
    var incomingMessages: AsyncStream<Data> { get }
    func connect() async throws
    func disconnect()
}

/// MCPClient is an actor responsible for managing communication with an MCP server.
/// It handles JSON-RPC 2.0 session management, request sending, and response/notification processing.
public actor MCPClient {
    // MARK: - Properties

    /// The current connection state of the client.
    public private(set) var connectionState: ConnectionState = .disconnected

    /// The transport mechanism used for sending and receiving data.
    /// This will be set during connection.
    private var transport: MCPTransport?

    /// Configuration for the client, potentially including server details if not using stdio.
    public let clientConfiguration: StdioServerConfiguration? // Assuming StdioServerConfiguration is defined

    /// Capabilities reported by the server after successful initialization.
    public private(set) var serverCapabilities: ServerCapabilities?

    /// Stores pending requests awaiting a response from the server.
    /// Keyed by request ID.
    private var pendingRequests: [String: PendingRequest] = [:]

    /// Counter for generating unique request IDs.
    private var requestIDCounter: Int = 0

    /// Task responsible for processing incoming messages from the transport layer.
    private var messageProcessingTask: Task<Void, Error>?

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

    /// Initializes a new MCPClient.
    /// - Parameter configuration: Optional configuration for the client.
    public init(configuration: StdioServerConfiguration? = nil) {
        self.clientConfiguration = configuration
        // Transport is typically set via a connect method.
    }

    deinit {
        stopListeningToTransport()
        // If transport has a synchronous disconnect, call it here.
        // Otherwise, an explicit async disconnect method is better.
    }

    /// Establishes a connection to the server using the provided transport.
    /// - Parameter transport: The transport mechanism to use.
    public func connect(transport: MCPTransport) async throws {
        guard connectionState == .disconnected || connectionState == .disconnecting else {
            print("MCPClient: Already connected or in the process of connecting/disconnecting.")
            throw MCPClientError.alreadyConnected // Or handle as appropriate
        }

        self.transport = transport
        self.connectionState = .connecting

        do {
            try await transport.connect()
            self.connectionState = .connected
            startListeningToTransport()
            print("MCPClient: Connected and listening for messages.")
        } catch {
            self.connectionState = .disconnected
            self.transport = nil
            print("MCPClient: Connection failed - \(error)")
            throw error
        }
    }

    /// Disconnects from the server and cleans up resources.
    public func disconnect() async {
        guard connectionState == .connected || connectionState == .connecting else {
            print("MCPClient: Not connected.")
            return
        }

        self.connectionState = .disconnecting
        stopListeningToTransport()
        transport?.disconnect() // Assuming transport has a disconnect method
        self.transport = nil
        self.pendingRequests.forEach { _, value in
            value.continuation.resume(throwing: MCPClientError.transportError(CocoaError(.userCancelled)))
        }
        self.pendingRequests.removeAll()
        self.connectionState = .disconnected
        print("MCPClient: Disconnected.")
    }

    // MARK: - API Layer (Public Methods)

    /// Initializes the JSON-RPC session with the server.
    /// The client sends its capabilities, and the server responds with its own.
    /// - Parameter clientCapabilities: The capabilities of this client.
    /// - Returns: The capabilities of the server.
    public func initialize(clientCapabilities: ClientCapabilities) async throws -> ServerCapabilities {
        let params = InitializeRequestParams(capabilities: clientCapabilities)
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
        guard connectionState == .connected, let currentTransport = transport else {
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
                    try await currentTransport.send(data: encodedRequestData)
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
    private func startListeningToTransport() {
        guard let currentTransport = self.transport else {
            print("MCPClient Error: Transport not available to start listening.")
            // Optionally, set state to disconnected or throw
            return
        }

        // Ensure any existing task is cancelled before starting a new one.
        messageProcessingTask?.cancel()

        messageProcessingTask = Task {
            print("MCPClient: Message processing task started. Awaiting messages from transport...")
            do {
                for try await data in currentTransport.incomingMessages {
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
                    await self.disconnect() // Example: trigger disconnect
                }
            }
            print("MCPClient: Message processing task finished.")
        }
    }

    /// Stops the task that listens for incoming messages.
    private func stopListeningToTransport() {
        messageProcessingTask?.cancel()
        messageProcessingTask = nil
        print("MCPClient: Message processing task stopped.")
    }

    /// Handles incoming raw data from the transport, parsing and dispatching it.
    /// This method is called sequentially by the `messageProcessingTask`.
    private func handleIncomingData(_ data: Data) async {
        // Attempt to decode the base message to determine its type
        let baseMessage: BaseMessage
        do {
            baseMessage = try JSONDecoder().decode(BaseMessage.self, from: data)
        } catch {
            print("MCPClient: Failed to decode base message structure - \(error). Data: \(String(data: data, encoding: .utf8) ?? "Invalid UTF-8")")
            // This could be a malformed message; decide how to handle (e.g., log and ignore)
            return
        }

        // Case 1: Response to a previous request (has ID, no method)
        if let id = baseMessage.id, baseMessage.method == nil {
            await handleResponse(id: id, data: data)
        }
        // Case 2: Notification from server (has method, no ID)
        else if let method = baseMessage.method, baseMessage.id == nil {
            await handleNotification(method: method, data: data)
        }
        // Case 3: Request from server (has ID and method)
        else if let id = baseMessage.id, let method = baseMessage.method {
            await handleServerRequest(id: id, method: method, data: data)
        }
        // Case 4: Unknown message structure
        else {
            print("MCPClient: Received message with unknown structure. ID: \(baseMessage.id ?? "nil"), Method: \(baseMessage.method ?? "nil")")
            // This indicates a non-compliant message or a parsing issue not caught by BaseMessage decoding.
        }
    }

    /// Handles a JSON-RPC response message.
    private func handleResponse(id: String, data: Data) async {
        guard let pending = pendingRequests.removeValue(forKey: id) else {
            print("MCPClient: Received unsolicited response for ID \(id). Ignoring.")
            // It's important not to throw here if the continuation is not found,
            // as this method is part of the general message handling loop.
            // Instead, log and potentially track unsolicited responses if needed.
            return
        }

        do {
            // Decode the full response, using AnyCodable for result and JSONRPCErrorObject for error
            let response = try JSONDecoder().decode(JSONRPCResponse<AnyCodable, JSONRPCErrorObject>.self, from: data)

            if let errorObject = response.error {
                print("MCPClient: Received error for request \(id): \(errorObject)")
                pending.continuation.resume(throwing: MCPClientError.jsonRpcError(errorObject))
            } else if let anyCodableResult = response.result {
                // Attempt to cast/decode AnyCodable to the specific expected ResultType
                do {
                    let typedResult = try anyCodableResult.decode(to: pending.responseType)
                    pending.continuation.resume(returning: typedResult)
                } catch {
                    print("MCPClient: Failed to decode result for request \(id) to type \(pending.responseType) - \(error)")
                    pending.continuation.resume(throwing: MCPClientError.responseDecodingFailed(error))
                }
            } else {
                // This case should ideally not happen if the response is well-formed (either result or error must be present)
                print("MCPClient: Response for request \(id) had neither result nor error.")
                pending.continuation.resume(throwing: MCPClientError.unexpectedMessageFormat)
            }
        } catch {
            print("MCPClient: Failed to decode JSONRPCResponse for ID \(id) - \(error)")
            pending.continuation.resume(throwing: MCPClientError.responseDecodingFailed(error))
        }
    }

    /// Handles a JSON-RPC notification message.
    private func handleNotification(method: String, data: Data) async {
        print("MCPClient: Received notification: \(method). Data: \(String(data: data, encoding: .utf8) ?? "")")
        // TODO: Implement full notification handling
        // 1. Define a generic JSONRPCNotification<Params: Decodable> struct.
        // 2. Decode `data` into this struct.
        // 3. Route based on `method` to specific handlers or delegates.
        // Example:
        // switch method {
        // case "textDocument/publishDiagnostics":
        //     if let params = try? JSONDecoder().decode(PublishDiagnosticsParams.self, from: data) {
        //         delegate?.didReceiveDiagnostics(params)
        //     }
        // default:
        //     print("Unhandled notification: \(method)")
        // }
    }

    /// Handles a JSON-RPC request message initiated by the server.
    private func handleServerRequest(id: String, method: String, data: Data) async {
        print("MCPClient: Received server request: \(method) (id: \(id)). Data: \(String(data: data, encoding: .utf8) ?? "")")
        // TODO: Implement full server-initiated request handling
        // 1. Define a generic JSONRPCRequest<Params: Decodable> struct for incoming requests.
        // 2. Decode `data` into this struct.
        // 3. Route based on `method` to specific handlers.
        // 4. The handler must eventually send a JSONRPCResponse (result or error) back to the server using `transport.send()`.
        // Example:
        // switch method {
        // case "workspace/applyEdit":
        //     // ... process and respond
        // default:
        //     // Send back a methodNotFound error
        //     let error = JSONRPCErrorObject(code: -32601, message: "Method not found", data: nil)
        //     let response = JSONRPCResponse<Never, JSONRPCErrorObject>(id: id, result: nil, error: error) // Assuming Never for ResultType
        //     // try? await transport?.send(data: JSONEncoder().encode(response))
        // }
        let error = JSONRPCErrorObject(code: -32601, message: "Server-initiated requests not yet supported by client", data: nil)
        let response = JSONRPCResponse<EmptyCodable, JSONRPCErrorObject>(id: id, result: nil, error: error) // Using EmptyCodable for no result
        do {
            let responseData = try JSONEncoder().encode(response)
            try await transport?.send(data: responseData)
        } catch {
            print("MCPClient: Failed to send error response for server request \(id): \(error)")
        }
    }
}

// MARK: - Helper Schema Types (Assumed to be defined elsewhere, or here if simple)

public struct StdioServerConfiguration: Codable { /* ... */ }
public struct ClientCapabilities: Codable { /* ... */ }
public struct ServerCapabilities: Codable { /* e.g., version: String, otherCaps: ... */ }
public struct Resource: Codable { /* e.g., id: String, name: String, type: String */ }
public struct Prompt: Codable { /* e.g., id: String, text: String, metadata: [String: AnyCodable]? */ }
public struct CallToolResult: Codable { /* e.g., output: AnyCodable, error: String? */ }

// For listResources
public struct ListResourcesResult: Codable { public let resources: [Resource] }

// For getPrompt
public struct GetPromptParams: Codable { public let id: String }
public struct GetPromptResult: Codable { public let prompt: Prompt }

// For initialize
public struct InitializeRequestParams: Codable { public let capabilities: ClientCapabilities }
// ServerCapabilities is directly returned for initialize

// For callTool
public struct CallToolParams: Codable { 
    public let name: String
    public let arguments: [String: AnyCodable]?
}
// CallToolResult is directly returned for callTool

// For readResource (New)
public struct ReadResourceParams: Codable {
    public let id: String
    public let version: String?
}
public struct ResourceContent: Codable { /* e.g., content: String, format: String */ }

// For methods that take no parameters
private struct EmptyParams: Encodable {}

public struct AnyCodable: Codable { // Basic implementation for example
    private let value: Any

    public init<T>(_ value: T?) {
        self.value = value ?? ()
    }

    public func decode<T: Decodable>(to type: T.Type) throws -> T {
        let data = try JSONEncoder().encode(self) // Re-encode to then decode specifically
        return try JSONDecoder().decode(T.self, from: data)
    }
    // Implement Encodable and Decodable conformance
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        if let encodable = value as? Encodable {
            try encodable.encode(to: encoder) // This won't work directly as `Encodable` has `Self` requirements
                                            // A proper AnyCodable implementation is more complex, often using type erasure or specific encoding strategies.
                                            // For simplicity here, we assume it can be re-encoded if it was originally Decodable.
            // This is a placeholder for a real AnyCodable implementation.
            // A common approach is to encode to a dictionary or array if possible, or to Data.
            // For now, let's assume a simple path if it's a common JSON type.
            switch value {
            case let val as String: try container.encode(val)
            case let val as Int: try container.encode(val)
            case let val as Double: try container.encode(val)
            case let val as Bool: try container.encode(val)
            case let val as [Any?]: try container.encode(val.map { AnyCodable($0) })
            case let val as [String: Any?]: try container.encode(val.mapValues { AnyCodable($0) })
            default:
                // Attempt to convert to Data then to a generic structure if possible, or throw
                // This part is highly dependent on the actual AnyCodable implementation used.
                // For this example, we'll throw if not a simple type.
                throw EncodingError.invalidValue(value, EncodingError.Context(codingPath: [], debugDescription: "AnyCodable can only encode basic JSON types or requires a more robust implementation."))
            }
        } else {
            try container.encodeNil()
        }
    }
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil() { self.value = () } 
        else if let bool = try? container.decode(Bool.self) { self.value = bool }
        else if let int = try? container.decode(Int.self) { self.value = int }
        else if let double = try? container.decode(Double.self) { self.value = double }
        else if let string = try? container.decode(String.self) { self.value = string }
        else if let array = try? container.decode([AnyCodable].self) { self.value = array.map { $0.value } }
        else if let dictionary = try? container.decode([String: AnyCodable].self) { self.value = dictionary.mapValues { $0.value } }
        else { throw DecodingError.dataCorruptedError(in: container, debugDescription: "AnyCodable value cannot be decoded") }
    }
}

public struct EmptyCodable: Codable {}

// Specific Request/Result types (examples)
public struct InitializeRequestParams: Codable { let capabilities: ClientCapabilities }
// ServerCapabilities is the result type for Initialize

public struct ListResourcesResult: Codable { let resources: [Resource] }

public struct GetPromptParams: Codable { let id: String }
public struct GetPromptResult: Codable { let prompt: Prompt }

public struct CallToolParams: Codable { 
    let name: String
    let arguments: [String: AnyCodable]?
}
public struct CallToolRequest: Codable { let params: CallToolParams }
// CallToolResult is the result type for CallTool

// For readResource (New)
public struct ReadResourceParams: Codable {
    let id: String
    let version: String?
}
public struct ResourceContent: Codable { /* e.g., content: String, format: String */ }

// Assume these are defined in your Schema module
// JSONRPCRequest, JSONRPCResponse, JSONRPCErrorObject are internal concerns handled by sendRequest/handleIncomingData
