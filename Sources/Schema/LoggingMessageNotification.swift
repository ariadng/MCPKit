import Foundation

/**
 * Notification of a log message passed from server to client. If no logging/setLevel request has been sent from the client, the server MAY decide which messages to send automatically.
 */
public struct LoggingMessageNotification: Notification, Codable {
    public var method: String = "notifications/message"
    public var params: NotificationParams?
    
    public struct Params: Codable {
        /**
         * The severity of this log message.
         */
        public var level: LoggingLevel
        
        /**
         * An optional name of the logger issuing this message.
         */
        public var logger: String?
        
        /**
         * The data to be logged, such as a string message or an object. Any JSON serializable type is allowed here.
         */
        public var data: AnyCodable
        
        public init(level: LoggingLevel, logger: String? = nil, data: AnyCodable) {
            self.level = level
            self.logger = logger
            self.data = data
        }
    }
    
    public init(params: Params) {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(params),
           let jsonObject = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let jsonData = try? JSONSerialization.data(withJSONObject: jsonObject),
           (try? JSONDecoder().decode(AnyCodable.self, from: jsonData)) != nil {
            var notificationParams = NotificationParams()
            for (key, value) in jsonObject {
                notificationParams[key] = AnyCodable(value)
            }
            self.params = notificationParams
        }
    }
}
