/**
 * A known resource that the server is capable of reading.
 */
public struct Resource: Codable {
    /**
     * The URI of the resource. The URI can use any protocol; it is up to the server how to interpret it.
     */
    public var uri: String
    
    /**
     * A human-readable name for the resource.
     */
    public var name: String
    
    /**
     * An optional human-readable description of the resource.
     */
    public var description: String?
    
    /**
     * The MIME type of the resource, if known.
     */
    public var mimeType: String?
    
    /**
     * Optional annotations for the client.
     */
    public var annotations: Annotations?
    
    /**
     * The size of the resource in bytes, if known.
     */
    public var size: Int?
    
    public init(
        uri: String,
        name: String,
        description: String? = nil,
        mimeType: String? = nil,
        annotations: Annotations? = nil,
        size: Int? = nil
    ) {
        self.uri = uri
        self.name = name
        self.description = description
        self.mimeType = mimeType
        self.annotations = annotations
        self.size = size
    }
}
