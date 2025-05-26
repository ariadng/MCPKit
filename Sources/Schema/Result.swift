/**
 * Base interface for all results.
 */
public protocol Result: Codable {
    var _meta: [String: AnyCodable]? { get set }
}

public struct ResultMeta: Codable {
    private var additionalProperties: [String: AnyCodable]
    
    public init(additionalProperties: [String: AnyCodable] = [:]) {
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
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DynamicCodingKeys.self)
        var properties = [String: AnyCodable]()
        
        for key in container.allKeys {
            let value = try container.decode(AnyCodable.self, forKey: key)
            properties[key.stringValue] = value
        }
        
        self.additionalProperties = properties
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: DynamicCodingKeys.self)
        
        for (key, value) in additionalProperties {
            try container.encode(value, forKey: DynamicCodingKeys(stringValue: key)!)
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
