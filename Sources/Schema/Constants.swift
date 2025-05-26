/**
 * Constants for the Model Context Protocol
 */
public enum Constants {
    /// Latest protocol version
    public static let LATEST_PROTOCOL_VERSION = "2025-03-26"
    
    /// JSON-RPC version
    public static let JSONRPC_VERSION = "2.0"
    
    // Standard JSON-RPC error codes
    public static let PARSE_ERROR = -32700
    public static let INVALID_REQUEST = -32600
    public static let METHOD_NOT_FOUND = -32601
    public static let INVALID_PARAMS = -32602
    public static let INTERNAL_ERROR = -32603
}
