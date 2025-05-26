# DisconnectReason

**File:** `Sources/MCPClient/DisconnectReason.swift`

The `DisconnectReason` enum represents the various reasons why an `MCPClient` might disconnect from a server. This is used by `ConnectionState` to provide more context about a disconnection.

## Cases

-   `.normal`:
    Indicates a normal, intentional disconnection initiated by the client or a graceful shutdown.
-   `.transportError(Error)`:
    Indicates that the disconnection was due to an error reported by the underlying transport layer. The associated `Error` value provides details about the transport failure.
-   `.connectionFailed(Error)`:
    Indicates that an attempt to establish a connection failed. The associated `Error` value provides details about the connection failure.
-   `.disconnecting`:
    Indicates the client is in the process of disconnecting. This state might be observed if a new disconnect reason arrives while already in the process of a previous disconnect.

The enum conforms to `Equatable` for state comparison.
