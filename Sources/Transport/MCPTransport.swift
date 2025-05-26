import Foundation

/// Represents the various states of a transport connection.
public enum TransportConnectionState: Sendable {
    /// The transport is disconnected. An optional `Error` can indicate the reason for disconnection.
    case disconnected(error: Error?)
    /// The transport is currently attempting to establish a connection.
    case connecting
    /// The transport is connected and ready to send/receive data.
    case connected
}

/// Defines the contract for transport mechanisms used by `MCPClient`.
///
/// `MCPTransport` abstracts the underlying communication channel (e.g., Stdio, WebSockets, HTTP streams),
/// allowing `MCPClient` to remain transport-agnostic. Concrete implementations of this protocol
/// will handle the specifics of connecting, sending, receiving, and managing the state of a
/// particular communication method.
public protocol MCPTransport: AnyObject, Sendable {
    /// An asynchronous stream that yields `Data` objects for incoming messages from the server.
    /// Each `Data` object should represent a complete, decodable message unit (e.g., a full JSON-RPC message).
    var incomingMessages: AsyncStream<Data> { get }

    /// An asynchronous stream that emits `TransportConnectionState` values whenever the
    /// transport's connection status changes.
    var stateStream: AsyncStream<TransportConnectionState> { get }

    /// Establishes the connection to the MCP server.
    ///
    /// This method should handle all necessary setup for the specific transport mechanism,
    /// such as opening a network connection or launching a subprocess.
    /// - Throws: An error if the connection cannot be established (e.g., network issues, process launch failure).
    func connect() async throws

    /// Sends raw, encoded message `Data` over the transport.
    ///
    /// Implementations are responsible for any necessary framing or encoding specific to the transport
    /// (e.g., adding Content-Length headers for Stdio, or handling WebSocket message types).
    /// - Parameter data: The `Data` object to be sent. This is expected to be an encoded JSON-RPC message.
    /// - Throws: An error if sending fails (e.g., connection lost, write error).
    func send(_ data: Data) async throws

    /// Closes the connection gracefully and cleans up any associated resources.
    ///
    /// This method should ensure that all resources are released and the transport is in a clean state.
    /// It should ideally not throw errors for cleanup failures but handle them internally (e.g., by logging).
    func disconnect() async
}
