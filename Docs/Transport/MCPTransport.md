# MCPTransport

## Overview

This file defines the core components of the transport layer for the MCPKit. It includes the `TransportConnectionState` enum, which represents the various states of a transport connection, and the `MCPTransport` protocol, which outlines the contract for all transport mechanism implementations. The primary goal is to abstract the underlying communication channel, allowing the `MCPClient` to be transport-agnostic.

## `TransportConnectionState` Enum

Represents the various states of a transport connection.

### Definition
```swift
public enum TransportConnectionState: Sendable {
    case disconnected(error: Error?)
    case connecting
    case connected
}
```

### Cases
-   `disconnected(error: Error?)`: The transport is disconnected. An optional `Error` can indicate the reason for disconnection.
-   `connecting`: The transport is currently attempting to establish a connection.
-   `connected`: The transport is connected and ready to send/receive data.

## `MCPTransport` Protocol

Defines the contract for transport mechanisms used by `MCPClient`. Implementations of this protocol handle the specifics of connecting, sending, receiving, and managing the state of a particular communication method.

### Definition
```swift
public protocol MCPTransport: AnyObject, Sendable {
    var incomingMessages: AsyncStream<Data> { get }
    var stateStream: AsyncStream<TransportConnectionState> { get }

    func connect() async throws
    func send(_ data: Data) async throws
    func disconnect() async
}
```

### Conformance
-   `AnyObject`: The protocol can only be adopted by class types.
-   `Sendable`: Instances of conforming types can be safely used in concurrent code.

### Properties

-   **`incomingMessages: AsyncStream<Data>`**
    -   An asynchronous stream that yields `Data` objects for incoming messages from the server.
    -   Each `Data` object should represent a complete, decodable message unit (e.g., a full JSON-RPC message).

-   **`stateStream: AsyncStream<TransportConnectionState>`**
    -   An asynchronous stream that emits `TransportConnectionState` values whenever the transport's connection status changes.

### Methods

-   **`connect() async throws`**
    -   Establishes the connection to the MCP server.
    -   This method should handle all necessary setup for the specific transport mechanism, such as opening a network connection or launching a subprocess.
    -   **Throws**: An error if the connection cannot be established (e.g., network issues, process launch failure).

-   **`send(_ data: Data) async throws`**
    -   Sends raw, encoded message `Data` over the transport.
    -   Implementations are responsible for any necessary framing or encoding specific to the transport (e.g., adding Content-Length headers for Stdio, or handling WebSocket message types).
    -   **Parameter `data`**: The `Data` object to be sent. This is expected to be an encoded JSON-RPC message.
    -   **Throws**: An error if sending fails (e.g., connection lost, write error).

-   **`disconnect() async`**
    -   Closes the connection gracefully and cleans up any associated resources.
    -   This method should ensure that all resources are released and the transport is in a clean state. It should ideally not throw errors for cleanup failures but handle them internally (e.g., by logging).
