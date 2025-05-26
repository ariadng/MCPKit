/**
 * A notification which does not expect a response.
 */
public struct JSONRPCNotification: Codable {
    public var jsonrpc: String = Constants.JSONRPC_VERSION
    public var method: String
    public var params: AnyCodable?
    
    public init(method: String, params: AnyCodable? = nil) {
        self.method = method
        self.params = params
    }
}
