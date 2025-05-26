# MCPClient

## 1. Overview

The `MCPClient` is a Swift `actor` designed to facilitate communication with a Model Context Protocol (MCP) v1 server. It provides a high-level, asynchronous, and thread-safe API for Swift applications to interact with MCP servers, abstracting the complexities of JSON-RPC 2.0 session management, message encoding/decoding, and concurrency.

It is a core component of the `MCPKit` library, enabling developers to easily integrate MCP functionalities into their applications.

## 2. Key Features

*   **Actor-Based Concurrency**: Implemented as a Swift `actor`, `MCPClient` ensures thread-safe access to its internal state and operations, simplifying concurrent programming.
*   **Connection Management**: Provides methods to establish (`connect`) and terminate (`disconnect`) connections to an MCP server via a configurable transport layer.
*   **JSON-RPC 2.0 Session Management**: Handles the underlying JSON-RPC 2.0 protocol, including:
    *   Unique request ID generation.
    *   Tracking pending requests and matching responses to their original requests.
    *   Parsing incoming messages to differentiate between responses, notifications, and server-initiated requests (though full handling for the latter two is pending).
*   **Strongly-Typed API**: Exposes public methods that use concrete Swift types defined in the MCP schema (assumed to be in `ariadng/MCPKit/Sources/Schema`) for parameters and return values. This offers compile-time safety and ease of use.
*   **Abstraction**: Hides the low-level details of JSON-RPC message construction, serialization, and deserialization from the API user.
*   **Error Handling**: Defines a comprehensive `MCPClientError` enum for reporting issues encountered during client operations.

## 3. Initialization

An `MCPClient` instance is initialized with an optional configuration object:

```swift
import MCPClient
import MCPSchema // Assuming schema types are in this module

// If StdioServerConfiguration is relevant for your transport
let config = StdioServerConfiguration(/*...details...* /)
let client = MCPClient(configuration: config)

// Or without specific configuration if the transport handles it
let client = MCPClient()
```

## 4. Connection Management

The client requires an `MCPTransport` compliant object to manage the actual data transmission.

### 4.1. Connecting

To establish a connection:

```swift
// Assume 'myTransport' is an instance conforming to MCPTransport
// e.g., StdioTransport, WebSocketTransport (to be implemented in Phase 2)
do {
    try await client.connect(transport: myTransport)
    print("Successfully connected to MCP server.")
} catch {
    print("Failed to connect: \(error)")
}
```

### 4.2. Disconnecting

To close the connection:

```swift
await client.disconnect()
print("Disconnected from MCP server.")
```

The `connectionState` property can be observed to know the current status:

```swift
let currentState = await client.connectionState
// currentState can be .disconnected, .connecting, .connected, .disconnecting
```

## 5. Public API Methods

All public API methods are `async` and `throws`, returning specific schema types.

*   **`initialize(clientCapabilities: ClientCapabilities) async throws -> ServerCapabilities`**
    *   Initializes the JSON-RPC session with the server.
    *   Sends client capabilities and receives server capabilities.
    *   **Parameters**:
        *   `clientCapabilities: ClientCapabilities`: The capabilities of this client.
    *   **Returns**: `ServerCapabilities` reported by the server.
    *   **Throws**: `MCPClientError` on failure.

*   **`listResources() async throws -> [Resource]`**
    *   Lists available resources on the server.
    *   **Returns**: An array of `Resource` objects.
    *   **Throws**: `MCPClientError` on failure.

*   **`getPrompt(id: String) async throws -> Prompt`**
    *   Retrieves a specific prompt by its ID.
    *   **Parameters**:
        *   `id: String`: The ID of the prompt to retrieve.
    *   **Returns**: The `Prompt` object.
    *   **Throws**: `MCPClientError` on failure.

