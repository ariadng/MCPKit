/**
 * Binary contents of a resource.
 */
public struct BlobResourceContents: ResourceContents, Codable {
    /**
     * The URI of the resource. The URI can use any protocol; it is up to the server how to interpret it.
     */
    public var uri: String
    
    /**
     * The MIME type of the resource, if known.
     */
    public var mimeType: String?
    
    /**
     * The base64-encoded binary content of the resource.
     */
    public var blob: String
    
    public init(uri: String, blob: String, mimeType: String? = nil) {
        self.uri = uri
        self.blob = blob
        self.mimeType = mimeType
    }
}
