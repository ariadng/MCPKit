/**
 * A reference to a resource or resource template definition.
 */
public struct ResourceReference: Codable {
    public var type: String = "ref/resource"
    
    /**
     * The URI of the resource. The URI can use any protocol; it is up to the server how to interpret it.
     */
    public var uri: String
    
    public init(uri: String) {
        self.uri = uri
    }
}
