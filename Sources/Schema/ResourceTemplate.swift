/**
 * A template description for resources available on the server.
 */
public struct ResourceTemplate: Codable {
    /**
     * A template for the URI of the resource. The URI can use any protocol; it is up to the server how to interpret it.
     * The template may contain placeholders in the form {name} which can be replaced with values to generate a valid URI.
     */
    public var uriTemplate: String
    
    /**
     * A human-readable name for the resource template.
     */
    public var name: String
    
    /**
     * An optional human-readable description of the resource template.
     */
    public var description: String?
    
    /**
     * The MIME type of resources generated from this template, if known.
     */
    public var mimeType: String?
    
    /**
     * Optional annotations for the client.
     */
    public var annotations: Annotations?
    
    public init(
        uriTemplate: String,
        name: String,
        description: String? = nil,
        mimeType: String? = nil,
        annotations: Annotations? = nil
    ) {
        self.uriTemplate = uriTemplate
        self.name = name
        self.description = description
        self.mimeType = mimeType
        self.annotations = annotations
    }
}
