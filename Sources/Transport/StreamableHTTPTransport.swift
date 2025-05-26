import Foundation

/// Errors specific to `StreamableHTTPTransport` operations.
public enum StreamableHTTPError: Error, LocalizedError {
    case invalidURL
    case sendingNotSupportedOnPrimaryStream
    case unexpectedHTTPStatus(statusCode: Int, responseBody: String?)
    case streamEndedNormally // Used to signal the natural end of the stream to the catch block
    case taskNotRunning

    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The provided server URL is invalid."
        case .sendingNotSupportedOnPrimaryStream:
            return "Sending data is not supported on the primary stream by StreamableHTTPTransport. Client-initiated requests expecting streamed responses may require a different mechanism."
        case .unexpectedHTTPStatus(let statusCode, let body):
            let bodyDescription = body?.isEmpty == false ? " Body: \(body!)" : ""
            return "Received unexpected HTTP status code: \(statusCode).\(bodyDescription)"
        case .streamEndedNormally:
            return "The HTTP stream ended normally."
        case .taskNotRunning:
            return "The processing task is not running or has already completed."
        }
    }
}

public final actor StreamableHTTPTransport: MCPTransport {

    private class ActorTaskWrapper {
        let id = UUID() // For debugging or logging if needed
        var task: Task<Void, Error>?
        init(_ task: Task<Void, Error>?) { self.task = task }
        func cancel() { task?.cancel() }
    }

    private let serverURL: URL
    private let httpMethod: String
    private let urlSession: URLSession
    private var currentActorTaskWrapper: ActorTaskWrapper?

    public nonisolated let incomingMessages: AsyncStream<Data>
    private var incomingMessagesContinuation: AsyncStream<Data>.Continuation?

    public nonisolated let stateStream: AsyncStream<TransportConnectionState>
    private var stateStreamContinuation: AsyncStream<TransportConnectionState>.Continuation?

    public init(serverURL: URL, httpMethod: String = "GET", urlSession: URLSession = .shared) {
        self.serverURL = serverURL
        self.httpMethod = httpMethod.uppercased()
        self.urlSession = urlSession

        var incomingCont: AsyncStream<Data>.Continuation!
        self.incomingMessages = AsyncStream<Data> { continuation in
            incomingCont = continuation
        }
        self.incomingMessagesContinuation = incomingCont

        var stateCont: AsyncStream<TransportConnectionState>.Continuation!
        self.stateStream = AsyncStream<TransportConnectionState> { continuation in
            stateCont = continuation
        }
        self.stateStreamContinuation = stateCont
        
        self.stateStreamContinuation?.yield(.disconnected(error: nil))
    }

    public func connect() async throws {
        if let existingWrapper = currentActorTaskWrapper {
            print("StreamableHTTPTransport: Connect called while a task is already active. Cancelling existing task.")
            existingWrapper.cancel()
            currentActorTaskWrapper = nil
        }

        stateStreamContinuation?.yield(.connecting)
        
        print("StreamableHTTPTransport: Starting new HTTP stream processing task for URL: \(serverURL).")
        
        // Create the new task and immediately wrap it
        let newWrappedTask = ActorTaskWrapper(nil) // Initialize wrapper, task set below
        let task = Task { 
            // Pass the wrapper instance to the processing method
            // This function is designed to run indefinitely or until an error/cancellation.
            // It handles its own errors by updating the stateStream.
            // We make the Task `async throws` to match the expected type, even if
            // establishAndProcessHTTPStream doesn't throw directly to this Task's catch.
            try await self.establishAndProcessHTTPStream(taskWrapper: newWrappedTask)
        }
        newWrappedTask.task = task // Assign the created task to the wrapper
        currentActorTaskWrapper = newWrappedTask // Store the wrapper
    }

    public func send(_ data: Data) async throws {
        print("StreamableHTTPTransport: Send called. Data: \(String(data: data, encoding: .utf8) ?? "Non-UTF8 Data")")
        throw StreamableHTTPError.sendingNotSupportedOnPrimaryStream
    }

    public func disconnect() async {
        let wrapperToCancel = currentActorTaskWrapper
        currentActorTaskWrapper = nil // Clear immediately
        
        wrapperToCancel?.cancel() // Request cancellation on the (now previous) task

        print("StreamableHTTPTransport: Disconnect called.")
        
        if wrapperToCancel != nil {
             stateStreamContinuation?.yield(.disconnected(error: nil)) 
        }
        
        if incomingMessagesContinuation != nil {
            incomingMessagesContinuation?.finish()
            incomingMessagesContinuation = nil
        }
        if stateStreamContinuation != nil {
            stateStreamContinuation?.finish()
            stateStreamContinuation = nil
        }
        print("StreamableHTTPTransport: Streams finished by disconnect().")
    }

    private func establishAndProcessHTTPStream(taskWrapper: ActorTaskWrapper) async throws {
        var request = URLRequest(url: serverURL)
        request.httpMethod = self.httpMethod
        request.setValue("application/x-ndjson", forHTTPHeaderField: "Accept")

        print("StreamableHTTPTransport: Attempting to connect with \(httpMethod) to \(serverURL.absoluteString) (Task ID: \(taskWrapper.id))")

        do {
            guard currentActorTaskWrapper === taskWrapper else {
                print("StreamableHTTPTransport: Task \(taskWrapper.id) is no longer the active task before network request. Aborting.")
                throw CancellationError()
            }

            let (asyncBytes, response) = try await urlSession.bytes(for: request)
            
            guard currentActorTaskWrapper === taskWrapper else {
                print("StreamableHTTPTransport: Task \(taskWrapper.id) is no longer the active task after network request. Aborting.")
                throw CancellationError()
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw URLError(.badServerResponse)
            }
            
            guard httpResponse.statusCode >= 200, httpResponse.statusCode < 300 else {
                var responseBody: String? = nil
                var bodyData = Data()
                do {
                    for try await byte in asyncBytes {
                        bodyData.append(byte)
                        if bodyData.count > 1024 { break } 
                    }
                    if !bodyData.isEmpty { responseBody = String(data: bodyData, encoding: .utf8) }
                } catch { /* Ignore */ }
                throw StreamableHTTPError.unexpectedHTTPStatus(statusCode: httpResponse.statusCode, responseBody: responseBody)
            }
            
            if Task.isCancelled { // Check for cancellation specifically for this task execution context
                print("StreamableHTTPTransport: Task \(taskWrapper.id) cancelled before connection fully established.")
                throw CancellationError()
            }
            stateStreamContinuation?.yield(.connected)
            print("StreamableHTTPTransport: Connected successfully (Task ID: \(taskWrapper.id)).")
            
            for try await line in asyncBytes.lines {
                if Task.isCancelled { 
                    print("StreamableHTTPTransport: Task \(taskWrapper.id) cancelled during line processing.")
                    throw CancellationError() 
                }
                 guard currentActorTaskWrapper === taskWrapper else { // Check on each iteration if still active
                    print("StreamableHTTPTransport: Task \(taskWrapper.id) is no longer the active task during line processing. Aborting.")
                    throw CancellationError()
                }
                
                if let jsonData = line.data(using: .utf8) {
                    if !jsonData.isEmpty { 
                        incomingMessagesContinuation?.yield(jsonData)
                    }
                } else {
                    print("StreamableHTTPTransport: Warning - failed to convert line to Data. Line: \(line) (Task ID: \(taskWrapper.id))")
                }
            }
            print("StreamableHTTPTransport: Stream ended normally from server (Task ID: \(taskWrapper.id)).")
            throw StreamableHTTPError.streamEndedNormally
        } catch {
            if currentActorTaskWrapper === taskWrapper {
                let finalError = error
                print("StreamableHTTPTransport: Task \(taskWrapper.id) ended with error: \(finalError.localizedDescription)")
                stateStreamContinuation?.yield(.disconnected(error: finalError))
                currentActorTaskWrapper = nil // Clear the task as it has now ended
                throw finalError // Re-throw to satisfy 'async throws' if necessary, though connect() doesn't catch it.
            } else {
                print("StreamableHTTPTransport: Error caught for a stale task \(taskWrapper.id). Current active task might be different or nil. Error: \(error.localizedDescription)")
                // If it's a stale task, we might not want to throw, or throw a specific 'stale task error'
                // For now, just print and let the task end.
                if error is CancellationError {
                    throw error // Propagate cancellation if it's for this stale task
                }
                // Otherwise, don't rethrow the original error for a stale task as it might be misleading.
            }
            // Do not finish streams here; disconnect() is responsible for that.
        }
    }
}
