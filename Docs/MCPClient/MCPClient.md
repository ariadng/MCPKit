# MCPClient

**File:** `Sources/MCPClient/MCPClient.swift`

The `MCPClient` is an actor responsible for managing communication with an MCP (Model-Context Protocol) server. It handles the full lifecycle of a client, including establishing connections, sending requests, processing responses, and managing notifications according to the JSON-RPC 2.0 specification.

## Overview

`MCPClient` provides a high-level asynchronous API for interacting with an MCP server. It abstracts the underlying transport mechanism (e.g., Stdio, SSE, Streamable HTTP) and manages session state, request IDs, and pending continuations for asynchronous operations.

## Properties

-   `connectionState: ConnectionState` (public private(set)): The current connection state of the client (e.g., `.disconnected`, `.connecting`, `.connected`).
-   `transportConfiguration: MCPTransportConfiguration` (public): The configuration specifying the transport to use and its parameters.
-   `serverCapabilities: ServerCapabilities?` (public private(set)): Capabilities reported by the server after successful initialization.

## Key Public Methods

-   `init(transportConfiguration: MCPTransportConfiguration, clientCapabilities: ClientCapabilities) throws`:
    Initializes a new MCPClient with a specific transport configuration and client capabilities.
-   `connect() async throws`:
    Establishes a connection to the server using the configured transport and starts listening for incoming messages.
-   `disconnect(reason: DisconnectReason = .normal) async`:
    Disconnects from the server and cleans up resources.
-   `initialize(clientCapabilities: ClientCapabilities) async throws -> ServerCapabilities`:
    Sends an `initialize` request to the server and returns the server's capabilities.
-   `listResources(cursor: String? = nil, limit: Int? = nil) async throws -> ListResourcesResult`:
    Requests a list of available resources from the server.
-   `getPrompt(id: String) async throws -> Prompt`:
    Retrieves a specific prompt by its ID.
-   `readResource(id: String, version: String?) async throws -> ResourceContent`:
    Reads the content of a specific resource.
-   `callTool(name: String, arguments: [String: AnyCodable]?) async throws -> CallToolResult`:
    Requests the server to call a specific tool with the given arguments.
-   `sendNotification(method: String, params: (some Encodable)?) async throws`:
    Sends a JSON-RPC notification to the server.
-   `handleServerRequest<Params: Decodable, ResultType: Encodable>(method: String, handler: @escaping (Params?) async throws -> ResultType) async`:
    Registers a handler for incoming server-initiated requests for a specific method.

## Handling Server-Initiated Messages

`MCPClient` allows the application to respond to messages initiated by the server (notifications and requests) by providing callback closures. These are public properties on the `MCPClient` instance.

### Server Notifications

The client can listen for specific notifications sent by the server:

*   **`onLoggingMessage: ((LoggingMessageNotification.Params) -> Void)?`**
    *   Called when the server sends a `logging/message` notification.
    *   The `LoggingMessageNotification.Params` type (defined in the `Schema` module) provides details like `level`, `logger`, and the log `data` (as `AnyCodable`).
    *   Example:
        ```swift
        client.onLoggingMessage = { params in
            print("Server Log [\(params.level)] (\(params.logger ?? "default")): \(params.data)")
            // Further processing of logParams.data if it's a structured object
        }
        ```

*   **`onResourceUpdate: ((ResourceUpdatedNotification.Params) -> Void)?`**
    *   Called when the server sends a `resources/updated` notification, typically after the client has subscribed to resource updates.
    *   The `ResourceUpdatedNotification.Params` type (defined in the `Schema` module) provides the `uri` of the updated resource.
    *   Example:
        ```swift
        client.onResourceUpdate = { params in
            print("Resource updated on server: \(params.uri)")
            // Logic to refresh or re-fetch the resource
        }
        ```

### Server-Initiated Requests

The client can handle requests initiated by the server:

*   **`onSamplingCreateMessage: ((CreateMessageRequest.Params) async throws -> CreateMessageResult)?`**
    *   Called when the server sends a `sampling/createMessage` request, asking the client to generate a message (e.g., using a local LLM).
    *   The handler receives `CreateMessageRequest.Params` (from the `Schema` module), which includes details like `messages` (context), `modelPreferences`, `maxTokens`, etc.
    *   The handler must be `async`, can `throw` an error (which will be sent back to the server as a JSON-RPC error), and must return a `CreateMessageResult` (also from the `Schema` module). The `CreateMessageResult` includes fields like `role`, `content` (as `SamplingMessage.MessageContent`), and `model`.
    *   If no handler is set, the `MCPClient` will automatically respond to the server with a "method not found" error.
    *   Example:
        ```swift
        client.onSamplingCreateMessage = { requestParams async throws -> CreateMessageResult in
            // Logic to process requestParams (e.g., select model, generate content)
            let generatedContent = // ... your message generation logic ...
            
            // Assuming SamplingMessage.MessageContent.text for simplicity
            let responseContent = SamplingMessage.MessageContent.text(generatedContent)
            
            return CreateMessageResult(
                role: .assistant, 
                content: responseContent,
                model: "my-client-llm-v1.0",
                stopReason: "completed"
            )
        }
        ```

To use these, assign your custom handler closure to the corresponding property on your `MCPClient` instance before or after connecting.

## Internal Structures

-   `PendingRequest`: A private struct holding a `CheckedContinuation` and the expected `Decodable.Type` for a pending request. This is used to manage asynchronous responses.
-   `BaseMessage`: A private struct used to decode the base fields (`id`, `method`) of an incoming JSON-RPC message to determine if it's a response, notification, or server request.

## Dependencies

-   `ConnectionState`: Enum representing the client's connection status. (Defined in `ConnectionState.swift`)
-   `MCPTransport`: Protocol for the underlying communication transport.
-   `MCPTransportConfiguration`: Enum specifying the transport configuration.
-   `ClientCapabilities`, `ServerCapabilities`, `Prompt`, `ResourceContent`, `CallToolResult`, `ListResourcesResult`, `AnyCodable`: Schema types for MCP messages (from `Sources/Schema/`).
-   `DisconnectReason`: Enum representing the reason for a disconnection. (Defined in `DisconnectReason.swift`)
-   `MCPClientError`: Enum for client-specific errors. (Defined in `MCPClientError.swift`)
