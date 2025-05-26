/**
 * A response to a request that indicates an error occurred.
 */
public struct JSONRPCError: Codable {
    public var jsonrpc: String = Constants.JSONRPC_VERSION
    public var id: RequestId
    public var error: ErrorObject
    
    public struct ErrorObject: Codable {
        /**
         * The error type that occurred.
         */
        public var code: Int
        
        /**
         * A short description of the error. The message SHOULD be limited to a concise single sentence.
         */
        public var message: String
        
        /**
         * Additional information about the error. The value of this member is defined by the sender (e.g. detailed error information, nested errors etc.).
         */
        public var data: AnyCodable?
        
        public init(code: Int, message: String, data: AnyCodable? = nil) {
            self.code = code
            self.message = message
            self.data = data
        }
    }
    
    public init(id: RequestId, error: ErrorObject) {
        self.id = id
        self.error = error
    }
}
