/**
 * Union type of all requests that can be sent from the client to the server.
 */
public enum ClientRequest: Codable {
    case initialize(InitializeRequest)
    case ping(PingRequest)
    case listResources(ListResourcesRequest)
    case listResourceTemplates(ListResourceTemplatesRequest)
    case readResource(ReadResourceRequest)
    case subscribe(SubscribeRequest)
    case unsubscribe(UnsubscribeRequest)
    case listPrompts(ListPromptsRequest)
    case getPrompt(GetPromptRequest)
    case listTools(ListToolsRequest)
    case callTool(CallToolRequest)
    case setLevel(SetLevelRequest)
    case complete(CompleteRequest)
    
    private enum CodingKeys: String, CodingKey {
        case method
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let method = try container.decode(String.self, forKey: .method)
        
        switch method {
        case "initialize":
            self = .initialize(try InitializeRequest(from: decoder))
        case "ping":
            self = .ping(try PingRequest(from: decoder))
        case "resources/list":
            self = .listResources(try ListResourcesRequest(from: decoder))
        case "resources/templates/list":
            self = .listResourceTemplates(try ListResourceTemplatesRequest(from: decoder))
        case "resources/read":
            self = .readResource(try ReadResourceRequest(from: decoder))
        case "subscribe":
            self = .subscribe(try SubscribeRequest(from: decoder))
        case "unsubscribe":
            self = .unsubscribe(try UnsubscribeRequest(from: decoder))
        case "prompts/list":
            self = .listPrompts(try ListPromptsRequest(from: decoder))
        case "prompts/get":
            self = .getPrompt(try GetPromptRequest(from: decoder))
        case "tools/list":
            self = .listTools(try ListToolsRequest(from: decoder))
        case "tools/call":
            self = .callTool(try CallToolRequest(from: decoder))
        case "logging/setLevel":
            self = .setLevel(try SetLevelRequest(from: decoder))
        case "complete":
            self = .complete(try CompleteRequest(from: decoder))
        default:
            throw DecodingError.dataCorruptedError(forKey: .method, in: container, debugDescription: "Unknown request method: \(method)")
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        switch self {
        case .initialize(let request):
            try request.encode(to: encoder)
        case .ping(let request):
            try request.encode(to: encoder)
        case .listResources(let request):
            try request.encode(to: encoder)
        case .listResourceTemplates(let request):
            try request.encode(to: encoder)
        case .readResource(let request):
            try request.encode(to: encoder)
        case .subscribe(let request):
            try request.encode(to: encoder)
        case .unsubscribe(let request):
            try request.encode(to: encoder)
        case .listPrompts(let request):
            try request.encode(to: encoder)
        case .getPrompt(let request):
            try request.encode(to: encoder)
        case .listTools(let request):
            try request.encode(to: encoder)
        case .callTool(let request):
            try request.encode(to: encoder)
        case .setLevel(let request):
            try request.encode(to: encoder)
        case .complete(let request):
            try request.encode(to: encoder)
        }
    }
}
