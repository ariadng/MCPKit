/**
 * A JSON-RPC batch request, as described in https://www.jsonrpc.org/specification#batch.
 */
public enum JSONRPCBatchRequestItem: Codable {
    case request(JSONRPCRequest)
    case notification(JSONRPCNotification)
    
    private enum CodingKeys: String, CodingKey {
        case id
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if container.contains(.id) {
            self = .request(try JSONRPCRequest(from: decoder))
        } else {
            self = .notification(try JSONRPCNotification(from: decoder))
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        switch self {
        case .request(let request):
            try request.encode(to: encoder)
        case .notification(let notification):
            try notification.encode(to: encoder)
        }
    }
}

public typealias JSONRPCBatchRequest = [JSONRPCBatchRequestItem]
