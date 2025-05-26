/**
 * Union type of all result types that can be returned from the client to the server.
 */
public enum ClientResult: Codable {
    case empty(EmptyResult)
    case listRoots(ListRootsResult)
    case createMessage(CreateMessageResult)
    
    private enum CodingKeys: String, CodingKey {
        case roots
        case model
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if container.contains(.roots) {
            self = .listRoots(try ListRootsResult(from: decoder))
        } else if container.contains(.model) {
            self = .createMessage(try CreateMessageResult(from: decoder))
        } else {
            self = .empty(try EmptyResult(from: decoder))
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        switch self {
        case .empty(let result):
            try result.encode(to: encoder)
        case .listRoots(let result):
            try result.encode(to: encoder)
        case .createMessage(let result):
            try result.encode(to: encoder)
        }
    }
}
