/**
 * The server's response to a completion/complete request
 */
public struct CompleteResult: Result, Codable {
    public var _meta: [String: AnyCodable]?
    public var completion: Completion
    
    public init(completion: Completion, _meta: [String: AnyCodable]? = nil) {
        self.completion = completion
        self._meta = _meta
    }
    
    public struct Completion: Codable {
        /**
         * An array of completion values. Must not exceed 100 items.
         */
        public var values: [String]
        
        /**
         * The total number of completion options available. This can exceed the number of values actually sent in the response.
         */
        public var total: Int?
        
        /**
         * Indicates whether there are additional completion options beyond those provided in the current response, even if the exact total is unknown.
         */
        public var hasMore: Bool?
        
        public init(values: [String], total: Int? = nil, hasMore: Bool? = nil) {
            self.values = values
            self.total = total
            self.hasMore = hasMore
        }
    }
}
