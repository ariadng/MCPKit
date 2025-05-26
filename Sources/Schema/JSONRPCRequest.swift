/**
 * A request that expects a response.
 */
public struct JSONRPCRequest: Codable {
    public var jsonrpc: String = Constants.JSONRPC_VERSION
    public var id: RequestId
    public var method: String
    public var params: AnyCodable?
    
    public init(id: RequestId, method: String, params: AnyCodable? = nil) {
        self.id = id
        self.method = method
        self.params = params
    }
}
