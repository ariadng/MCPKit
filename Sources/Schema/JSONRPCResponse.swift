/**
 * A successful (non-error) response to a request.
 */
public struct JSONRPCResponse: Codable {
    public var jsonrpc: String = Constants.JSONRPC_VERSION
    public var id: RequestId
    public var result: AnyCodable
    
    public init(id: RequestId, result: AnyCodable) {
        self.id = id
        self.result = result
    }
}
