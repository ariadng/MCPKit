# StdioTransport

## Overview

This file defines `StdioTransport`, an actor that implements the `MCPTransport` protocol. It is designed for communication with a local MCP server process by managing its lifecycle and using its standard input (stdin), standard output (stdout), and standard error (stderr) pipes. This transport mechanism is specific to macOS and is conditionally compiled using `#if os(macOS)`.

## `StdioError` Enum

Defines errors specific to `StdioTransport` operations.

### Definition
```swift
public enum StdioError: Error, LocalizedError {
    case processLaunchFailed(Error)
    case pipeError(String)
    case processTerminatedUnexpectedly(exitCode: Int32, reason: Process.TerminationReason)
    case stdoutPipeClosed
    case stdinWriteError(Error)
    case notConnected
    case alreadyConnected
    case unsupportedPlatform
    // ... (localized descriptions)
}
```

### Cases
-   `processLaunchFailed(Error)`: Failed to launch the server process, encapsulating the underlying error.
-   `pipeError(String)`: An error occurred with pipe setup or handling.
-   `processTerminatedUnexpectedly(exitCode: Int32, reason: Process.TerminationReason)`: The server process terminated unexpectedly.
-   `stdoutPipeClosed`: The standard output pipe of the server process closed unexpectedly.
-   `stdinWriteError(Error)`: An error occurred while writing to the server's standard input.
-   `notConnected`: Attempted an operation that requires a connection when the transport is not connected.
-   `alreadyConnected`: Attempted to connect when the transport is already connected or in the process of connecting.
-   `unsupportedPlatform`: Indicates an attempt to use `StdioTransport` on a non-macOS platform (though compilation guards should prevent this).

## `StdioTransport` Actor

An actor that manages a local server process and communicates via its standard I/O pipes.

### Definition
```swift
public final actor StdioTransport: MCPTransport {
    // Properties
    private let serverCommandPath: String
    private let serverArguments: [String]
    private var process: Process?
    private var stdinPipe: Pipe?
    private var stdoutPipe: Pipe?
    private var stderrPipe: Pipe?

    private var stdoutReadTask: Task<Void, Never>?
    private var stderrReadTask: Task<Void, Never>?

    private let incomingMessagesContinuation: AsyncStream<Data>.Continuation
    public nonisolated let incomingMessages: AsyncStream<Data>

    private let stateStreamContinuation: AsyncStream<TransportConnectionState>.Continuation
    public nonisolated let stateStream: AsyncStream<TransportConnectionState>

    private var internalState: TransportConnectionState
    // Initializer, connect, send, disconnect, and private helper methods
}
```

### Key Properties
-   `serverCommandPath: String`: The absolute path to the server executable.
-   `serverArguments: [String]`: Arguments to pass to the server executable.
-   `process: Process?`: The `Process` object representing the running server.
-   `stdinPipe: Pipe?`, `stdoutPipe: Pipe?`, `stderrPipe: Pipe?`: Pipes for stdin, stdout, and stderr of the server process.
-   `stdoutReadTask: Task<Void, Never>?`: Task for continuously reading from the server's stdout.
-   `stderrReadTask: Task<Void, Never>?`: Task for continuously reading from the server's stderr (for logging).
-   `incomingMessages: AsyncStream<Data>`: (from `MCPTransport`) Stream for yielding received message data.
-   `stateStream: AsyncStream<TransportConnectionState>`: (from `MCPTransport`) Stream for yielding connection state changes.
-   `internalState: TransportConnectionState`: Tracks the current connection state internally.

### Initialization
```swift
public init(commandPath: String, arguments: [String] = [])
```
-   Initializes the transport with the path to the server command and its arguments.
-   Sets up the `incomingMessages` and `stateStream` along with their continuations.
-   Initial state is set to `.disconnected(error: nil)`.

### Core `MCPTransport` Methods
-   **`connect() async throws`**
    -   Checks if already connected; throws `StdioError.alreadyConnected` if so.
    -   Updates state to `.connecting`.
    -   Creates `Process`, `stdinPipe`, `stdoutPipe`, and `stderrPipe`.
    -   Configures the `Process` with the executable URL, arguments, and pipes.
    -   Sets a `terminationHandler` for the process.
    -   Attempts to `process.run()`. Throws `StdioError.processLaunchFailed` on failure.
    -   If successful, starts `stdoutReadTask` and `stderrReadTask`.
    -   Updates state to `.connected`.

-   **`send(_ data: Data) async throws`**
    -   Checks if connected; throws `StdioError.notConnected` if not.
    -   Writes the provided `data` followed by a newline character (`\n`) to the server's `stdinPipe`. The newline acts as a message frame delimiter.
    -   Throws `StdioError.stdinWriteError` on failure.

-   **`disconnect() async`**
    -   Updates state to `.disconnected(error: nil)`.
    -   Calls `cleanupResources()` to terminate the process and release resources.

### Private Methods
-   **`updateState(_ newState: TransportConnectionState)`**
    -   Synchronously updates `internalState` and yields `newState` to `stateStreamContinuation`.

-   **`handleTermination(of terminatedProcess: Process, error: Error? = nil) async`**
    -   Called by the `Process.terminationHandler` or when a critical error occurs.
    -   If the disconnection wasn't client-initiated, updates state to `.disconnected` with an appropriate error.
    -   Calls `cleanupResources()`.

-   **`startReadingStdout()`**
    -   Creates and starts `stdoutReadTask` (a detached task).
    -   Continuously reads available data from `stdoutPipe`.
    -   Accumulates data in a buffer. When a newline character is encountered, the data up to and including the newline is considered a complete message.
    -   This message (without the trailing newline) is then passed to `processStdoutData()`.
    -   Handles pipe closure by breaking the loop and potentially signaling disconnection.

-   **`startReadingStderr()`**
    -   Creates and starts `stderrReadTask` (a detached task).
    -   Continuously reads available data from `stderrPipe` and logs it as strings.

-   **`processStdoutData(_ data: Data)`**
    -   Called by `startReadingStdout` with a complete message frame.
    -   Yields the `data` to `incomingMessagesContinuation`.

-   **`cleanupResources() async`**
    -   Cancels `stdoutReadTask` and `stderrReadTask`.
    -   Terminates the `process` if it's running.
    -   Closes file handles associated with pipes.
    -   Nil-out references to `process`, pipes, and tasks.
    -   Ensures `incomingMessagesContinuation` and `stateStreamContinuation` are finished if they haven't been already.

### Message Framing
-   **Sending**: Messages sent via `send(_ data: Data)` have a newline character (`\n`) appended to them before being written to the server's stdin.
-   **Receiving**: The `startReadingStdout()` method reads data until a newline character is encountered, treating the segment (excluding the newline) as a complete message.

## `TransportConnectionState` Extension

The file also includes an extension on `TransportConnectionState` (likely defined in `MCPTransport.swift` or a shared file) to add convenience computed properties:
-   `isDisconnected: Bool`: True if state is `.disconnected`.
-   `isDisconnectedByClient: Bool`: True if state is `.disconnected(error: nil)`, implying a deliberate disconnect.

```
