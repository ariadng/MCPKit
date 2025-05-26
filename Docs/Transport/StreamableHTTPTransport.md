# StreamableHTTPTransport

`StreamableHTTPTransport` is a component of `MCPKit` designed to handle communication with an MCP (Model-Context Protocol) server over a persistent HTTP connection that streams newline-delimited JSON (NDJSON) objects. This transport is suitable for scenarios where the server continuously sends discrete JSON messages over a single HTTP request (e.g., using GET or POST).

## Key Features

-   **HTTP Streaming (NDJSON)**: Connects to an HTTP endpoint and processes a stream of newline-delimited JSON objects. It expects the server to set `Content-Type` appropriately (e.g., `application/x-ndjson`) and for the client to `Accept` it.
-   **Configurable HTTP Method**: Can be configured to use different HTTP methods (e.g., `GET`, `POST`) for establishing the stream, although `GET` is typical for receiving streams.
-   **Asynchronous Operations**: Built with Swift's `async/await` for non-blocking network I/O.
-   **Stream-based Data Handling**:
    -   `incomingMessages: AsyncStream<Data>`: Yields `Data` objects, where each `Data` object represents a single, complete JSON message (one line from the NDJSON stream).
    -   `stateStream: AsyncStream<TransportConnectionState>`: Provides real-time updates on the connection status (e.g., `.connecting`, `.connected`, `.disconnected`).
-   **Task Management with `ActorTaskWrapper`**: Uses an internal `ActorTaskWrapper` class to manage the lifecycle of the network processing task. This ensures that only the most current task can modify the transport's state, preventing race conditions if `connect()` is called multiple times.
-   **Error Handling**: Defines a `StreamableHTTPError` enum for specific HTTP streaming-related issues.
-   **Actor-based Thread Safety**: Implemented as a Swift `actor` for thread-safe state management.

## Initialization

To use `StreamableHTTPTransport`, initialize it with the server's streaming endpoint URL. You can also specify the HTTP method and a custom `URLSession`.

```swift
let streamURL = URL(string: "https://example.com/mcp-stream")!
let transport = StreamableHTTPTransport(
    serverURL: streamURL,
    httpMethod: "GET",         // Default: "GET"
    urlSession: .shared      // Default: URLSession.shared
)
```

## Core `MCPTransport` Protocol Implementation

-   **`connect() async throws`**: 
    -   If an existing processing task (via `currentActorTaskWrapper`) is active, it's cancelled.
    -   Updates state to `.connecting`.
    -   Creates a new `ActorTaskWrapper` and a new `Task` that calls `establishAndProcessHTTPStream(taskWrapper:)`.
    -   The `ActorTaskWrapper` holds this new task, and `currentActorTaskWrapper` is updated to this new wrapper. This pattern ensures that only the operations initiated by the most recent `connect()` call can affect the transport's state.

-   **`send(_ data: Data) async throws`**: 
    -   Throws `StreamableHTTPError.sendingNotSupportedOnPrimaryStream`. This transport is designed for receiving a stream of messages from the server on the primary connection. Sending client-initiated requests that expect a streamed response might require a different mechanism or a separate, non-streaming HTTP request/response utility.

-   **`disconnect() async`**: 
    -   Retrieves the `currentActorTaskWrapper` and then immediately nils out the actor's reference to it.
    -   Cancels the task held by the retrieved wrapper.
    -   If a task was active (i.e., `wrapperToCancel` was not nil) and the `stateStream` is not yet finished, yields `.disconnected(error: nil)`.
    -   Ensures `incomingMessagesContinuation` and `stateStreamContinuation` are finished exactly once using `hasFinishedIncomingMessagesStream` and `hasFinishedStateStream` flags.

## Streams

-   **`public nonisolated let incomingMessages: AsyncStream<Data>`**: 
    -   Provides an asynchronous stream of `Data` objects.
    -   Each `Data` object represents a single line (a complete JSON message) received from the NDJSON stream.

-   **`public nonisolated let stateStream: AsyncStream<TransportConnectionState>`**: 
    -   Provides an asynchronous stream of `TransportConnectionState` enum values.
    -   Allows observers to monitor the connection lifecycle: `.disconnected(error: Error?)`, `.connecting`, `.connected`.

## HTTP Streaming Specific Behavior

