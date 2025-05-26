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
