import Foundation

/**
 * A request from the server to sample an LLM via the client. The client has full discretion over which model to select. 
 * The client should also inform the user before beginning sampling, to allow them to inspect the request (human in the loop) and decide whether to approve it.
 */
public struct CreateMessageRequest: Request, Codable {
    public var method: String = "sampling/createMessage"
    public var params: RequestParams?
    
    public struct Params: Codable, Sendable {
        public var messages: [SamplingMessage]
        
        /**
         * The server's preferences for which model to select. The client MAY ignore these preferences.
         */
        public var modelPreferences: ModelPreferences?
        
        /**
         * An optional system prompt the server wants to use for sampling. The client MAY modify or omit this prompt.
         */
        public var systemPrompt: String?
        
        /**
         * A request to include context from one or more MCP servers (including the caller), to be attached to the prompt. The client MAY ignore this request.
         */
        public var includeContext: IncludeContext?
        
        /**
         * Temperature for sampling
         */
        public var temperature: Double?
        
        /**
         * The maximum number of tokens to sample, as requested by the server. The client MAY choose to sample fewer tokens than requested.
         */
        public var maxTokens: Int
        
        /**
         * Sequences that will stop generation if encountered
         */
        public var stopSequences: [String]?
        
        /**
         * Optional metadata to pass through to the LLM provider. The format of this metadata is provider-specific.
         */
        public var metadata: AnyCodable?
        
        public enum IncludeContext: String, Codable, Sendable {
            case none = "none"
            case thisServer = "thisServer"
            case allServers = "allServers"
        }
        
        public init(
            messages: [SamplingMessage],
            modelPreferences: ModelPreferences? = nil,
            systemPrompt: String? = nil,
            includeContext: IncludeContext? = nil,
            temperature: Double? = nil,
            maxTokens: Int,
            stopSequences: [String]? = nil,
            metadata: AnyCodable? = nil
        ) {
            self.messages = messages
            self.modelPreferences = modelPreferences
            self.systemPrompt = systemPrompt
            self.includeContext = includeContext
            self.temperature = temperature
            self.maxTokens = maxTokens
            self.stopSequences = stopSequences
            self.metadata = metadata
        }
    }
    
    public init(params: Params) {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(params),
           let jsonObject = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let jsonData = try? JSONSerialization.data(withJSONObject: jsonObject),
           (try? JSONDecoder().decode(AnyCodable.self, from: jsonData)) != nil {
            var requestParams = RequestParams()
            for (key, value) in jsonObject {
                requestParams[key] = AnyCodable(value)
            }
            self.params = requestParams
        }
    }
}
