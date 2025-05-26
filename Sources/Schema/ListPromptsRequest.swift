/**
 * Sent from the client to request a list of prompts and prompt templates the server has.
 */
public struct ListPromptsRequest: Request, PaginatedRequest, Codable {
    public var method: String = "prompts/list"
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
