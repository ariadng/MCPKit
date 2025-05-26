/**
 * A notification from the server to the client, informing it that a resource has changed and may need to be read again. This should only be sent if the client previously sent a resources/subscribe request.
 */
public struct ResourceUpdatedNotification: Notification, Codable {
    public var method: String = "notifications/resources/updated"
    public var params: NotificationParams?
    
    public struct Params: Codable {
        /**
         * The URI of the resource that has been updated. This might be a sub-resource of the one that the client actually subscribed to.
         */
        public var uri: String
        
        public init(uri: String) {
            self.uri = uri
        }
    }
    
    public init(uri: String) {
        var params = NotificationParams()
        params["uri"] = AnyCodable(uri)
        self.params = params
    }
}
