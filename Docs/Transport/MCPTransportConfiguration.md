# MCPTransportConfiguration

**File Path:** `Sources/Transport/MCPTransportConfiguration.swift`

The `MCPTransportConfiguration` enum defines the available transport mechanisms that an `MCPClient` can use to communicate with an MCP server. It specifies the type of transport and the parameters required for its initialization.

This enum conforms to the `Sendable` protocol, making it safe to pass across concurrency domains.

## Cases

The enum provides the following configuration cases:

---

### 1. `stdio`

Configures the client to use `StdioTransport` for communication with a local MCP server process via standard input/output pipes.

**Availability:** This case is only available on macOS (`#if os(macOS)`).

**Parameters:**

*   `commandPath`: `String`
    *   The absolute path to the server executable file.
*   `arguments`: `[String]` (Optional)
    *   An array of string arguments to pass to the server executable upon launch.
    *   Defaults to an empty array (`[]`).

**Example:**

```swift
let stdioConfig = MCPTransportConfiguration.stdio(
    commandPath: "/usr/local/bin/my_mcp_server",
    arguments: ["--verbose", "--port", "8080"]
)
```

---

### 2. `sse`

Configures the client to use `SSETransport` for communication with an MCP server using Server-Sent Events (SSE).

**Parameters:**

*   `url`: `URL`
    *   The URL of the SSE endpoint on the MCP server.
*   `maxRetryAttempts`: `Int` (Optional)
    *   The maximum number of times the client should attempt to reconnect if the connection is lost.
    *   Defaults to `5`.
*   `baseRetryDelay`: `TimeInterval` (Optional)
    *   The base delay in seconds for the exponential backoff strategy used during reconnection attempts.
    *   Defaults to `1.0` second.

**Example:**

```swift
if let serverURL = URL(string: "https://example.com/mcp-events") {
    let sseConfig = MCPTransportConfiguration.sse(
        url: serverURL,
        maxRetryAttempts: 3,
        baseRetryDelay: 2.0
    )
}
```

---

### 3. `streamableHTTP`

Configures the client to use `StreamableHTTPTransport` for communication with an MCP server that provides a stream of newline-delimited JSON (NDJSON) objects over an HTTP connection.

**Parameters:**

*   `url`: `URL`
    *   The URL of the HTTP endpoint on the MCP server that provides the NDJSON stream.
*   `httpMethod`: `String` (Optional)
    *   The HTTP method to be used for the request (e.g., "GET", "POST").
    *   Defaults to `"GET"`.

**Example:**

```swift
if let streamURL = URL(string: "https://example.com/mcp-stream") {
    let httpConfig = MCPTransportConfiguration.streamableHTTP(
        url: streamURL,
        httpMethod: "POST"
    )
}
```

---
<!-- 
// /// Configuration for a custom, user-provided transport instance.
// /// This allows advanced users to inject their own `MCPTransport` conforming types.
// case custom(MCPTransport) // Consider if MCPTransport can be Sendable if this case is used directly.
If this case is enabled in the future, documentation for it should be added here.
-->
