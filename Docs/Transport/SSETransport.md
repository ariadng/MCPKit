# SSETransport

## Overview

This file implements the `SSETransport` class, an actor conforming to the `MCPTransport` protocol. It provides a transport mechanism for `MCPClient` using Server-Sent Events (SSE). SSE is a standard for enabling servers to push data to web clients over a single, long-lived HTTP connection. This transport is primarily designed for server-to-client communication.

## `SSETransportError` Enum

Defines errors specific to `SSETransport` operations.

### Definition
```swift
public enum SSETransportError: Error, LocalizedError {
    case invalidURL
    case sendingNotSupported
    case unexpectedHTTPStatus(statusCode: Int, responseBody: String?)
    case sseParsingError(description: String)
    case streamEnded // Indicates the SSE stream ended, possibly normally.
    case maxRetriesReached
    case connectionAttemptFailed(Error)
    // ... (localized descriptions)
}
```

### Cases
-   `invalidURL`: The provided server URL is invalid.
-   `sendingNotSupported`: Sending data is not supported by `SSETransport`.
-   `unexpectedHTTPStatus(statusCode: Int, responseBody: String?)`: Received an unexpected HTTP status code from the server.
-   `sseParsingError(description: String)`: An error occurred while parsing an SSE event.
-   `streamEnded`: The Server-Sent Events stream ended.
-   `maxRetriesReached`: Maximum reconnection attempts have been reached.
-   `connectionAttemptFailed(Error)`: Failed to establish the SSE connection, encapsulating the underlying error.

## `SSETransport` Actor

An actor that implements the `MCPTransport` protocol for Server-Sent Events.

### Definition
```swift
public final actor SSETransport: MCPTransport {
    // Properties
    private let serverURL: URL
    private let urlSession: URLSession
    private var sseProcessingTask: Task<Void, Never>?

    public nonisolated let incomingMessages: AsyncStream<Data>
    private var incomingMessagesContinuation: AsyncStream<Data>.Continuation?

    public nonisolated let stateStream: AsyncStream<TransportConnectionState>
    private var stateStreamContinuation: AsyncStream<TransportConnectionState>.Continuation?

    private var currentRetryAttempt: Int
    private let maxRetryAttempts: Int
    private let baseRetryDelay: TimeInterval
    private var lastEventID: String?
    private var customRetryDelay: TimeInterval?

    // Initializer, connect, send, disconnect, and private helper methods
}
```

### Key Properties
-   `serverURL: URL`: The URL of the SSE server.
-   `urlSession: URLSession`: The URLSession instance used for HTTP requests.
-   `sseProcessingTask: Task<Void, Never>?`: The background task responsible for managing the SSE connection and processing incoming events.
-   `incomingMessages: AsyncStream<Data>`: (from `MCPTransport`) Stream for yielding received message data.
-   `stateStream: AsyncStream<TransportConnectionState>`: (from `MCPTransport`) Stream for yielding connection state changes.
-   `currentRetryAttempt: Int`: Tracks the number of current reconnection attempts.
-   `maxRetryAttempts: Int`: Maximum number of times to attempt reconnection.
-   `baseRetryDelay: TimeInterval`: The base delay (in seconds) for exponential backoff during reconnection.
-   `lastEventID: String?`: The ID of the last successfully processed event, used for reconnection.
-   `customRetryDelay: TimeInterval?`: A server-suggested retry delay (from an SSE `retry` field).

### Initialization
```swift
public init(serverURL: URL, urlSession: URLSession = .shared, maxRetryAttempts: Int = 5, baseRetryDelay: TimeInterval = 1.0)
```
-   Initializes the transport with the server URL, an optional URL session, and parameters for reconnection logic.

### Core `MCPTransport` Methods
-   **`connect() async`**
    -   Initiates the connection to the SSE server.
    -   Cancels any existing processing task.
    -   Resets retry attempts and custom delays.
    -   Yields `.connecting` to `stateStream`.
    -   Starts a new `sseProcessingTask` to call `establishAndProcessSSEConnection()`.

-   **`send(_ data: Data) async throws`**
    -   Throws `SSETransportError.sendingNotSupported` as SSE is primarily for server-to-client data flow.

-   **`disconnect() async`**
    -   Manually disconnects the SSE stream.
    -   Sets `currentRetryAttempt` beyond `maxRetryAttempts` to prevent further retries.
    -   Cancels the `sseProcessingTask`.
    -   Calls `disconnectCleanup()` to finalize disconnection and clean up streams.

### Private Methods
-   **`disconnectCleanup(with error: Error?) async`**
    -   Centralized cleanup logic.
    -   Yields `.disconnected(error: error)` to `stateStream`.
    -   Finishes `incomingMessagesContinuation` and `stateStreamContinuation`.

-   **`establishAndProcessSSEConnection() async`**
    -   The main loop for connecting and processing SSE events.
    -   Constructs a `URLRequest` with appropriate headers (`Accept: text/event-stream`, `Cache-Control: no-cache`, `Last-Event-ID`).
    -   Uses `urlSession.bytes(for: request)` to get an `AsyncThrowingStream` of bytes.
    -   Handles HTTP response codes, expecting 200 OK.
    -   If successful, yields `.connected` to `stateStream` and resets retry counters.
    -   Iterates through `asyncByteStream.lines` to parse SSE events:
        -   Recognizes event fields like `id`, `data`, and `retry`.
        -   Concatenates multi-line `data` fields.
        -   When an empty line (event terminator) is encountered, the accumulated `data` is converted to `Data` and yielded to `incomingMessagesContinuation`.
        -   Updates `lastEventID` and `customRetryDelay` based on received fields.
    -   Handles errors (including `CancellationError`) by invoking `scheduleReconnection(with: error)`.

-   **`scheduleReconnection(with error: Error) async`**
    -   Called when `establishAndProcessSSEConnection` encounters an error or the stream ends.
    -   Checks if reconnection is permissible (within `maxRetryAttempts` and not a `CancellationError` from an explicit `disconnect`).
    -   Calculates delay using exponential backoff (`baseRetryDelay * 2^currentRetryAttempt`) or `customRetryDelay`.
    -   Increments `currentRetryAttempt`.
    -   Yields `.connecting` to `stateStream`.
    -   After the delay, recursively calls `establishAndProcessSSEConnection()` to retry.
    -   If retries are exhausted or not permitted, calls `disconnectCleanup()` with `SSETransportError.maxRetriesReached` or the original error.

### SSE Parsing Logic
The `establishAndProcessSSEConnection` method parses lines from the event stream:
-   Lines starting with `:` are comments and ignored.
-   Empty lines signify the end of an event.
-   Recognized fields:
    -   `id:<event_id>`: Sets `lastEventID`.
    -   `data:<event_data>`: Appends to `currentEventDataLines`. Multiple `data` lines are concatenated.
    -   `retry:<milliseconds>`: Sets `customRetryDelay`.
-   Other fields are ignored.
