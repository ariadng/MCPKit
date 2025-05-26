/**
 * A prompt or prompt template that the server offers.
 */
public struct Prompt: Codable {
    /**
     * The name of the prompt or prompt template.
     */
    public var name: String
    
    /**
     * An optional human-readable description of the prompt.
     */
    public var description: String?
    
    /**
     * The arguments that this prompt template accepts, if any.
     */
    public var arguments: [PromptArgument]?
    
    public init(name: String, description: String? = nil, arguments: [PromptArgument]? = nil) {
        self.name = name
        self.description = description
        self.arguments = arguments
    }
}
