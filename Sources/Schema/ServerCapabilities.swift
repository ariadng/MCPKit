/**
 * Capabilities that a server may support. Known capabilities are defined here, in this schema, but this is not a closed set: any server can define its own, additional capabilities.
 */
public struct ServerCapabilities: Codable {
    /**
     * Experimental capabilities. These are not standardized and may change at any time.
     */
    public var experimental: [String: AnyCodable]?
    
    /**
     * Capabilities related to logging.
     */
    public var logging: AnyCodable?
    
    /**
     * Capabilities related to completions.
     */
    public var completions: AnyCodable?
    
    /**
     * Capabilities related to prompts.
     */
    public var prompts: PromptsCapabilities?
    
    /**
     * Capabilities related to resources.
     */
    public var resources: ResourcesCapabilities?
    
    /**
     * Capabilities related to tools.
     */
    public var tools: ToolsCapabilities?
    
    public init(
        experimental: [String: AnyCodable]? = nil,
        logging: AnyCodable? = nil,
        completions: AnyCodable? = nil,
        prompts: PromptsCapabilities? = nil,
        resources: ResourcesCapabilities? = nil,
        tools: ToolsCapabilities? = nil
    ) {
        self.experimental = experimental
        self.logging = logging
        self.completions = completions
        self.prompts = prompts
        self.resources = resources
        self.tools = tools
    }
    
    public struct PromptsCapabilities: Codable {
        /**
         * Whether this server supports notifications for changes to the prompt list.
         */
        public var listChanged: Bool?
        
        public init(listChanged: Bool? = nil) {
            self.listChanged = listChanged
        }
    }
    
    public struct ResourcesCapabilities: Codable {
        /**
         * Whether this server supports subscribing to resource updates.
         */
        public var subscribe: Bool?
        
        /**
         * Whether this server supports notifications for changes to the resource list.
         */
        public var listChanged: Bool?
        
        public init(subscribe: Bool? = nil, listChanged: Bool? = nil) {
            self.subscribe = subscribe
            self.listChanged = listChanged
        }
    }
    
    public struct ToolsCapabilities: Codable {
        /**
         * Whether this server supports notifications for changes to the tool list.
         */
        public var listChanged: Bool?
        
        public init(listChanged: Bool? = nil) {
            self.listChanged = listChanged
        }
    }
}
