/**
 * The server's response to a tool call.
 *
 * Any errors that originate from the tool SHOULD be reported inside the result
 * object, with `isError` set to true, _not_ as an MCP protocol-level error
 * response. Otherwise, the LLM would not be able to see that an error occurred
 * and self-correct.
 *
 * However, any errors in _finding_ the tool, an error indicating that the
 * server does not support tool calls, or any other exceptional conditions,
 * should be reported as an MCP error response.
 */
public struct CallToolResult: Result, Codable {
    public var _meta: [String: AnyCodable]?
    public var content: [ContentType]
    public var isError: Bool?
    
    public init(content: [ContentType], isError: Bool? = nil, _meta: [String: AnyCodable]? = nil) {
        self.content = content
        self.isError = isError
        self._meta = _meta
    }
    
    public enum ContentType: Codable {
        case text(TextContent)
        case image(ImageContent)
        case audio(AudioContent)
        case resource(EmbeddedResource)
        
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
            case "resource":
                self = .resource(try EmbeddedResource(from: decoder))
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
            case .resource(let content):
                try content.encode(to: encoder)
            }
        }
    }
}
