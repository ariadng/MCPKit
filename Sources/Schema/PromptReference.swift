/**
 * Identifies a prompt.
 */
public struct PromptReference: Codable {
    public var type: String = "ref/prompt"
    
    /**
     * The name of the prompt.
     */
    public var name: String
    
    public init(name: String) {
        self.name = name
    }
}
