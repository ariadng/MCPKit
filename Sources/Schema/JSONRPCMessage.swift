/**
 * Refers to any valid JSON-RPC object that can be decoded off the wire, or encoded to be sent.
 */
public enum JSONRPCMessage: Codable {
    case request(JSONRPCRequest)
    case notification(JSONRPCNotification)
    case batchRequest(JSONRPCBatchRequest)
    case response(JSONRPCResponse)
    case error(JSONRPCError)
    case batchResponse(JSONRPCBatchResponse)
    
    private enum CodingKeys: String, CodingKey {
        case jsonrpc
        case id
        case method
        case result
        case error
    }
    
    public init(from decoder: Decoder) throws {
        // Try to decode as a single object first
        if let container = try? decoder.container(keyedBy: CodingKeys.self) {
            // Check if it's a request, notification, response, or error
            if container.contains(.method) {
                if container.contains(.id) {
                    self = .request(try JSONRPCRequest(from: decoder))
                } else {
                    self = .notification(try JSONRPCNotification(from: decoder))
                }
            } else if container.contains(.result) {
                self = .response(try JSONRPCResponse(from: decoder))
            } else if container.contains(.error) {
                self = .error(try JSONRPCError(from: decoder))
            } else {
                throw DecodingError.dataCorruptedError(forKey: .jsonrpc, in: container, debugDescription: "Invalid JSON-RPC message")
            }
        } else {
            // Try to decode as an array (batch)
            let container = try decoder.singleValueContainer()
            
            // Check if it's a batch request or batch response
            if let batchRequest = try? container.decode(JSONRPCBatchRequest.self) {
                self = .batchRequest(batchRequest)
            } else if let batchResponse = try? container.decode(JSONRPCBatchResponse.self) {
                self = .batchResponse(batchResponse)
            } else {
                throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid JSON-RPC message")
            }
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        switch self {
        case .request(let request):
            try request.encode(to: encoder)
        case .notification(let notification):
            try notification.encode(to: encoder)
        case .batchRequest(let batchRequest):
            var container = encoder.singleValueContainer()
            try container.encode(batchRequest)
        case .response(let response):
            try response.encode(to: encoder)
        case .error(let error):
            try error.encode(to: encoder)
        case .batchResponse(let batchResponse):
            var container = encoder.singleValueContainer()
            try container.encode(batchResponse)
        }
    }
}
