/**
 * Describes an argument that a prompt can accept.
 */
public struct PromptArgument: Codable {
    /**
     * The name of the argument.
     */
    public var name: String
    
    /**
     * An optional human-readable description of the argument.
     */
    public var description: String?
    
    /**
     * Whether this argument is required.
     */
    public var required: Bool?
    
    public init(name: String, description: String? = nil, required: Bool? = nil) {
        self.name = name
        self.description = description
        self.required = required
    }
}
