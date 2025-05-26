# MCPClient

## Overview

The `MCPClient` actor is a core component of the MCPKit library, responsible for managing communication with an MCP (Model-Context Protocol) server. It handles:
- Establishing and maintaining a connection using a configurable transport mechanism (Stdio, SSE, or StreamableHTTP).
- JSON-RPC 2.0 session management, including the MCP initialization handshake and capability exchange.
- Sending standard MCP requests to the server (e.g., `listResources`, `getResource`, `callTool`).
- Processing responses and notifications received from the server.
- Handling server-initiated requests (e.g., `sampling/createMessage`).
- Optional automatic reconnection if the connection is lost.
- Optional heartbeat (ping) messages to keep the connection alive.

## Connection State

The `MCPClient` manages its connection state through the `ConnectionState` public enum:

```swift
public enum ConnectionState: Equatable {
    case disconnected(error: Error? = nil)
    case connecting
    case connected
    case disconnecting
    case reconnecting(attempt: Int, nextAttemptIn: TimeInterval)
}
```

- **`disconnected(error: Error?)`**: The client is not connected. An optional `error` parameter may indicate why the disconnection occurred.
- **`connecting`**: The client is in the process of establishing a connection to the server, including the transport layer connection and the MCP handshake.
- **`connected`**: The client has successfully connected to the server and completed the MCP handshake.
- **`disconnecting`**: The client is in the process of gracefully disconnecting from the server.
- **`reconnecting(attempt: Int, nextAttemptIn: TimeInterval)`**: The client has lost its connection and is attempting to reconnect. `attempt` indicates the current retry number, and `nextAttemptIn` specifies the delay before the next attempt.

You can observe changes to the connection state by accessing the `connectionState` property of the `MCPClient` instance.

## Key Public Properties

- **`connectionState: ConnectionState`**: (Read-only) Provides the current connection state of the client. This property is updated automatically as the client transitions between states.
- **`transportConfiguration: MCPTransportConfiguration`**: (Read-only) The configuration that was used to initialize the client, specifying the transport type (e.g., `.stdio`, `.sse`, `.streamableHTTP`) and its parameters.
- **`serverCapabilities: ServerCapabilities?`**: (Read-only) Contains the capabilities reported by the MCP server. This property is populated after a successful MCP handshake (which occurs during the `connect()` process) and will be `nil` until then.

## Public Callbacks for Server-Initiated Messages

`MCPClient` allows you to define closures to handle messages initiated by the server:

- **`onLoggingMessage: ((LoggingMessageNotification.Params) -> Void)?`**: Assign a closure to this property to handle `logging/message` notifications sent by the server. The closure receives the parameters of the notification.
- **`onResourceUpdate: ((ResourceUpdatedNotification.Params) -> Void)?`**: Assign a closure to handle `resources/updated` notifications. This is typically used to inform the client that a resource it might be interested in has changed.
- **`onSamplingCreateMessage: ((CreateMessageRequest.Params) async throws -> CreateMessageResult)?`**: Assign an asynchronous, throwing closure to handle `sampling/createMessage` requests sent by the server. Your closure must process the request and return a `CreateMessageResult` or throw an error, which will then be sent back to the server as a JSON-RPC response.

## Initialization

To create an instance of `MCPClient`, you use its initializer:

```swift
public init(
    transportConfiguration: MCPTransportConfiguration,
    clientCapabilities: ClientCapabilities,
    heartbeatInterval: TimeInterval? = nil,
    enableAutoReconnect: Bool = true,
    maxReconnectAttempts: Int = 5,
    baseReconnectDelay: TimeInterval = 1.0,
    maxReconnectDelay: TimeInterval = 30.0,
    reconnectDelayJitterFactor: Double = 0.25
) throws
```

**Parameters:**
- `transportConfiguration`: An `MCPTransportConfiguration` enum value specifying the transport mechanism and its required parameters (e.g., URL for SSE, command path for Stdio).
- `clientCapabilities`: A `ClientCapabilities` struct detailing the capabilities of this client, which will be sent to the server during the MCP handshake.
- `heartbeatInterval`: (Optional) The interval in seconds for sending `mcp/ping` messages to the server to keep the connection alive. Defaults to `nil` (heartbeat disabled).
- `enableAutoReconnect`: (Optional) A boolean indicating whether the client should automatically attempt to reconnect if the connection is lost. Defaults to `true`.
- `maxReconnectAttempts`: (Optional) The maximum number of reconnection attempts if `enableAutoReconnect` is true. Defaults to `5`. A value of `0` means infinite attempts.
- `baseReconnectDelay`: (Optional) The initial delay (in seconds) before the first reconnection attempt. Defaults to `1.0`.
- `maxReconnectDelay`: (Optional) The maximum delay (in seconds) between reconnection attempts. Defaults to `30.0`.
- `reconnectDelayJitterFactor`: (Optional) A factor (0.0 to 1.0) to introduce randomness (jitter) in reconnection delays. This helps prevent multiple clients from retrying simultaneously. Defaults to `0.25`.

## Core Public Methods

### Managing the Connection

