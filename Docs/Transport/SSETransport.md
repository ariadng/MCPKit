# SSETransport

`SSETransport` is a component of `MCPKit` that enables communication with an MCP (Model-Context Protocol) server using Server-Sent Events (SSE). SSE is a standard that allows a server to push data to a client asynchronously once an initial client connection has been established. This transport is suitable for scenarios where the server needs to send updates, notifications, or streamed data to the client.

## Key Features

-   **Server-Sent Events (SSE) Protocol**: Implements client-side handling of an SSE connection.
-   **HTTP-based**: Uses HTTP(S) GET requests to establish the event stream.
-   **Automatic Reconnection**: Handles connection drops and attempts to reconnect automatically, respecting SSE `retry` fields and employing an exponential backoff strategy.
-   **Last-Event-ID**: Supports sending the `Last-Event-ID` header on reconnection attempts to allow the server to resume the stream from the last known event.
-   **Asynchronous Operations**: Built with Swift's `async/await` for non-blocking network I/O.
-   **Stream-based Data Handling**:
    -   `incomingMessages: AsyncStream<Data>`: Yields `Data` objects, where each typically represents the `data` field of an SSE event (potentially multi-line `data` fields are concatenated).
    -   `stateStream: AsyncStream<TransportConnectionState>`: Provides real-time updates on the connection status (e.g., `.connecting`, `.connected`, `.disconnected`).
-   **Error Handling**: Defines an `SSETransportError` enum for specific SSE-related issues.
-   **Actor-based Thread Safety**: Implemented as a Swift `actor` for thread-safe state management.

## Initialization

To use `SSETransport`, initialize it with the server's SSE endpoint URL. You can also configure `URLSession`, maximum retry attempts, and the base retry delay.

```swift
let sseEndpointURL = URL(string: "https://example.com/mcp-events")!
let transport = SSETransport(
    serverURL: sseEndpointURL,
    maxRetryAttempts: 5,       // Default: 5
    baseRetryDelay: 1.0        // Default: 1.0 second
)
```

## Core `MCPTransport` Protocol Implementation

-   **`connect() async`**: 
    -   If an existing SSE processing task is active, it's cancelled.
    -   Resets retry attempts and custom retry delay.
    -   Updates state to `.connecting`.
    -   Starts a new `sseProcessingTask` (a `Task<Void, Never>`) which calls `establishAndProcessSSEConnection()`.

-   **`send(_ data: Data) async throws`**: 
    -   Throws `SSETransportError.sendingNotSupported`. SSE is primarily a server-to-client protocol; client-to-server messages are typically sent via separate HTTP requests, not over the SSE stream itself.

-   **`disconnect() async`**: 
    -   Sets `currentRetryAttempt` beyond `maxRetryAttempts` to prevent further retries.
    -   Cancels the `sseProcessingTask`.
    -   Calls `disconnectCleanup(with: nil)` to yield `.disconnected(error: nil)` and finish the streams if a task was active or streams were open.

## Streams

-   **`public nonisolated let incomingMessages: AsyncStream<Data>`**: 
    -   Provides an asynchronous stream of `Data` objects.
    -   Each `Data` object corresponds to the complete data payload of a received SSE event. Multi-line `data:` fields in an SSE event are concatenated before being yielded.

-   **`public nonisolated let stateStream: AsyncStream<TransportConnectionState>`**: 
    -   Provides an asynchronous stream of `TransportConnectionState` enum values.
    -   Allows observers to monitor the connection lifecycle: `.disconnected(error: Error?)`, `.connecting`, `.connected`.

## SSE Specific Behavior

-   **`establishAndProcessSSEConnection()` (Private Method)**:
    -   Constructs a `URLRequest` with `Accept: text/event-stream` and `Cache-Control: no-cache` headers.
    -   Includes `Last-Event-ID` header if `lastEventID` is set.
    -   Uses `urlSession.bytes(for: request)` to get an `AsyncThrowingStream<URLSession.AsyncBytes, Error>`.
    -   Handles HTTP status codes (expects 200 OK). Non-200 responses result in an error and trigger retry logic.
    -   Upon successful connection (HTTP 200), updates state to `.connected` and resets retry counters.
    -   Iterates through `asyncByteStream.lines` to parse SSE events:
        -   `id:<event_id>`: Updates `lastEventID`.
        -   `event:<event_name>`: Stores `eventName` (currently logged but not directly used to filter messages for `MCPTransport`).
        -   `data:<event_data>`: Appends to `currentEventDataLines`. Multiple `data` lines for a single event are concatenated.
        -   `retry:<milliseconds>`: Parses and sets `customRetryDelay` for subsequent reconnection attempts.
        -   Empty line: Signals the end of an event. The accumulated `currentEventDataLines` are joined, converted to `Data`, and yielded to `incomingMessagesContinuation`.
    -   Handles `CancellationError` (e.g., from `disconnect()` or task cancellation) by calling `disconnectCleanup(with: CancellationError())`.
    -   Other errors trigger retry logic: increments `currentRetryAttempt`, calculates delay (using `customRetryDelay` or exponential backoff), and schedules a new call to `establishAndProcessSSEConnection()` after the delay, unless `maxRetryAttempts` is reached.
    -   If `maxRetryAttempts` is reached, calls `disconnectCleanup(with: SSETransportError.maxRetriesReached)`.

-   **`disconnectCleanup(with error: Error?) async` (Private Method)**:
    -   Ensures that `stateStreamContinuation` and `incomingMessagesContinuation` are finished exactly once using `hasFinishedStateStream` and `hasFinishedIncomingMessagesStream` flags.
    -   If `stateStream` is not yet finished, yields `.disconnected(error: error)` and then finishes it.
    -   If `incomingMessagesStream` is not yet finished, it's finished.

## Error Handling

`SSETransport` uses the `SSETransportError` enum. Key cases:

-   `.invalidURL`: The provided server URL is malformed.
-   `.sendingNotSupported`: `send()` method was called.
-   `.unexpectedHTTPStatus(statusCode: Int, responseBody: String?)`: The server responded with an HTTP status other than 200 OK.
-   `.sseParsingError(description: String)`: An error occurred while parsing an SSE event field (e.g., non-integer `retry` value).
-   `.streamEnded`: The SSE stream ended from the server side without a specific error (can be normal).
-   `.maxRetriesReached`: Automatic reconnection attempts exceeded `maxRetryAttempts`.
-   `.connectionAttemptFailed(Error)`: Wraps an underlying error that occurred during a connection attempt.

## Example Usage (Conceptual)

```swift
let sseURL = URL(string: "https://your.server.com/events")!
let transport = SSETransport(serverURL: sseURL)

// Observe state changes
Task {
    for await state in transport.stateStream {
        print("SSE Transport state: \(state)")
        if case .disconnected(let error) = state, let error = error {
            print("Disconnected with error: \(error.localizedDescription)")
        }
    }
    print("SSE state stream finished.")
}

// Observe incoming messages
Task {
    for await data in transport.incomingMessages {
        if let message = String(data: data, encoding: .utf8) {
            print("Received SSE message: \(message)")
            // Process the message (e.g., decode JSON)
        }
    }
    print("SSE incoming messages stream finished.")
}

// Connect
print("Attempting to connect SSE...")
await transport.connect()

// To stop and clean up
// await transport.disconnect()
