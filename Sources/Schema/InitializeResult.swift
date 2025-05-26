/**
 * After receiving an initialize request from the client, the server sends this response.
 */
public struct InitializeResult: Result, Codable {
    public var _meta: [String: AnyCodable]?
    
    /**
     * The version of the Model Context Protocol that the server wants to use. 
     * This may not match the version that the client requested. 
     * If the client cannot support this version, it MUST disconnect.
     */
    public var protocolVersion: String
    
    /**
     * The server's capabilities.
     */
    public var capabilities: ServerCapabilities
    
    /**
     * Information about the server implementation.
     */
    public var serverInfo: Implementation
    
    /**
     * Instructions describing how to use the server and its features.
     *
     * This can be used by clients to improve the LLM's understanding of available tools, resources, etc. 
     * It can be thought of like a "hint" to the model. For example, this information MAY be added to the system prompt.
     */
    public var instructions: String?
    
    public init(
        protocolVersion: String,
        capabilities: ServerCapabilities,
        serverInfo: Implementation,
        instructions: String? = nil,
        _meta: [String: AnyCodable]? = nil
    ) {
        self.protocolVersion = protocolVersion
        self.capabilities = capabilities
        self.serverInfo = serverInfo
        self.instructions = instructions
        self._meta = _meta
    }
}
