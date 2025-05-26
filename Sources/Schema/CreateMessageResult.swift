/**
 * The client's response to a sampling/create_message request from the server. 
 * The client should inform the user before returning the sampled message, to allow them to inspect the response (human in the loop) and decide whether to allow the server to see it.
 */
public struct CreateMessageResult: Result, Codable {
    public var _meta: [String: AnyCodable]?
    public var role: Role
    public var content: SamplingMessage.MessageContent
    
    /**
     * The name of the model that generated the message.
     */
    public var model: String
    
    /**
     * The reason why sampling stopped, if known.
     */
    public var stopReason: String?
    
    public init(role: Role, content: SamplingMessage.MessageContent, model: String, stopReason: String? = nil, _meta: [String: AnyCodable]? = nil) {
        self.role = role
        self.content = content
        self.model = model
        self.stopReason = stopReason
        self._meta = _meta
    }
}
