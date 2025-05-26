/**
 * This notification can be sent by either side to indicate that it is cancelling a previously-issued request.
 *
 * The request SHOULD still be in-flight, but due to communication latency, it is always possible that this notification MAY arrive after the request has already finished.
 *
 * This notification indicates that the result will be unused, so any associated processing SHOULD cease.
 *
 * A client MUST NOT attempt to cancel its `initialize` request.
 */
public struct CancelledNotification: Notification, Codable {
    public var method: String = "notifications/cancelled"
    public var params: NotificationParams?
    
    public struct Params: Codable {
        /**
         * The ID of the request to cancel.
         *
         * This MUST correspond to the ID of a request previously issued in the same direction.
         */
        public var requestId: RequestId
        
        /**
         * An optional string describing the reason for the cancellation. This MAY be logged or presented to the user.
         */
        public var reason: String?
        
        public init(requestId: RequestId, reason: String? = nil) {
            self.requestId = requestId
            self.reason = reason
        }
    }
    
    public init(params: Params) {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(params),
           let jsonObject = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let jsonData = try? JSONSerialization.data(withJSONObject: jsonObject),
           let anyCodable = try? JSONDecoder().decode(AnyCodable.self, from: jsonData) {
            var notificationParams = NotificationParams()
            for (key, value) in jsonObject {
                notificationParams[key] = AnyCodable(value)
            }
            self.params = notificationParams
        }
    }
}
