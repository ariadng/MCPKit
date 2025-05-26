/**
 * This request is sent from the client to the server when it first connects, asking it to begin initialization.
 */
public struct InitializeRequest: Request, Codable {
    public var method: String = "initialize"
    public var params: RequestParams?
    
    public struct Params: Codable {
        /**
         * The latest version of the Model Context Protocol that the client supports. The client MAY decide to support older versions as well.
         */
        public var protocolVersion: String
        public var capabilities: ClientCapabilities
        public var clientInfo: Implementation
        
        public init(protocolVersion: String, capabilities: ClientCapabilities, clientInfo: Implementation) {
            self.protocolVersion = protocolVersion
            self.capabilities = capabilities
            self.clientInfo = clientInfo
        }
    }
    
    public init(params: Params) {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(params),
           let jsonObject = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let jsonData = try? JSONSerialization.data(withJSONObject: jsonObject),
           let anyCodable = try? JSONDecoder().decode(AnyCodable.self, from: jsonData) {
            var requestParams = RequestParams()
            for (key, value) in jsonObject {
                requestParams[key] = AnyCodable(value)
            }
            self.params = requestParams
        }
    }
}
