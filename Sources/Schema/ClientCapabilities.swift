/**
 * Capabilities a client may support. Known capabilities are defined here, in this schema, but this is not a closed set: any client can define its own, additional capabilities.
 */
public struct ClientCapabilities: Codable {
    /**
     * Experimental capabilities. These are not standardized and may change at any time.
     */
    public var experimental: [String: AnyCodable]?
    
    /**
     * Capabilities related to roots.
     */
    public var roots: RootsCapabilities?
    
    /**
     * Capabilities related to sampling.
     */
    public var sampling: SamplingCapabilities?
    
    public init(experimental: [String: AnyCodable]? = nil, roots: RootsCapabilities? = nil, sampling: SamplingCapabilities? = nil) {
        self.experimental = experimental
        self.roots = roots
        self.sampling = sampling
    }
    
    public struct RootsCapabilities: Codable {
        /**
         * Whether the client supports notifications for changes to the roots list.
         */
        public var listChanged: Bool?
        
        public init(listChanged: Bool? = nil) {
            self.listChanged = listChanged
        }
    }
    
    /**
     * Capabilities related to message sampling by the client.
     */
    public struct SamplingCapabilities: Codable {
        /**
         * Whether the client supports handling server-initiated `sampling/createMessage` requests.
         * If `true`, the server may send `sampling/createMessage` requests, and the client is expected
         * to have a handler set for `MCPClient.onSamplingCreateMessage`.
         */
        public var supportsCreateMessageRequest: Bool?

        public init(supportsCreateMessageRequest: Bool? = nil) {
            self.supportsCreateMessageRequest = supportsCreateMessageRequest
        }
    }
}
