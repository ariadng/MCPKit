/**
 * Union type of all notifications that can be sent from the server to the client.
 */
public enum ServerNotification: Codable {
    case cancelled(CancelledNotification)
    case progress(ProgressNotification)
    case resourceListChanged(ResourceListChangedNotification)
    case resourceUpdated(ResourceUpdatedNotification)
    case promptListChanged(PromptListChangedNotification)
    case toolListChanged(ToolListChangedNotification)
    case loggingMessage(LoggingMessageNotification)
    
    private enum CodingKeys: String, CodingKey {
        case method
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let method = try container.decode(String.self, forKey: .method)
        
        switch method {
        case "notifications/cancelled":
            self = .cancelled(try CancelledNotification(from: decoder))
        case "notifications/progress":
            self = .progress(try ProgressNotification(from: decoder))
        case "notifications/resources/list_changed":
            self = .resourceListChanged(try ResourceListChangedNotification(from: decoder))
        case "notifications/resources/updated":
            self = .resourceUpdated(try ResourceUpdatedNotification(from: decoder))
        case "notifications/prompts/list_changed":
            self = .promptListChanged(try PromptListChangedNotification(from: decoder))
        case "notifications/tools/list_changed":
            self = .toolListChanged(try ToolListChangedNotification(from: decoder))
        case "notifications/message":
            self = .loggingMessage(try LoggingMessageNotification(from: decoder))
        default:
            throw DecodingError.dataCorruptedError(forKey: .method, in: container, debugDescription: "Unknown notification method: \(method)")
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        switch self {
        case .cancelled(let notification):
            try notification.encode(to: encoder)
        case .progress(let notification):
            try notification.encode(to: encoder)
        case .resourceListChanged(let notification):
            try notification.encode(to: encoder)
        case .resourceUpdated(let notification):
            try notification.encode(to: encoder)
        case .promptListChanged(let notification):
            try notification.encode(to: encoder)
        case .toolListChanged(let notification):
            try notification.encode(to: encoder)
        case .loggingMessage(let notification):
            try notification.encode(to: encoder)
        }
    }
}