- **`connect()`**
  ```swift
  public func connect() async throws
  ```
  Asynchronously attempts to establish a connection to the MCP server. This process involves:
  1. Setting the client state to `.connecting`.
  2. Establishing the underlying transport connection (e.g., opening a Stdio pipe, connecting an SSE stream).
  3. Performing the MCP handshake by sending an `initialize` request with the client's capabilities and processing the server's response.
  4. If successful, the state transitions to `.connected`, and `serverCapabilities` is populated.
  5. If any step fails, an error is thrown, and the state typically transitions to `.disconnected(error: ...)`.

  This method should be called to start communication. It will cancel any ongoing automatic reconnection attempts if called manually.

- **`disconnect(triggeredByError: Error? = nil)`**
  ```swift
  public func disconnect(triggeredByError: Error? = nil) async
  ```
  Asynchronously disconnects the client from the server. This involves:
  1. Setting the client state to `.disconnecting`.
  2. Sending a `shutdown` request to the server (if the MCP handshake was completed).
  3. Closing the transport connection.
  4. Cancelling internal tasks (like heartbeats or message processing).
  5. Setting the client state to `.disconnected(error: triggeredByError)`.

  - `triggeredByError`: An optional `Error` that can be passed to indicate if the disconnection was due to an issue.

### Standard MCP Requests

These methods allow the client to send standard MCP requests to the server. They generally require the client to be in the `.connected` state. Calling them in other states will result in an error.

- **`listResources(params: ListResourcesRequest.Params)`**
  ```swift
  public func listResources(params: ListResourcesRequest.Params) async throws -> ListResourcesResult
  ```
  Sends a `resources/list` request to the server to retrieve a list of available resources.
  - `params`: An instance of `ListResourcesRequest.Params`, which may include a `cursor` for pagination or other filtering criteria.
  - Returns: A `ListResourcesResult` containing the list of `ResourceDescriptor` objects and an optional `nextCursor` string for pagination.

- **`getResource(params: GetResourceRequest.Params)`**
  ```swift
  public func getResource(params: GetResourceRequest.Params) async throws -> GetResourceResult
  ```
  Sends a `resources/get` request to the server to fetch the content or details of a specific resource.
  - `params`: An instance of `GetResourceRequest.Params`, primarily containing the `uri` of the resource to retrieve.
  - Returns: A `GetResourceResult` containing the `Resource` data.

- **`callTool(params: CallToolRequest.Params)`**
  ```swift
  public func callTool(params: CallToolRequest.Params) async throws -> CallToolResult
  ```
  Sends a `tool/call` request to the server to invoke a specific tool with given inputs.
  - `params`: An instance of `CallToolRequest.Params`, including `toolName`, `toolInput`, and a unique `requestId` for this tool call.
  - Returns: A `CallToolResult` containing the `toolOutput` from the executed tool.

- **`respondToToolCall(params: RespondToToolCallRequest.Params)`**
  ```swift
  public func respondToToolCall(params: RespondToToolCallRequest.Params) async throws -> RespondToToolCallResult
  ```
  Sends a `tool/respond` request. This method is used when the *client itself* is acting as a tool provider and needs to send the result of a tool execution that was initiated by the server (e.g., via a `tool/call` request *from* the server *to* the client).
  - `params`: An instance of `RespondToToolCallRequest.Params`, including the original `requestId` (from the server's `tool/call` request) and the `toolOutput`.
  - Returns: A `RespondToToolCallResult`, typically confirming the server received the response.

## Automatic Reconnection

If `enableAutoReconnect` is `true` during initialization (the default), `MCPClient` will automatically attempt to re-establish the connection if it's unexpectedly lost (e.g., network issue, server restart). The reconnection strategy uses an exponential backoff mechanism with jitter to avoid overwhelming the server. This behavior is configured by:
- `maxReconnectAttempts`
- `baseReconnectDelay`
- `maxReconnectDelay`
- `reconnectDelayJitterFactor`

During reconnection attempts, the client's state will be `.reconnecting(attempt:nextAttemptIn:)`.

## Heartbeat (Ping/Pong)

If a `heartbeatInterval` is specified during initialization, `MCPClient` will periodically send `mcp/ping` requests to the server when the connection is active (`.connected` state) and the transport is persistent (SSE or StreamableHTTP). The server is expected to reply with an `mcp/pong` response. This helps:
- Keep the connection alive through intermediaries (like load balancers or proxies) that might close idle connections.
- Detect a dead connection more quickly than relying on TCP timeouts.

Failure to receive a pong response within a certain timeframe can trigger a disconnection and, if enabled, a reconnection attempt.

## Error Handling

Most asynchronous methods in `MCPClient` that involve communication (e.g., `connect()`, `listResources()`, etc.) are marked `throws`. They can throw errors for various reasons, such as:
- Network issues.
- Transport-specific errors.
- JSON serialization or deserialization failures.
- Server-reported errors (via JSON-RPC error objects in responses).
- Client-side validation errors (e.g., attempting an operation in an invalid state).

It's important to handle these potential errors using `do-catch` blocks. The `connectionState` property (specifically `.disconnected(error: ...)` or `.reconnecting(...)` after an error) also provides insight into connection-related failures.
