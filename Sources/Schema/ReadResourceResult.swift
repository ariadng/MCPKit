/**
 * The server's response to a resources/read request from the client.
 */
public struct ReadResourceResult: Result, Codable {
    public var _meta: [String: AnyCodable]?
    public var contents: [ResourceContentsType]
    
    public init(contents: [ResourceContentsType], _meta: [String: AnyCodable]? = nil) {
        self.contents = contents
        self._meta = _meta
    }
    
    public enum ResourceContentsType: Codable {
        case text(TextResourceContents)
        case blob(BlobResourceContents)
        
        private enum CodingKeys: String, CodingKey {
            case text, blob
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            if let textContents = try? container.decode(TextResourceContents.self, forKey: .text) {
                self = .text(textContents)
            } else if let blobContents = try? container.decode(BlobResourceContents.self, forKey: .blob) {
                self = .blob(blobContents)
            } else {
                throw DecodingError.dataCorruptedError(forKey: .text, in: container, debugDescription: "Unable to decode resource contents")
            }
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            
            switch self {
            case .text(let contents):
                try container.encode(contents, forKey: .text)
            case .blob(let contents):
                try container.encode(contents, forKey: .blob)
            }
        }
    }
}
