/**
 * Base interface for all notifications.
 */
public protocol Notification: Codable {
    var method: String { get }
    var params: NotificationParams? { get }
}

public struct NotificationParams: Codable {
    /**
     * This parameter name is reserved by MCP to allow clients and servers to attach additional metadata to their notifications.
     */
    public var _meta: [String: AnyCodable]?
    private var additionalProperties: [String: AnyCodable]
    
    public init(_meta: [String: AnyCodable]? = nil, additionalProperties: [String: AnyCodable] = [:]) {
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
        self._meta = try container.decodeIfPresent([String: AnyCodable].self, forKey: ._meta)
        
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
