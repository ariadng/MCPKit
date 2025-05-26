import Foundation

/// Specifies the transport type and its required parameters for `MCPClient`.
public enum MCPTransportConfiguration: Sendable {
    #if os(macOS)
    /// Configuration for `StdioTransport`.
    /// - Parameters:
    ///   - commandPath: The absolute path to the server executable.
    ///   - arguments: Arguments to pass to the server executable.
    case stdio(commandPath: String, arguments: [String] = [])
    #endif

    /// Configuration for `SSETransport` (Server-Sent Events).
    /// - Parameters:
    ///   - url: The URL of the SSE server.
    ///   - maxRetryAttempts: Maximum number of reconnection attempts. Defaults to 5.
    ///   - baseRetryDelay: Base delay (in seconds) for exponential backoff. Defaults to 1.0.
    case sse(url: URL, maxRetryAttempts: Int = 5, baseRetryDelay: TimeInterval = 1.0)

    /// Configuration for `StreamableHTTPTransport` (Newline Delimited JSON over HTTP).
    /// - Parameters:
    ///   - url: The URL of the HTTP server providing the NDJSON stream.
    ///   - httpMethod: The HTTP method to use (e.g., "GET", "POST"). Defaults to "GET".
    case streamableHTTP(url: URL, httpMethod: String = "GET")

    // /// Configuration for a custom, user-provided transport instance.
    // /// This allows advanced users to inject their own `MCPTransport` conforming types.
    // case custom(MCPTransport) // Consider if MCPTransport can be Sendable if this case is used directly.
}
