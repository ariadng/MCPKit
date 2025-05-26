/**
 * Describes the name and version of an MCP implementation.
 */
public struct Implementation: Codable {
    public var name: String
    public var version: String
    
    public init(name: String, version: String) {
        self.name = name
        self.version = version
    }
}
