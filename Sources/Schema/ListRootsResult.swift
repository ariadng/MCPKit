/**
 * The client's response to a roots/list request from the server.
 * This result contains an array of Root objects, each representing a root directory
 * or file that the server can operate on.
 */
public struct ListRootsResult: Result, Codable {
    public var _meta: [String: AnyCodable]?
    public var roots: [Root]
    
    public init(roots: [Root], _meta: [String: AnyCodable]? = nil) {
        self.roots = roots
        self._meta = _meta
    }
}
