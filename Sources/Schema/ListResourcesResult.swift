/**
 * The server's response to a resources/list request from the client.
 */
public struct ListResourcesResult: Result, PaginatedResult, Codable {
    public var _meta: [String: AnyCodable]?
    public var nextCursor: Cursor?
    public var resources: [Resource]
    
    public init(resources: [Resource], nextCursor: Cursor? = nil, _meta: [String: AnyCodable]? = nil) {
        self.resources = resources
        self.nextCursor = nextCursor
        self._meta = _meta
    }
}
