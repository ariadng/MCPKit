/**
 * The server's response to a resources/templates/list request from the client.
 */
public struct ListResourceTemplatesResult: Result, PaginatedResult, Codable {
    public var _meta: [String: AnyCodable]?
    public var nextCursor: Cursor?
    public var resourceTemplates: [ResourceTemplate]
    
    public init(resourceTemplates: [ResourceTemplate], nextCursor: Cursor? = nil, _meta: [String: AnyCodable]? = nil) {
        self.resourceTemplates = resourceTemplates
        self.nextCursor = nextCursor
        self._meta = _meta
    }
}
