/**
 * Additional properties describing a Tool to clients.
 *
 * NOTE: all properties in ToolAnnotations are **hints**.
 * They are not guaranteed to provide a faithful description of
 * tool behavior (including descriptive properties like `title`).
 *
 * Clients should never make tool use decisions based on ToolAnnotations
 * received from untrusted servers.
 */
public struct ToolAnnotations: Codable {
    /**
     * A human-readable title for the tool.
     */
    public var title: String?
    
    /**
     * Indicates that the tool does not modify any state.
     */
    public var readOnlyHint: Bool?
    
    /**
     * Indicates that the tool may modify state in a way that cannot be undone.
     */
    public var destructiveHint: Bool?
    
    /**
     * Indicates that the tool is idempotent (calling it multiple times with the same arguments has the same effect as calling it once).
     */
    public var idempotentHint: Bool?
    
    /**
     * Indicates that the tool may accept arguments not explicitly listed in its schema.
     */
    public var openWorldHint: Bool?
    
    public init(
        title: String? = nil,
        readOnlyHint: Bool? = nil,
        destructiveHint: Bool? = nil,
        idempotentHint: Bool? = nil,
        openWorldHint: Bool? = nil
    ) {
        self.title = title
        self.readOnlyHint = readOnlyHint
        self.destructiveHint = destructiveHint
        self.idempotentHint = idempotentHint
        self.openWorldHint = openWorldHint
    }
}
