/**
 * The server's response to a prompts/list request from the client.
 */
public struct ListPromptsResult: Result, PaginatedResult, Codable {
    public var _meta: [String: AnyCodable]?
    public var nextCursor: Cursor?
    public var prompts: [Prompt]
    
    public init(prompts: [Prompt], nextCursor: Cursor? = nil, _meta: [String: AnyCodable]? = nil) {
        self.prompts = prompts
        self.nextCursor = nextCursor
        self._meta = _meta
    }
}
