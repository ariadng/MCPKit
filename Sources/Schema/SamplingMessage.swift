/**
 * Describes a message issued to or received from an LLM API.
 */
public struct SamplingMessage: Codable {
    public var role: Role
    public var content: MessageContent
    
    public init(role: Role, content: MessageContent) {
        self.role = role
        self.content = content
    }
    
    public enum MessageContent: Codable {
        case text(TextContent)
        case image(ImageContent)
        case audio(AudioContent)
        
        private enum CodingKeys: String, CodingKey {
            case type
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let type = try container.decode(String.self, forKey: .type)
            
            switch type {
            case "text":
                self = .text(try TextContent(from: decoder))
            case "image":
                self = .image(try ImageContent(from: decoder))
            case "audio":
                self = .audio(try AudioContent(from: decoder))
            default:
                throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "Unknown content type: \(type)")
            }
        }
        
        public func encode(to encoder: Encoder) throws {
            switch self {
            case .text(let content):
                try content.encode(to: encoder)
            case .image(let content):
                try content.encode(to: encoder)
            case .audio(let content):
                try content.encode(to: encoder)
            }
        }
    }
}
