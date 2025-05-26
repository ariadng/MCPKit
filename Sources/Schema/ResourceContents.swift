/**
 * The contents of a specific resource or sub-resource.
 */
public protocol ResourceContents: Codable {
    /**
     * The URI of the resource. The URI can use any protocol; it is up to the server how to interpret it.
     */
    var uri: String { get set }
    
    /**
     * The MIME type of the resource, if known.
     */
    var mimeType: String? { get set }
}
