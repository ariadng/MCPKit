/**
 * The contents of a resource, embedded into a prompt or tool call result.
 *
 * It is up to the client how best to render embedded resources for the benefit
 * of the LLM and/or the user.
 */
public struct EmbeddedResource: Codable {
    public var type: String = "resource"
    public var resource: ResourceType
    public var annotations: Annotations?
    
    public init(resource: ResourceType, annotations: Annotations? = nil) {
        self.resource = resource
        self.annotations = annotations
    }
    
    public enum ResourceType: Codable {
        case text(TextResourceContents)
        case blob(BlobResourceContents)
        
        private enum CodingKeys: String, CodingKey {
            case text, blob, uri
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            if container.contains(.text) {
                self = .text(try TextResourceContents(from: decoder))
            } else if container.contains(.blob) {
                self = .blob(try BlobResourceContents(from: decoder))
            } else {
                throw DecodingError.dataCorruptedError(forKey: .uri, in: container, debugDescription: "Unable to decode resource type")
            }
        }
        
        public func encode(to encoder: Encoder) throws {
            switch self {
            case .text(let contents):
                try contents.encode(to: encoder)
            case .blob(let contents):
                try contents.encode(to: encoder)
            }
        }
    }
}
