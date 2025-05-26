/**
 * Union type of all requests that can be sent from the server to the client.
 */
public enum ServerRequest: Codable {
    case ping(PingRequest)
    case listRoots(ListRootsRequest)
    case createMessage(CreateMessageRequest)
    
    private enum CodingKeys: String, CodingKey {
        case method
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let method = try container.decode(String.self, forKey: .method)
        
        switch method {
        case "ping":
            self = .ping(try PingRequest(from: decoder))
        case "roots/list":
            self = .listRoots(try ListRootsRequest(from: decoder))
        case "sampling/createMessage":
            self = .createMessage(try CreateMessageRequest(from: decoder))
        default:
            throw DecodingError.dataCorruptedError(forKey: .method, in: container, debugDescription: "Unknown request method: \(method)")
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        switch self {
        case .ping(let request):
            try request.encode(to: encoder)
        case .listRoots(let request):
            try request.encode(to: encoder)
        case .createMessage(let request):
            try request.encode(to: encoder)
        }
    }
}
