# MCPClientError

**File:** `Sources/MCPClient/MCPClientError.swift`

The `MCPClientError` enum defines custom errors specific to `MCPClient` operations. These errors help in diagnosing issues related to client-server communication, message handling, and internal client state.

## Cases

-   `.notConnected`:
    An operation was attempted that requires an active connection, but the client is not connected.
-   `.requestEncodingFailed(Error)`:
    Failed to encode an outgoing JSON-RPC request. The associated `Error` provides details.
-   `.responseDecodingFailed(Error)`:
    Failed to decode an incoming JSON-RPC response. The associated `Error` provides details.
-   `.transportError(Error)`:
    An error occurred in the underlying transport layer. The associated `Error` provides details.
-   `.unsolicitedResponse(id: String)`:
    Received a response from the server with an ID that does not match any pending requests.
-   `.serverError(code: Int, message: String, data: AnyCodable?)`:
    The server returned a JSON-RPC error object in response to a request. Includes the error `code`, `message`, and optional `data`.
-   `.unexpectedMessageFormat`:
    An incoming message did not conform to the expected JSON-RPC structure.
-   `.continuationNotFound(id: String)`:
    A response was received, but the corresponding continuation for the request ID was not found (internal error).
-   `.typeCastingFailed(expectedType: String, actualValue: Any)`:
    Failed to cast a decoded response to the expected Swift type.
-   `.jsonRpcError(JSONRPCErrorObject)`:
    Wraps a `JSONRPCErrorObject` received from the server, typically used when the error structure is directly from the JSON-RPC schema.
-   `.transportNotAvailable`:
    The configured transport could not be initialized or is otherwise unavailable.
-   `.alreadyConnected`:
    An attempt was made to connect when the client is already connected or in the process of connecting.
-   `.notImplemented`:
    The requested feature or method is not yet implemented.
