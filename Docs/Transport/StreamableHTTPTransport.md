# StreamableHTTPTransport

## Overview

This file implements `StreamableHTTPTransport`, an actor conforming to the `MCPTransport` protocol. It is designed to handle streaming HTTP responses, specifically those formatted as Newline Delimited JSON (NDJSON). Each line in the HTTP response body is treated as a separate JSON message.

## `StreamableHTTPError` Enum

Defines errors specific to `StreamableHTTPTransport` operations.

### Definition
```swift
public enum StreamableHTTPError: Error, LocalizedError {
    case invalidURL
    case sendingNotSupportedOnPrimaryStream
    case unexpectedHTTPStatus(statusCode: Int, responseBody: String?)
    case streamEndedNormally // Used to signal the natural end of the stream to the catch block
    case taskNotRunning
    // ... (localized descriptions)
}
```

### Cases
-   `invalidURL`: The provided server URL is invalid.
-   `sendingNotSupportedOnPrimaryStream`: Sending data is not supported on the primary stream by this transport. This implies that client-initiated requests expecting streamed responses might need a different mechanism or a different HTTP method/endpoint configuration not handled by this basic transport.
-   `unexpectedHTTPStatus(statusCode: Int, responseBody: String?)`: Received an unexpected HTTP status code from the server.
-   `streamEndedNormally`: Used internally to signal that the HTTP stream ended as expected (e.g., server closed the connection after sending all data), allowing the processing task to terminate gracefully.
-   `taskNotRunning`: Indicates an attempt to operate when the internal processing task is not active.

## `StreamableHTTPTransport` Actor

An actor that implements the `MCPTransport` protocol for handling NDJSON streams over HTTP.

### Inner Class: `ActorTaskWrapper`
To manage task identity correctly (since `Task` is a struct and cannot be compared with `===`), a private helper class is used:
```swift
private class ActorTaskWrapper {
    let id = UUID() // For debugging
    var task: Task<Void, Error>?
    init(_ task: Task<Void, Error>?) { self.task = task }
    func cancel() { task?.cancel() }
}
```
This wrapper allows the actor to ensure that state updates and error handling are performed only by the currently active processing task.

### Definition
```swift
public final actor StreamableHTTPTransport: MCPTransport {
    // Properties
    private let serverURL: URL
    private let httpMethod: String // e.g., "GET", "POST"
    private let urlSession: URLSession
    private var currentActorTaskWrapper: ActorTaskWrapper?

    public nonisolated let incomingMessages: AsyncStream<Data>
    private var incomingMessagesContinuation: AsyncStream<Data>.Continuation?

    public nonisolated let stateStream: AsyncStream<TransportConnectionState>
    private var stateStreamContinuation: AsyncStream<TransportConnectionState>.Continuation?

    // Initializer, connect, send, disconnect, and private helper methods
}
```

### Key Properties
-   `serverURL: URL`: The URL of the HTTP server providing the NDJSON stream.
-   `httpMethod: String`: The HTTP method to use for the request (e.g., "GET", "POST"). Defaults to "GET".
-   `urlSession: URLSession`: The URLSession instance used for HTTP requests.
-   `currentActorTaskWrapper: ActorTaskWrapper?`: Holds the wrapper for the current active processing task.
-   `incomingMessages: AsyncStream<Data>`: (from `MCPTransport`) Stream for yielding received NDJSON message data.
-   `stateStream: AsyncStream<TransportConnectionState>`: (from `MCPTransport`) Stream for yielding connection state changes.

### Initialization
```swift
public init(serverURL: URL, httpMethod: String = "GET", urlSession: URLSession = .shared)
```
-   Initializes the transport with the server URL, HTTP method (uppercased), and an optional URL session.
-   Sets up `incomingMessages` and `stateStream` with their continuations.
-   Initial state is `.disconnected(error: nil)`.

### Core `MCPTransport` Methods
-   **`connect() async throws`**
    -   Cancels any existing `currentActorTaskWrapper` and its associated task.
    -   Yields `.connecting` to `stateStream`.
    -   Creates a new `ActorTaskWrapper` and a new `Task` (typed `async throws`) to execute `establishAndProcessHTTPStream(taskWrapper:)`.
    -   Stores the new wrapper as `currentActorTaskWrapper`.

-   **`send(_ data: Data) async throws`**
    -   Throws `StreamableHTTPError.sendingNotSupportedOnPrimaryStream`. This transport is designed for receiving a stream from the server in response to an initial request (like GET).

-   **`disconnect() async`**
    -   Clears `currentActorTaskWrapper` and cancels the task it was holding.
    -   Yields `.disconnected(error: nil)` if a task was active.
    -   Finishes `incomingMessagesContinuation` and `stateStreamContinuation`.

### Private Methods
-   **`establishAndProcessHTTPStream(taskWrapper: ActorTaskWrapper) async throws`**
    -   The main method for establishing the HTTP connection and processing the NDJSON stream.
    -   Constructs a `URLRequest` with the specified `httpMethod` and sets the `Accept` header to `application/x-ndjson`.
    -   **Task Identity Check**: Before and after `await urlSession.bytes(for: request)`, it checks if `currentActorTaskWrapper === taskWrapper`. If not, it means this task is stale (e.g., `disconnect()` or another `connect()` was called), so it throws `CancellationError`.
    -   Handles HTTP response codes, expecting a 2xx status. Throws `StreamableHTTPError.unexpectedHTTPStatus` otherwise.
    -   If connected successfully (HTTP 2xx) and the task is still active and not cancelled, yields `.connected` to `stateStream`.
    -   Iterates through `asyncBytes.lines` (from `urlSession.bytes`):
        -   Performs task cancellation and identity checks on each iteration.
        -   Converts each non-empty `line` (String) to `Data` (UTF-8) and yields it to `incomingMessagesContinuation`.
    -   If the stream of lines ends normally, it throws `StreamableHTTPError.streamEndedNormally`.
    -   **Error Handling**: In the `catch` block:
        -   If `currentActorTaskWrapper === taskWrapper` (i.e., this is the active task), it yields `.disconnected(error: finalError)` to `stateStream`, clears `currentActorTaskWrapper`, and re-throws the error.
        -   If it's a stale task, it logs the error but doesn't update the primary state.

### Message Framing
-   **Receiving**: Each line from the HTTP response body is treated as a distinct message. The `asyncBytes.lines` property of `URLSession.bytes` handles splitting the byte stream into lines.
-   **Sending**: Not supported on the primary stream.
