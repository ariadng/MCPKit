/**
 * Optional annotations for the client. The client can use annotations to inform how objects are used or displayed
 */
public struct Annotations: Codable {
    /**
     * Describes who the intended customer of this object or data is.
     *
     * It can include multiple entries to indicate content useful for multiple audiences (e.g., `["user", "assistant"]`).
     */
    public var audience: [Role]?
    
    /**
     * Describes how important this data is for operating the server.
     *
     * A value of 1 means "most important," and indicates that the data is
     * effectively required, while 0 means "least important," and indicates that
     * the data is entirely optional.
     */
    public var priority: Double?
    
    public init(audience: [Role]? = nil, priority: Double? = nil) {
        self.audience = audience
        self.priority = priority
    }
}
