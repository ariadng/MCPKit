/**
 * Base interface for all requests.
 */
public protocol Request: Codable {
    var method: String { get }
    var params: RequestParams? { get }
}

public struct RequestParams: Codable {
    public var _meta: RequestMeta?
    private var additionalProperties: [String: AnyCodable]
    
    public init(_meta: RequestMeta? = nil, additionalProperties: [String: AnyCodable] = [:]) {
        self._meta = _meta
        self.additionalProperties = additionalProperties
    }
    
    public subscript(key: String) -> AnyCodable? {
        get {
            return additionalProperties[key]
        }
        set {
            additionalProperties[key] = newValue
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case _meta
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self._meta = try container.decodeIfPresent(RequestMeta.self, forKey: ._meta)
        
        let dynamicContainer = try decoder.container(keyedBy: DynamicCodingKeys.self)
        var properties = [String: AnyCodable]()
        
        for key in dynamicContainer.allKeys {
            if key.stringValue != "_meta" {
                let value = try dynamicContainer.decode(AnyCodable.self, forKey: key)
                properties[key.stringValue] = value
            }
        }
        
        self.additionalProperties = properties
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(_meta, forKey: ._meta)
        
        var dynamicContainer = encoder.container(keyedBy: DynamicCodingKeys.self)
        
        for (key, value) in additionalProperties {
            try dynamicContainer.encode(value, forKey: DynamicCodingKeys(stringValue: key)!)
        }
    }
    
    private struct DynamicCodingKeys: CodingKey {
        var stringValue: String
        var intValue: Int?
        
        init?(stringValue: String) {
            self.stringValue = stringValue
            self.intValue = nil
        }
        
        init?(intValue: Int) {
            self.stringValue = "\(intValue)"
            self.intValue = intValue
        }
    }
}

public struct RequestMeta: Codable {
    /**
     * If specified, the caller is requesting out-of-band progress notifications for this request (as represented by notifications/progress).
     * The value of this parameter is an opaque token that will be attached to any subsequent notifications.
     * The receiver is not obligated to provide these notifications.
     */
    public var progressToken: ProgressToken?
    
    public init(progressToken: ProgressToken? = nil) {
        self.progressToken = progressToken
    }
}
