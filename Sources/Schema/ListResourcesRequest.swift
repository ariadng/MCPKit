/**
 * Sent from the client to request a list of resources the server has.
 */
public struct ListResourcesRequest: Request, PaginatedRequest, Codable {
    public var method: String = "resources/list"
    public var params: RequestParams?
    
    public init(cursor: Cursor? = nil) {
        if let cursor = cursor {
            var params = RequestParams()
            params["cursor"] = AnyCodable(cursor)
            self.params = params
        } else {
            self.params = nil
        }
    }
}
