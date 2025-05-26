/**
 * Hints to use for model selection.
 *
 * Keys not declared here are currently left unspecified by the spec and are up
 * to the client to interpret.
 */
public struct ModelHint: Codable, Sendable {
    /**
     * The name of a specific model that the server would prefer to use.
     */
    public var name: String?
    
    public init(name: String? = nil) {
        self.name = name
    }
}
