/**
 * A uniquely identifying ID for a request in JSON-RPC.
 */
public enum RequestId: Codable, Hashable {
    case string(String)
    case number(Int)
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let stringValue = try? container.decode(String.self) {
            self = .string(stringValue)
        } else if let intValue = try? container.decode(Int.self) {
            self = .number(intValue)
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "RequestId must be a string or number")
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch self {
        case .string(let value):
            try container.encode(value)
        case .number(let value):
            try container.encode(value)
        }
    }
    
    /// Provides a string representation of the RequestId.
    public var asString: String {
        switch self {
        case .string(let s):
            return s
        case .number(let n):
            return String(n)
        }
    }
}
