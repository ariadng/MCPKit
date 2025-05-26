/**
 * Sent from the client to request resources/updated notifications from the server whenever a particular resource changes.
 */
public struct SubscribeRequest: Request, Codable {
    public var method: String = "resources/subscribe"
    public var params: RequestParams?
    
    public struct Params: Codable {
        /**
         * The URI of the resource to subscribe to. The URI can use any protocol; it is up to the server how to interpret it.
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
