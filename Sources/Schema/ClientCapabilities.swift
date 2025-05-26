/**
 * Capabilities a client may support. Known capabilities are defined here, in this schema, but this is not a closed set: any client can define its own, additional capabilities.
 */
public struct ClientCapabilities: Codable {
    /**
     * Experimental capabilities. These are not standardized and may change at any time.
     */
    public var experimental: [String: AnyCodable]?
    
    /**
     * Capabilities related to roots.
     */
    public var roots: RootsCapabilities?
    
    /**
     * Capabilities related to sampling.
     */
    public var sampling: AnyCodable?
    
    public init(experimental: [String: AnyCodable]? = nil, roots: RootsCapabilities? = nil, sampling: AnyCodable? = nil) {
        self.experimental = experimental
        self.roots = roots
        self.sampling = sampling
    }
    
    public struct RootsCapabilities: Codable {
        /**
         * Whether the client supports notifications for changes to the roots list.
         */
        public var listChanged: Bool?
        
        public init(listChanged: Bool? = nil) {
            self.listChanged = listChanged
        }
    }
}

/**
 * A type-erased Codable value.
 */
public struct AnyCodable: Codable {
    private let value: Any
    
    public init<T>(_ value: T) {
        self.value = value
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if container.decodeNil() {
            self.value = Optional<Any>.none as Any
        } else if let bool = try? container.decode(Bool.self) {
            self.value = bool
        } else if let int = try? container.decode(Int.self) {
            self.value = int
        } else if let double = try? container.decode(Double.self) {
            self.value = double
        } else if let string = try? container.decode(String.self) {
            self.value = string
        } else if let array = try? container.decode([AnyCodable].self) {
            self.value = array
        } else if let dictionary = try? container.decode([String: AnyCodable].self) {
            self.value = dictionary
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "AnyCodable value cannot be decoded")
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch self.value {
        case is NSNull, is Optional<Any>:
            try container.encodeNil()
        case let bool as Bool:
            try container.encode(bool)
        case let int as Int:
            try container.encode(int)
        case let double as Double:
            try container.encode(double)
        case let string as String:
            try container.encode(string)
        case let array as [Any]:
            try container.encode(array.map { AnyCodable($0) })
        case let dictionary as [String: Any]:
            try container.encode(dictionary.mapValues { AnyCodable($0) })
        default:
            let context = EncodingError.Context(codingPath: container.codingPath, debugDescription: "AnyCodable value cannot be encoded")
            throw EncodingError.invalidValue(self.value, context)
        }
    }
}