*   **`readResource(id: String, version: String?) async throws -> ResourceContent`**
    *   Reads the content of a specific resource, optionally at a specific version.
    *   **Parameters**:
        *   `id: String`: The ID of the resource to read.
        *   `version: String?`: Optional version string for the resource.
    *   **Returns**: `ResourceContent` containing the resource's data.
    *   **Throws**: `MCPClientError` on failure.

*   **`callTool(name: String, arguments: [String: AnyCodable]?) async throws -> CallToolResult`**
    *   Calls a server-defined tool.
    *   **Parameters**:
        *   `name: String`: The name of the tool to call.
        *   `arguments: [String: AnyCodable]?`: Optional arguments for the tool.
    *   **Returns**: `CallToolResult` containing the output of the tool.
    *   **Throws**: `MCPClientError` on failure.

## 6. Error Handling

Operations within `MCPClient` can throw errors defined in the `MCPClientError` enum. These errors provide specific information about issues encountered, such as connection problems, encoding/decoding failures, or server-reported errors.

Example `MCPClientError` cases:
*   `.notConnected`
*   `.requestEncodingFailed(Error)`
*   `.responseDecodingFailed(Error)`
*   `.transportError(Error)`
*   `.unsolicitedResponse(id: String)`
*   `.serverError(code: Int, message: String, data: AnyCodable?)`
*   `.jsonRpcError(JSONRPCErrorObject)`

Always use `do-catch` blocks when calling `MCPClient` methods:

```swift
do {
    let capabilities = try await client.initialize(clientCapabilities: myCaps)
    // ... work with capabilities ...
} catch let error as MCPClientError {
    // Handle specific MCPClientError
    print("MCPClient Error: \(error)")
} catch {
    // Handle other errors
    print("An unexpected error occurred: \(error)")
}
```

## 7. Conceptual Usage Example

```swift
import MCPClient
import MCPSchema // Assuming your schema types (ClientCapabilities, etc.) are here

// Assume MyTransport is a concrete implementation of MCPTransport
let client = MCPClient()
let transport = MyTransport(/* transport configuration */)

Task {
    do {
        // 1. Connect to the server
        try await client.connect(transport: transport)
        print("Connected!")

        // 2. Initialize the session
        let clientCaps = ClientCapabilities(/* define client's capabilities */)
        let serverCaps = try await client.initialize(clientCapabilities: clientCaps)
        print("Session initialized. Server capabilities: \(serverCaps)")

        // 3. List available resources
        let resources = try await client.listResources()
        print("Available resources: \(resources.map { $0.id })")

        // 4. Get a specific prompt (if a resource ID is a prompt ID)
        if let promptResource = resources.first(where: { $0.type == "prompt" }) { // Example condition
            let prompt = try await client.getPrompt(id: promptResource.id)
            print("Retrieved prompt: \(prompt.text)")
        }

        // 5. Call a tool
        let toolArgs: [String: AnyCodable] = ["query": AnyCodable("Hello world")]
        let toolResult = try await client.callTool(name: "echoTool", arguments: toolArgs)
        print("Tool result: \(toolResult.output)")

    } catch let mcpError as MCPClientError {
        print("An MCPClient error occurred: \(mcpError)")
    } catch {
        print("An unexpected error occurred: \(error)")
    }

    // 6. Disconnect when done
    await client.disconnect()
    print("Disconnected.")
}
```

## 8. Dependencies

*   **Swift Standard Library** (Foundation for basic types).
*   **MCPSchema Module**: Relies on Swift types generated from the MCP JSON schema (e.g., `ClientCapabilities`, `ServerCapabilities`, `Resource`, `Prompt`, `CallToolResult`, `AnyCodable`, etc.).
*   **MCPTransport (Protocol)**: Requires a concrete implementation of the `MCPTransport` protocol to handle the actual network communication. This protocol is to be defined and implemented as part of Phase 2 of `MCPKit` development.

This documentation provides a guide to using the `MCPClient`. As development progresses (e.g., full notification handling, concrete transport layers), this document will be updated.
