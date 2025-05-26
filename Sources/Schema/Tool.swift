/**
 * Definition for a tool the client can call.
 */
public struct Tool: Codable {
    /**
     * The name of the tool.
     */
    public var name: String
    
    /**
     * An optional human-readable description of the tool.
     */
    public var description: String?
    
    /**
     * The schema for the input to the tool.
     */
    public var inputSchema: InputSchema
    
    /**
     * Optional additional tool information.
     */
    public var annotations: ToolAnnotations?
    
    public init(
        name: String,
        description: String? = nil,
        inputSchema: InputSchema,
        annotations: ToolAnnotations? = nil
    ) {
        self.name = name
        self.description = description
        self.inputSchema = inputSchema
        self.annotations = annotations
    }
    
    public struct InputSchema: Codable {
        public var type: String = "object"
        public var properties: [String: AnyCodable]?
        public var required: [String]?
        
        public init(properties: [String: AnyCodable]? = nil, required: [String]? = nil) {
            self.properties = properties
            self.required = required
        }
    }
}
