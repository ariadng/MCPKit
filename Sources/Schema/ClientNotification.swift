/**
 * Union type of all notifications that can be sent from the client to the server.
 */
public enum ClientNotification: Codable {
    case cancelled(CancelledNotification)
    case initialized(InitializedNotification)
    case rootsListChanged(RootsListChangedNotification)
    
    private enum CodingKeys: String, CodingKey {
        case method
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let method = try container.decode(String.self, forKey: .method)
        
        switch method {
        case "cancelled":
            self = .cancelled(try CancelledNotification(from: decoder))
        case "initialized":
            self = .initialized(try InitializedNotification(from: decoder))
        case "roots/listChanged":
            self = .rootsListChanged(try RootsListChangedNotification(from: decoder))
        default:
            throw DecodingError.dataCorruptedError(forKey: .method, in: container, debugDescription: "Unknown notification method: \(method)")
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        switch self {
        case .cancelled(let notification):
            try notification.encode(to: encoder)
        case .initialized(let notification):
            try notification.encode(to: encoder)
        case .rootsListChanged(let notification):
            try notification.encode(to: encoder)
        }
    }
}
