#if os(macOS)
import Foundation

/// `StdioTransport` facilitates communication with a local MCP server process
/// via its standard input/output pipes. This transport is macOS-specific.
public final actor StdioTransport: MCPTransport { // Changed from class to actor

    /// Errors specific to `StdioTransport` operations.
    public enum StdioError: Error, LocalizedError {
        case processLaunchFailed(Error)
        case pipeError(String)
        case processTerminatedUnexpectedly(exitCode: Int32, reason: Process.TerminationReason)
        case stdoutPipeClosed
        case stdinWriteError(Error)
        case notConnected
        case alreadyConnected
        case unsupportedPlatform

        public var errorDescription: String? {
            switch self {
            case .processLaunchFailed(let underlyingError):
                return "Failed to launch server process: \(underlyingError.localizedDescription)"
            case .pipeError(let message):
                return "Pipe error: \(message)"
            case .processTerminatedUnexpectedly(let exitCode, let reason):
                return "Server process terminated unexpectedly. Exit code: \(exitCode), Reason: \(reason.rawValue)"
            case .stdoutPipeClosed:
                return "Standard output pipe closed unexpectedly."
            case .stdinWriteError(let underlyingError):
                return "Error writing to standard input: \(underlyingError.localizedDescription)"
            case .notConnected:
                return "Transport is not connected."
            case .alreadyConnected:
                return "Transport is already connected or connecting."
            case .unsupportedPlatform:
                return "StdioTransport is only supported on macOS."
            }
        }
    }

    private let serverCommandPath: String
    private let serverArguments: [String]
    private var process: Process?
    private var stdinPipe: Pipe?
    private var stdoutPipe: Pipe?
    private var stderrPipe: Pipe? // For logging server errors

    private var stdoutReadTask: Task<Void, Never>?
    private var stderrReadTask: Task<Void, Never>?

    // Continuations are Sendable, so they can be stored in an actor.
    private let incomingMessagesContinuation: AsyncStream<Data>.Continuation
    public nonisolated let incomingMessages: AsyncStream<Data> // nonisolated as it's initialized and then immutable

    private let stateStreamContinuation: AsyncStream<TransportConnectionState>.Continuation
    public nonisolated let stateStream: AsyncStream<TransportConnectionState> // nonisolated for same reason

    // private let lock = NSLock() // Removed NSLock, actor provides synchronization
    private var internalState: TransportConnectionState = .disconnected(error: nil)
    private var hasFinishedStateStream: Bool = false
    private var hasFinishedIncomingMessagesStream: Bool = false

    /// Initializes the StdioTransport with the command to launch the server process.
    ///
    /// - Parameters:
    ///   - commandPath: The absolute path to the server executable.
    ///   - arguments: An array of arguments to pass to the server executable.
    public init(commandPath: String, arguments: [String] = []) {
        self.serverCommandPath = commandPath
        self.serverArguments = arguments

        var incomingContinuation: AsyncStream<Data>.Continuation!
        self.incomingMessages = AsyncStream<Data> { continuation in
            incomingContinuation = continuation
        }
        self.incomingMessagesContinuation = incomingContinuation!

        var stateContinuation: AsyncStream<TransportConnectionState>.Continuation!
        self.stateStream = AsyncStream<TransportConnectionState> { continuation in
            stateContinuation = continuation
        }
        self.stateStreamContinuation = stateContinuation!
        
        // Set initial state after continuations are captured
        // This direct call to yield is fine during init before actor is fully isolated.
        self.stateStreamContinuation.yield(.disconnected(error: nil))
    }

    // deinit removed: Actors have restrictions on deinitializers that access actor-isolated state 
    // or call async methods. Explicit disconnect() is required for cleanup.
    // Ensure streams are finished in cleanupResources when the transport is truly done.

    public func connect() async throws {
        // Actor methods are implicitly synchronized
        guard internalState.isDisconnected else {
            print("StdioTransport: Connect called but already connected or connecting.")
            throw StdioError.alreadyConnected
        }

        updateState(.connecting)

        self.process = Process()
        self.stdinPipe = Pipe()
        self.stdoutPipe = Pipe()
        self.stderrPipe = Pipe()

        guard let process = self.process,
              let stdinPipe = self.stdinPipe,
              let stdoutPipe = self.stdoutPipe,
              let stderrPipe = self.stderrPipe else {
            let error = StdioError.pipeError("Failed to create process or pipes.")
            updateState(.disconnected(error: error))
            throw error
        }

        process.executableURL = URL(fileURLWithPath: serverCommandPath)
        process.arguments = serverArguments
        process.standardInput = stdinPipe
        process.standardOutput = stdoutPipe
        process.standardError = stderrPipe

        process.terminationHandler = { [weak self] terminatedProcess in
            guard let self else { return }
            // Bridge to actor's context to handle termination
            Task {
                await self.handleTermination(of: terminatedProcess)
            }
        }

        do {
            try process.run()
            print("StdioTransport: Process started successfully (\(process.processIdentifier)).")
        } catch {
            let wrappedError = StdioError.processLaunchFailed(error)
            updateState(.disconnected(error: wrappedError))
            await cleanupResources() // Call actor method
            throw wrappedError
        }

        startReadingStdout()
        startReadingStderr() // For logging server errors
        updateState(.connected)
    }

    public func send(_ data: Data) async throws {
        // Actor methods are implicitly synchronized
        guard let process = self.process, process.isRunning,
              let stdinPipe = self.stdinPipe else {
            throw StdioError.notConnected
        }

        let handle = stdinPipe.fileHandleForWriting
        do {
            try handle.write(contentsOf: data) // Send the raw data
            try handle.write(contentsOf: Data("\n".utf8)) // Append newline for framing
        } catch {
            let wrappedError = StdioError.stdinWriteError(error)
            Task { // No need for [weak self] if self is an actor and this Task is short-lived
                await self.handleTermination(of: process, error: wrappedError)
            }
            throw wrappedError
        }
    }

    public func disconnect() async {
        // Actor methods are implicitly synchronized
        print("StdioTransport: Disconnect called.")
        updateState(.disconnected(error: nil))
        await cleanupResources()
    }

    private func updateState(_ newState: TransportConnectionState) {
        // This is an actor method, so internalState access is synchronized.
        internalState = newState
        stateStreamContinuation.yield(newState) // Continuation is Sendable
    }

    private func handleTermination(of terminatedProcess: Process, error: Error? = nil) async {
        // Actor method
        print("StdioTransport: Process termination handler invoked. PID: \(terminatedProcess.processIdentifier)")
        let termError = error ?? StdioError.processTerminatedUnexpectedly(
            exitCode: terminatedProcess.terminationStatus,
            reason: terminatedProcess.terminationReason
        )
        if !internalState.isDisconnectedByClient {
            updateState(.disconnected(error: termError))
        }
        await cleanupResources()
    }

    private func startReadingStdout() {
        guard let stdoutPipe = self.stdoutPipe else { return }
        let stdoutHandle = stdoutPipe.fileHandleForReading

        stdoutReadTask = Task.detached(priority: .userInitiated) { [weak self] in // weak self still good practice for detached tasks
            print("StdioTransport: stdoutReadTask started.")
            var buffer = Data()
            
            while let actorSelf = self { // Check self still exists
                let isRunning = await actorSelf.process?.isRunning ?? false
                if !isRunning && buffer.isEmpty {
                    print("StdioTransport: stdoutReadTask - process not running and buffer empty.")
                    break
                }

                if Task.isCancelled { 
                    print("StdioTransport: stdoutReadTask cancelled."); break
                }
                let availableData = stdoutHandle.availableData
                if availableData.isEmpty {
                    if !isRunning {
                        print("StdioTransport: stdoutReadTask - process not running and no more data.")
                        break
                    }
                    try? await Task.sleep(for: .milliseconds(50))
                    continue
                }
                
                buffer.append(availableData)
                
                while let newlineRange = buffer.firstRange(of: Data("\n".utf8)) {
                    let lineData = buffer.subdata(in: buffer.startIndex..<newlineRange.lowerBound)
                    buffer.removeSubrange(buffer.startIndex..<newlineRange.upperBound)
                    
                    if !lineData.isEmpty {
                        // Accessing actor-isolated continuation directly is fine as it's Sendable.
                        actorSelf.incomingMessagesContinuation.yield(lineData)
                    }
                }
            }
            
            print("StdioTransport: stdoutReadTask finished.")
            // Call actor method to handle cleanup/state update from task completion
            Task { [weak self] in 
                await self?.handleStdoutTaskCompletion()
            }
        }
    }

    private func handleStdoutTaskCompletion() async {
        // Actor method
        if let p = self.process, p.isRunning, self.internalState.isConnected {
             let error = StdioError.stdoutPipeClosed
             if !self.internalState.isDisconnectedByClient {
                 updateState(.disconnected(error: error))
             }
        }
        await self.cleanupResources()
    }
    
    private func startReadingStderr() {
        guard let stderrPipe = self.stderrPipe else { return }
        let stderrHandle = stderrPipe.fileHandleForReading

        stderrReadTask = Task.detached(priority: .background) { [weak self] in
            print("StdioTransport: stderrReadTask started.")
            while let actorSelf = self { // Check self still exists
                 let isRunning = await actorSelf.process?.isRunning ?? false
                  if !isRunning { print("StdioTransport: stderrReadTask - process not running."); break }
                  if Task.isCancelled { print("StdioTransport: stderrReadTask cancelled."); break }
                
                let dataChunk = stderrHandle.availableData
                if dataChunk.isEmpty {
                    if !isRunning { break }
                    try? await Task.sleep(for: .milliseconds(100))
                    continue
                }
                
                if let errorString = String(data: dataChunk, encoding: .utf8) {
                    print("StdioTransport [SERVER STDERR]: \(errorString.trimmingCharacters(in: .whitespacesAndNewlines))")
                } else {
                    print("StdioTransport [SERVER STDERR]: (Non-UTF8 data chunk)")
                }
            }
            print("StdioTransport: stderrReadTask finished.")
        }
    }

    private func cleanupResources() async {
        // Actor method
        print("StdioTransport: cleanupResources called.")

        stdoutReadTask?.cancel()
        stderrReadTask?.cancel()
        stdoutReadTask = nil
        stderrReadTask = nil

        if let process = self.process, process.isRunning {
            print("StdioTransport: Terminating process (\(process.processIdentifier)).")
            process.terminate() // This is synchronous
        }
        self.process = nil
        self.stdinPipe = nil
        self.stdoutPipe = nil
        self.stderrPipe = nil

        // Finish streams only if they haven't been finished yet.
        if !hasFinishedIncomingMessagesStream {
            incomingMessagesContinuation.finish()
            hasFinishedIncomingMessagesStream = true
            print("StdioTransport: incomingMessagesContinuation finished.")
        }
        
        if !hasFinishedStateStream {
            stateStreamContinuation.finish()
            hasFinishedStateStream = true
            print("StdioTransport: stateStreamContinuation finished.")
        }
    }
}

// Extension to provide convenient checks on TransportConnectionState
extension TransportConnectionState {
    var isDisconnected: Bool {
        if case .disconnected = self { return true }
        return false
    }

    var isConnected: Bool {
        if case .connected = self { return true }
        return false
    }
    
    /// True if the state is .disconnected and the error is nil (client-initiated disconnect)
    var isDisconnectedByClient: Bool {
        if case .disconnected(let error) = self, error == nil {
            return true
        }
        return false
    }
}

#else
// Non-macOS stub implementation for StdioTransport
// ... (rest of the #else block as before)
#endif
