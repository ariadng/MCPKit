# StdioTransport

`StdioTransport` is a component of `MCPKit` designed to facilitate communication with a local MCP (Model-Context Protocol) server process. It achieves this by managing the server process and utilizing its standard input (stdin), standard output (stdout), and standard error (stderr) pipes for communication. This transport is specifically tailored for macOS environments.

## Key Features

-   **Process Management**: Launches and monitors a local server executable.
-   **Pipe-based Communication**: Uses `stdin` for sending messages to the server and `stdout` for receiving messages. Server errors can be captured from `stderr`.
-   **Asynchronous Operations**: Leverages Swift's `async/await` for non-blocking operations.
-   **Message Framing**: Expects newline-delimited JSON messages from the server's stdout and sends messages to stdin followed by a newline character.
-   **Stream-based Data Handling**:
    -   `incomingMessages`: An `AsyncStream<Data>` that yields data chunks (typically individual JSON messages) received from the server's stdout.
    -   `stateStream`: An `AsyncStream<TransportConnectionState>` that provides real-time updates on the connection status (e.g., `.connecting`, `.connected`, `.disconnected`).
-   **Error Handling**: Defines a `StdioError` enum to represent specific errors that can occur during process management or pipe communication.
-   **Actor-based Thread Safety**: Implemented as a Swift `actor` to ensure thread-safe access to its internal state.

## Initialization

To use `StdioTransport`, you initialize it with the path to the server executable and optional command-line arguments:

```swift
let transport = StdioTransport(
    commandPath: "/path/to/your/mcp_server_executable",
    arguments: ["--port", "8080"]
)
```

## Core `MCPTransport` Protocol Implementation

-   **`connect() async throws`**: 
    -   Checks if already connected; throws `StdioError.alreadyConnected` if so.
    -   Updates state to `.connecting`.
    -   Creates `Process`, `stdinPipe`, `stdoutPipe`, and `stderrPipe`.
    -   Sets up the process with the executable path, arguments, and pipes.
    -   Assigns a `terminationHandler` to the process.
    -   Attempts to run the process. If launch fails, updates state to `.disconnected(error:)` and throws `StdioError.processLaunchFailed`.
    -   Starts asynchronous tasks to read from `stdout` and `stderr`.
    -   Updates state to `.connected` upon successful launch.

-   **`send(_ data: Data) async throws`**: 
    -   Checks if the process is running and connected; throws `StdioError.notConnected` otherwise.
    -   Writes the provided `Data` to the server process's `stdinPipe`, followed by a newline character (`\n`) for message framing.
    -   Throws `StdioError.stdinWriteError` if writing fails.

-   **`disconnect() async`**: 
    -   Updates state to `.disconnected(error: nil)` (client-initiated disconnect).
    -   Calls `cleanupResources()` which:
        -   Cancels `stdoutReadTask` and `stderrReadTask`.
        -   Terminates the server `process` if it's running.
        -   Closes pipe file handles.
        -   Clears references to `process` and pipes.
        -   Ensures `incomingMessagesContinuation` and `stateStreamContinuation` are finished if not already done.

## Streams

-   **`public nonisolated let incomingMessages: AsyncStream<Data>`**: 
    -   Provides an asynchronous stream of `Data` objects.
    -   Each `Data` object typically represents a complete JSON message received from the server's standard output, delimited by newlines.

-   **`public nonisolated let stateStream: AsyncStream<TransportConnectionState>`**: 
    -   Provides an asynchronous stream of `TransportConnectionState` enum values.
    -   Allows observers to monitor the connection lifecycle, including states like `.disconnected(error: Error?)`, `.connecting`, `.connected`.

## Error Handling

The `StdioTransport` uses the `StdioError` enum to report issues. Key error cases include:

-   `.processLaunchFailed(Error)`: If the server executable cannot be started.
-   `.pipeError(String)`: For issues related to setting up stdin/stdout/stderr pipes.
-   `.processTerminatedUnexpectedly(exitCode: Int32, reason: Process.TerminationReason)`: If the server process exits abnormally.
-   `.stdoutPipeClosed`: If the server's stdout closes unexpectedly.
-   `.stdinWriteError(Error)`: If writing to the server's stdin fails.
-   `.notConnected`: If `send()` is called when not connected.
-   `.alreadyConnected`: If `connect()` is called when already connected or connecting.

## Internal State Management

-   Uses an `internalState: TransportConnectionState` property, managed by the actor's synchronization.
-   `updateState(_ newState: TransportConnectionState)` method updates `internalState` and yields the `newState` to `stateStreamContinuation`.
-   `hasFinishedStateStream` and `hasFinishedIncomingMessagesStream` flags ensure stream continuations are finished exactly once, typically within `cleanupResources()` which is called by `disconnect()` or `handleTermination()`.

## Platform Specificity

`StdioTransport` is conditionally compiled for `os(macOS)` and is not intended for use on other platforms like iOS, watchOS, or tvOS.

## Example Usage (Conceptual)

```swift
// Initialize
let transport = StdioTransport(commandPath: "/usr/local/bin/my_mcp_server")

// Observe state changes
Task {
    for await state in transport.stateStream {
        print("Transport state: \(state)")
    }
}

// Observe incoming messages
Task {
    for await messageData in transport.incomingMessages {
        // Process messageData (e.g., decode JSON)
        print("Received message: \(String(data: messageData, encoding: .utf8) ?? "")")
    }
}

// Connect
do {
    try await transport.connect()
} catch {
    print("Failed to connect: \(error)")
}

// Send a message (assuming connected)
if let requestData = "{\"jsonrpc\": \"2.0\", \"method\": \"initialize\", \"id\": 1}".data(using: .utf8) {
    do {
        try await transport.send(requestData)
    } catch {
        print("Failed to send message: \(error)")
    }
}

// Disconnect when done
await transport.disconnect()
```

This documentation provides a comprehensive overview of `StdioTransport`, its functionalities, and how to integrate it into an `MCPKit`-based application on macOS.
