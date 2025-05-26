/**
 * An image provided to or from an LLM.
 */
public struct ImageContent: Codable {
    public var type: String = "image"
    
    /**
     * The base64-encoded image data.
     */
    public var data: String
    
    /**
     * The MIME type of the image. Different providers may support different image types.
     */
    public var mimeType: String
    
    /**
     * Optional annotations for the client.
     */
    public var annotations: Annotations?
    
    public init(data: String, mimeType: String, annotations: Annotations? = nil) {
        self.data = data
        self.mimeType = mimeType
        self.annotations = annotations
    }
}
