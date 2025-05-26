/**
 * The server's response to a prompts/get request from the client.
 */
public struct GetPromptResult: Result, Codable {
    public var _meta: [String: AnyCodable]?
    
    /**
     * An optional human-readable description of the prompt.
     */
    public var description: String?
    
    /**
     * The messages that make up the prompt.
     */
    public var messages: [PromptMessage]
    
    public init(messages: [PromptMessage], description: String? = nil, _meta: [String: AnyCodable]? = nil) {
        self.messages = messages
        self.description = description
        self._meta = _meta
    }
}