-   **`establishAndProcessHTTPStream(taskWrapper: ActorTaskWrapper) async throws` (Private Method)**:
    -   Constructs a `URLRequest` with the configured `httpMethod` and sets `Accept: application/x-ndjson` header.
    -   **Task Identity Check**: Before making the network request and after receiving the initial response, it checks if `self.currentActorTaskWrapper === taskWrapper`. If not, it means a newer `connect()` call has been made, so this (now stale) task aborts by throwing `CancellationError`.
    -   Uses `urlSession.bytes(for: request)` to get an `AsyncThrowingStream<URLSession.AsyncBytes, Error>`.
    -   Validates the `HTTPURLResponse`: expects a status code in the 200-299 range. Non-successful status codes throw `StreamableHTTPError.unexpectedHTTPStatus`.
    -   If the HTTP connection is successful and the task is still the active one, updates state to `.connected`.
    -   Iterates through `asyncBytes.lines`:
        -   Performs `Task.isCancelled` and `self.currentActorTaskWrapper === taskWrapper` checks on each iteration to allow for timely termination.
        -   Converts each line to `Data` and yields it to `incomingMessagesContinuation` if not empty.
    -   If the stream ends normally (iteration completes), throws `StreamableHTTPError.streamEndedNormally` to signal completion to the `catch` block.
    -   **Error Handling within Task**: 
        -   If an error occurs and `self.currentActorTaskWrapper === taskWrapper` (i.e., this task is still the active one), it yields `.disconnected(error: finalError)` to the `stateStream`, clears `currentActorTaskWrapper`, and re-throws the error.
        -   If an error occurs for a stale task, it's logged, and the error is not propagated to the `stateStream` to avoid interfering with a newer, active connection.

## `ActorTaskWrapper` Pattern

This private inner class is crucial for managing concurrency correctly. When `connect()` is called, it might be called again before the previous connection attempt's asynchronous operations (like `urlSession.bytes`) complete. The `ActorTaskWrapper` helps ensure that only the logic associated with the *latest* `connect()` call can modify the actor's state (like `currentActorTaskWrapper` or yielding to streams).

Each `Task` created by `connect()` is associated with a unique `ActorTaskWrapper` instance. The processing method (`establishAndProcessHTTPStream`) receives this wrapper. Before critical operations or in completion/error handlers, it compares its captured wrapper instance (by identity `===`) with the actor's `currentActorTaskWrapper`. If they don't match, the task knows it's stale and should not proceed with state modifications.

## Error Handling

`StreamableHTTPTransport` uses the `StreamableHTTPError` enum. Key cases:

-   `.invalidURL`: The provided server URL is malformed.
-   `.sendingNotSupportedOnPrimaryStream`: `send()` method was called.
-   `.unexpectedHTTPStatus(statusCode: Int, responseBody: String?)`: The server responded with an HTTP status outside the 200-299 range.
-   `.streamEndedNormally`: A signal that the HTTP stream finished without an operational error (used internally).
-   `.taskNotRunning`: (Currently defined but might be less used if `ActorTaskWrapper` handles most stale task scenarios).

`URLError` (e.g., `.badServerResponse`) can also be thrown by `URLSession` operations.

## Example Usage (Conceptual)

```swift
let ndjsonStreamURL = URL(string: "https://your.server.com/api/ndjson-feed")!
let transport = StreamableHTTPTransport(serverURL: ndjsonStreamURL, httpMethod: "GET")

// Observe state changes
Task {
    for await state in transport.stateStream {
        print("StreamableHTTP Transport state: \(state)")
        if case .disconnected(let error) = state, let error = error {
            // Note: streamEndedNormally might appear as the error here if the stream finishes cleanly.
            print("Disconnected with error/reason: \(error.localizedDescription)")
        }
    }
    print("StreamableHTTP state stream finished.")
}

// Observe incoming messages
Task {
    for await data in transport.incomingMessages {
        if let message = String(data: data, encoding: .utf8) {
            print("Received NDJSON message: \(message)")
            // Process the NDJSON message (e.g., decode JSON)
        }
    }
    print("StreamableHTTP incoming messages stream finished.")
}

// Connect
print("Attempting to connect to NDJSON stream...")
do {
    try await transport.connect()
} catch {
    // This catch is for errors thrown directly by connect() itself, if any.
    // Most connection lifecycle errors are reported via stateStream.
    print("Error calling connect: \(error.localizedDescription)")
}

// To stop and clean up
// await transport.disconnect()
