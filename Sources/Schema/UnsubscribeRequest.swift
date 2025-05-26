/**
 * Sent from the client to request cancellation of resources/updated notifications from the server. This should follow a previous resources/subscribe request.
 */
public struct UnsubscribeRequest: Request, Codable {
    public var method: String = "resources/unsubscribe"
    public var params: RequestParams?
    
    public struct Params: Codable {
        /**
         * The URI of the resource to unsubscribe from.
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
