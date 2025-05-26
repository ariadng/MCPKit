/**
 * The server's response to a tools/list request from the client.
 */
public struct ListToolsResult: Result, PaginatedResult, Codable {
    public var _meta: [String: AnyCodable]?
    public var nextCursor: Cursor?
    public var tools: [Tool]
    
    public init(tools: [Tool], nextCursor: Cursor? = nil, _meta: [String: AnyCodable]? = nil) {
        self.tools = tools
        self.nextCursor = nextCursor
        self._meta = _meta
    }
}
