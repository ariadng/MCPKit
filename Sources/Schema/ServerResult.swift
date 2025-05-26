/**
 * Union type of all result types that can be returned from the server to the client.
 */
public enum ServerResult: Codable {
    case empty(EmptyResult)
    case initialize(InitializeResult)
    case listResources(ListResourcesResult)
    case listResourceTemplates(ListResourceTemplatesResult)
    case readResource(ReadResourceResult)
    case listPrompts(ListPromptsResult)
    case getPrompt(GetPromptResult)
    case listTools(ListToolsResult)
    case callTool(CallToolResult)
    case complete(CompleteResult)
    
    private enum CodingKeys: String, CodingKey {
        case protocolVersion
        case resources
        case resourceTemplates
        case contents
        case prompts
        case messages
        case tools
        case content
        case completion
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if container.contains(.protocolVersion) {
            self = .initialize(try InitializeResult(from: decoder))
        } else if container.contains(.resources) {
            self = .listResources(try ListResourcesResult(from: decoder))
        } else if container.contains(.resourceTemplates) {
            self = .listResourceTemplates(try ListResourceTemplatesResult(from: decoder))
        } else if container.contains(.contents) {
            self = .readResource(try ReadResourceResult(from: decoder))
        } else if container.contains(.prompts) {
            self = .listPrompts(try ListPromptsResult(from: decoder))
        } else if container.contains(.messages) {
            self = .getPrompt(try GetPromptResult(from: decoder))
        } else if container.contains(.tools) {
            self = .listTools(try ListToolsResult(from: decoder))
        } else if container.contains(.content) {
            self = .callTool(try CallToolResult(from: decoder))
        } else if container.contains(.completion) {
            self = .complete(try CompleteResult(from: decoder))
        } else {
            self = .empty(try EmptyResult(from: decoder))
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        switch self {
        case .empty(let result):
            try result.encode(to: encoder)
        case .initialize(let result):
            try result.encode(to: encoder)
        case .listResources(let result):
            try result.encode(to: encoder)
        case .listResourceTemplates(let result):
            try result.encode(to: encoder)
        case .readResource(let result):
            try result.encode(to: encoder)
        case .listPrompts(let result):
            try result.encode(to: encoder)
        case .getPrompt(let result):
            try result.encode(to: encoder)
        case .listTools(let result):
            try result.encode(to: encoder)
        case .callTool(let result):
            try result.encode(to: encoder)
        case .complete(let result):
            try result.encode(to: encoder)
        }
    }
}
