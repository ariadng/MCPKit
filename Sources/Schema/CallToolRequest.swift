/**
 * Used by the client to invoke a tool provided by the server.
 */
public struct CallToolRequest: Request, Codable {
    public var method: String = "tools/call"
    public var params: RequestParams?
    
    public struct Params: Codable {
        /**
         * The name of the tool to call.
         */
        public var name: String
        
        /**
         * Arguments to pass to the tool.
         */
        public var arguments: [String: AnyCodable]?
        
        public init(name: String, arguments: [String: AnyCodable]? = nil) {
            self.name = name
            self.arguments = arguments
        }
    }
    
    public init(name: String, arguments: [String: Any]? = nil) {
        var params = RequestParams()
        params["name"] = AnyCodable(name)
        
        if let arguments = arguments {
            let argumentsDict = arguments.mapValues { AnyCodable($0) }
            params["arguments"] = AnyCodable(argumentsDict)
        }
        
        self.params = params
    }
}
