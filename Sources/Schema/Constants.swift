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

public extension Constants {
    enum MCPMethods {
        public enum Sampling {
            /// Method name for a server to request the client to create a message in a sampling context.
            public static let createMessage = "sampling/createMessage"
        }
        // Future MCP method groups can be added here, for example:
        // public enum General {
        //     public static let initialize = "initialize"
        //     public static let initialized = "initialized"
        //     public static let shutdown = "shutdown"
        //     public static let exit = "exit"
        // }
        // public enum Workspace {
        //     public static let listRoots = "workspace/listRoots"
        // }
    }
}
