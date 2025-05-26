/**
 * Audio provided to or from an LLM.
 */
public struct AudioContent: Codable {
    public var type: String = "audio"
    
    /**
     * The base64-encoded audio data.
     */
    public var data: String
    
    /**
     * The MIME type of the audio. Different providers may support different audio types.
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
