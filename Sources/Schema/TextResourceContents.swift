/**
 * Text contents of a resource.
 */
public struct TextResourceContents: ResourceContents, Codable {
    /**
     * The URI of the resource. The URI can use any protocol; it is up to the server how to interpret it.
     */
    public var uri: String
    
    /**
     * The MIME type of the resource, if known.
     */
    public var mimeType: String?
    
    /**
     * The text content of the resource.
     */
    public var text: String
    
    public init(uri: String, text: String, mimeType: String? = nil) {
        self.uri = uri
        self.text = text
        self.mimeType = mimeType
    }
}
