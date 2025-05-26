/**
 * Sent from the client to the server, to read a specific resource URI.
 */
public struct ReadResourceRequest: Request, Codable {
    public var method: String = "resources/read"
    public var params: RequestParams?
    
    public struct Params: Codable {
        /**
         * The URI of the resource to read. The URI can use any protocol; it is up to the server how to interpret it.
         */
        public var uri: String
        
        public init(uri: String) {
            self.uri = uri
        }
    }
    
    public init(uri: String) {
        var params = RequestParams()
        params["uri"] = AnyCodable(uri)
        self.params = params
    }
}
