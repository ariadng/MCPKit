/**
 * Text provided to or from an LLM.
 */
public struct TextContent: Codable, Sendable {
    public var type: String = "text"
    
    /**
     * The text content of the message.
     */
    public var text: String
    
    /**
     * Optional annotations for the client.
     */
    public var annotations: Annotations?
    
    public init(text: String, annotations: Annotations? = nil) {
        self.text = text
        self.annotations = annotations
    }
}
