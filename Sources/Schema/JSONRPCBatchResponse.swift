/**
 * A JSON-RPC batch response, as described in https://www.jsonrpc.org/specification#batch.
 */
public enum JSONRPCBatchResponseItem: Codable {
    case response(JSONRPCResponse)
    case error(JSONRPCError)
    
    private enum CodingKeys: String, CodingKey {
        case result
        case error
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if container.contains(.result) {
            self = .response(try JSONRPCResponse(from: decoder))
        } else if container.contains(.error) {
            self = .error(try JSONRPCError(from: decoder))
        } else {
            throw DecodingError.dataCorruptedError(forKey: .result, in: container, debugDescription: "Invalid JSON-RPC response")
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        switch self {
        case .response(let response):
            try response.encode(to: encoder)
        case .error(let error):
            try error.encode(to: encoder)
        }
    }
}

public typealias JSONRPCBatchResponse = [JSONRPCBatchResponseItem]
