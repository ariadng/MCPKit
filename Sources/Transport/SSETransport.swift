import Foundation

/// Errors specific to `SSETransport` operations.
public enum SSETransportError: Error, LocalizedError {
    case invalidURL
    case sendingNotSupported
    case unexpectedHTTPStatus(statusCode: Int, responseBody: String?)
    case sseParsingError(description: String)
    case streamEnded // Indicates the SSE stream ended, possibly normally.
    case maxRetriesReached
    case connectionAttemptFailed(Error)

    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The provided server URL is invalid."
        case .sendingNotSupported:
            return "Sending data is not supported by SSETransport. SSE is primarily for server-to-client communication."
        case .unexpectedHTTPStatus(let statusCode, let body):
            let bodyDescription = body?.isEmpty == false ? " Body: \(body!)" : ""
            return "Received unexpected HTTP status code: \(statusCode).\(bodyDescription)"
        case .sseParsingError(let description):
            return "Error parsing SSE event: \(description)"
        case .streamEnded:
            return "The Server-Sent Events stream ended."
        case .maxRetriesReached:
            return "Maximum reconnection attempts reached."
        case .connectionAttemptFailed(let error):
            return "Failed to establish SSE connection: \(error.localizedDescription)"
        }
    }
}

public final actor SSETransport: MCPTransport {

    private let serverURL: URL
    private let urlSession: URLSession
    private var sseProcessingTask: Task<Void, Never>?

    public nonisolated let incomingMessages: AsyncStream<Data>
    private let incomingMessagesContinuation: AsyncStream<Data>.Continuation

    public nonisolated let stateStream: AsyncStream<TransportConnectionState>
    private let stateStreamContinuation: AsyncStream<TransportConnectionState>.Continuation

    private var currentRetryAttempt: Int = 0
    private let maxRetryAttempts: Int
    private let baseRetryDelay: TimeInterval
    private var lastEventID: String?
    private var customRetryDelay: TimeInterval?
    
    private var hasFinishedStateStream: Bool = false
    private var hasFinishedIncomingMessagesStream: Bool = false

    public init(serverURL: URL, urlSession: URLSession = .shared, maxRetryAttempts: Int = 5, baseRetryDelay: TimeInterval = 1.0) {
        self.serverURL = serverURL
        self.urlSession = urlSession
        self.maxRetryAttempts = maxRetryAttempts
        self.baseRetryDelay = baseRetryDelay

        var incomingCont: AsyncStream<Data>.Continuation!
        self.incomingMessages = AsyncStream<Data> { continuation in
            incomingCont = continuation
        }
        self.incomingMessagesContinuation = incomingCont!

        var stateCont: AsyncStream<TransportConnectionState>.Continuation!
        self.stateStream = AsyncStream<TransportConnectionState> { continuation in
            stateCont = continuation
        }
        self.stateStreamContinuation = stateCont!
        
        self.stateStreamContinuation.yield(.disconnected(error: nil))
    }

    public func connect() async {
        if sseProcessingTask != nil {
            print("SSETransport: Connect called while a task is already active. Cancelling existing task.")
            sseProcessingTask?.cancel()
            sseProcessingTask = nil
        }
        
        currentRetryAttempt = 0
        customRetryDelay = nil
        
        stateStreamContinuation.yield(.connecting)
        
        print("SSETransport: Starting new SSE processing task.")
        sseProcessingTask = Task {
            await establishAndProcessSSEConnection()
        }
    }

    public func send(_ data: Data) async throws {
        print("SSETransport: Send called, but not supported for SSE. Data: \(String(data: data, encoding: .utf8) ?? "Non-UTF8 Data")")
        throw SSETransportError.sendingNotSupported
    }

    public func disconnect() async {
        let wasConnectedOrConnecting = sseProcessingTask != nil
        currentRetryAttempt = maxRetryAttempts + 1
        sseProcessingTask?.cancel()
        sseProcessingTask = nil
        
        print("SSETransport: Disconnect called.")
        if wasConnectedOrConnecting {
             await disconnectCleanup(with: nil)
        }
    }

    private func disconnectCleanup(with error: Error?) async {
        if sseProcessingTask == nil && error == nil {
            // If no task was active and no error, only proceed if streams might still be open.
            // This check helps prevent issues if disconnectCleanup is called redundantly.
            if hasFinishedStateStream && hasFinishedIncomingMessagesStream {
                print("SSETransport: disconnectCleanup called but streams already finished.")
                return
            }
        }
        
        sseProcessingTask = nil

        if !hasFinishedStateStream {
            stateStreamContinuation.yield(.disconnected(error: error))
            stateStreamContinuation.finish()
            hasFinishedStateStream = true
            print("SSETransport: stateStream finished.")
        } else if error != nil {
            // If stream already finished but we have a new error, at least log it.
            // This situation should ideally not happen if logic is correct.
            print("SSETransport: stateStream already finished, but disconnectCleanup called with error: \(error?.localizedDescription ?? "Unknown error")")
        }
        
        if !hasFinishedIncomingMessagesStream {
            incomingMessagesContinuation.finish()
            hasFinishedIncomingMessagesStream = true
            print("SSETransport: incomingMessagesStream finished.")
        }

        // Nil-ing out continuations is less critical now with the flags, but can be kept for completeness
        // or removed if deemed unnecessary.
        // incomingMessagesContinuation = nil 
        // stateStreamContinuation = nil
        print("SSETransport: disconnectCleanup completed.")
    }

    private func establishAndProcessSSEConnection() async {
        var request = URLRequest(url: serverURL)
        request.httpMethod = "GET"
        request.setValue("text/event-stream", forHTTPHeaderField: "Accept")
        request.setValue("no-cache", forHTTPHeaderField: "Cache-Control")
        request.timeoutInterval = 30

        if let eventID = lastEventID {
            request.setValue(eventID, forHTTPHeaderField: "Last-Event-ID")
        }
        let attemptForLog = currentRetryAttempt

        print("SSETransport: Attempting to connect (Attempt: \(attemptForLog + 1)). URL: \(serverURL.absoluteString)")

        do {
            let (asyncByteStream, response) = try await urlSession.bytes(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw SSETransportError.unexpectedHTTPStatus(statusCode: (response as? HTTPURLResponse)?.statusCode ?? -1, responseBody: nil)
            }

            if httpResponse.statusCode != 200 {
                var responseBody: String? = nil
                var bodyData = Data()
                do {
                    for try await byte in asyncByteStream {
                        bodyData.append(byte)
                        if bodyData.count > 1024 { break }
                    }
                    if !bodyData.isEmpty { responseBody = String(data: bodyData, encoding: .utf8) }
                } catch {
                    print("SSETransport: Error reading response body for failed request: \(error)")
                }
                throw SSETransportError.unexpectedHTTPStatus(statusCode: httpResponse.statusCode, responseBody: responseBody)
            }
            
            stateStreamContinuation.yield(.connected)
            currentRetryAttempt = 0
            customRetryDelay = nil
            print("SSETransport: Connected successfully.")

            var currentEventDataLines: [String] = []

            for try await line in asyncByteStream.lines {
                if Task.isCancelled { 
                    print("SSETransport: Task cancelled during line processing.")
                    throw CancellationError() 
                }

                if line.isEmpty { 
                    if !currentEventDataLines.isEmpty {
                        let fullDataString = currentEventDataLines.joined(separator: "\n")
                        if let jsonData = fullDataString.data(using: .utf8) {
                            incomingMessagesContinuation.yield(jsonData)
                        } else {
                            print("SSETransport: Failed to convert event data to UTF-8. Data: \(fullDataString)")
                        }
                        currentEventDataLines = []
                    }
                    continue
                }

                if line.starts(with: ":") { continue }

                if let colonIndex = line.firstIndex(of: ":") {
                    let field = String(line[..<colonIndex])
                    let valueStartIndex = line.index(after: colonIndex)
                    var value = String(line[valueStartIndex...])
                    if value.first == " " { value.removeFirst() }
                    
                    switch field {
                    case "id":
                        lastEventID = value
                    case "data":
                        currentEventDataLines.append(value)
                    case "retry":
                        if let retryMilliseconds = Int(value) {
                            customRetryDelay = TimeInterval(retryMilliseconds) / 1000.0
                        }
                    default: break
                    }
                } 
            }
            print("SSETransport: Stream ended normally.")
            throw SSETransportError.streamEnded

        } catch {
            if Task.isCancelled && !(error is CancellationError) {
                 print("SSETransport: Task was externally cancelled, not retrying.")
                 await disconnectCleanup(with: CancellationError())
                 return
            }
            if error is CancellationError {
                print("SSETransport: Task was cancelled. Cleaning up.")
                await disconnectCleanup(with: error)
                return
            }

            print("SSETransport: Connection error: \(error.localizedDescription)")
            
            stateStreamContinuation.yield(.disconnected(error: error))
            let shouldRetry = currentRetryAttempt < maxRetryAttempts
            currentRetryAttempt += 1
            let baseDelayVal = customRetryDelay ?? (baseRetryDelay * pow(2.0, Double(currentRetryAttempt - 1)))
            let jitter = baseDelayVal * Double.random(in: -0.2...0.2)
            let delay = max(0, baseDelayVal + jitter)

            if shouldRetry {
                print("SSETransport: Will attempt to reconnect in \(String(format: "%.2f", delay)) seconds (Attempt \(currentRetryAttempt)/\(maxRetryAttempts)).")
                do {
                    try await Task.sleep(for: .seconds(delay))
                    if Task.isCancelled { 
                        print("SSETransport: Task cancelled during retry sleep. Aborting retry.")
                        await disconnectCleanup(with: CancellationError())
                        return
                    }
                    await establishAndProcessSSEConnection()
                } catch {
                    print("SSETransport: Sleep for retry was cancelled. Aborting retry.")
                    await disconnectCleanup(with: CancellationError())
                }
            } else {
                print("SSETransport: Max retries reached or error is non-recoverable. Permanently disconnected.")
                await disconnectCleanup(with: error is CancellationError ? error : SSETransportError.maxRetriesReached)
            }
        }
    }
}
