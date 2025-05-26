/**
 * Used by the client to get a prompt provided by the server.
 */
public struct GetPromptRequest: Request, Codable {
    public var method: String = "prompts/get"
    public var params: RequestParams?
    
    public struct Params: Codable {
        /**
         * The name of the prompt or prompt template.
         */
        public var name: String
        
        /**
         * Arguments to use for templating the prompt.
         */
        public var arguments: [String: String]?
        
        public init(name: String, arguments: [String: String]? = nil) {
            self.name = name
            self.arguments = arguments
        }
    }
    
    public init(name: String, arguments: [String: String]? = nil) {
        var params = RequestParams()
        params["name"] = AnyCodable(name)
        
        if let arguments = arguments {
            let argumentsDict = arguments.mapValues { AnyCodable($0) }
            params["arguments"] = AnyCodable(argumentsDict)
        }
        
        self.params = params
    }
}
