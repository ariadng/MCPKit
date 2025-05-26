/**
 * A response that indicates success but carries no data.
 */
public struct EmptyResult: Result, Codable {
    public var _meta: [String: AnyCodable]?
    
    public init(_meta: [String: AnyCodable]? = nil) {
        self._meta = _meta
    }
}
