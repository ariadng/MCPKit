/**
 * Represents a root directory or file that the server can operate on.
 */
public struct Root: Codable {
    /**
     * The URI of the root. The URI can use any protocol; it is up to the server how to interpret it.
     */
    public var uri: String
    
    /**
     * A human-readable name for the root.
     */
    public var name: String?
    
    public init(uri: String, name: String? = nil) {
        self.uri = uri
        self.name = name
    }
}
