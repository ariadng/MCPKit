import Foundation

/**
 * An out-of-band notification used to inform the receiver of a progress update for a long-running request.
 */
public struct ProgressNotification: Notification, Codable {
    public var method: String = "notifications/progress"
    public var params: NotificationParams?
    
    public struct Params: Codable {
        /**
         * The progress token which was given in the initial request, used to associate this notification with the request that is proceeding.
         */
        public var progressToken: ProgressToken
        
        /**
         * The progress thus far. This should increase every time progress is made, even if the total is unknown.
         */
        public var progress: Int
        
        /**
         * Total number of items to process (or total progress required), if known.
         */
        public var total: Int?
        
        /**
         * An optional message describing the current progress.
         */
        public var message: String?
        
        public init(progressToken: ProgressToken, progress: Int, total: Int? = nil, message: String? = nil) {
            self.progressToken = progressToken
            self.progress = progress
            self.total = total
            self.message = message
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
