# ConnectionState

**File:** `Sources/MCPClient/ConnectionState.swift`

The `ConnectionState` enum represents the various connection states of the `MCPClient`. It helps in managing and understanding the client's current status with respect to the server.

## Cases

-   `.disconnected(reason: DisconnectReason?)`:
    The client is not connected to the server. The associated `DisconnectReason?` optionally provides context for why the client is disconnected (e.g., normal shutdown, transport error).
-   `.connecting`:
    The client is currently attempting to establish a connection with the server.
-   `.connected`:
    The client has successfully established a connection with the server and is ready to send/receive messages.
-   `.disconnecting`:
    The client is in the process of disconnecting from the server.

The enum conforms to `Equatable` for state comparison, taking into account the associated `DisconnectReason` for the `.disconnected` state.
