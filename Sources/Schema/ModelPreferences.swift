/**
 * The server's preferences for model selection, requested of the client during sampling.
 *
 * Because LLMs can vary along multiple dimensions, choosing the "best" model is
 * rarely straightforward. Different models excel in different areas—some are
 * faster but less capable, others are more capable but more expensive, and so
 * on. This interface allows servers to express their priorities across multiple
 * dimensions to help clients make an appropriate selection for their use case.
 *
 * These preferences are always advisory. The client MAY ignore them. It is also
 * up to the client to decide how to interpret these preferences and how to
 * balance them against other considerations.
 */
public struct ModelPreferences: Codable {
    /**
     * Hints to use for model selection.
     */
    public var hints: [ModelHint]?
    
    /**
     * How important cost is to the server.
     *
     * A value of 1 means "cost is most important", and the client should select
     * the cheapest model that can perform the task. A value of 0 means "cost is
     * not important", and the client should not consider cost when selecting a
     * model.
     */
    public var costPriority: Double?
    
    /**
     * How important speed is to the server.
     *
     * A value of 1 means "speed is most important", and the client should select
     * the fastest model that can perform the task. A value of 0 means "speed is
     * not important", and the client should not consider speed when selecting a
     * model.
     */
    public var speedPriority: Double?
    
    /**
     * How important intelligence is to the server.
     *
     * A value of 1 means "intelligence is most important", and the client should
     * select the most capable model that can perform the task. A value of 0 means
     * "intelligence is not important", and the client should not consider
     * intelligence when selecting a model.
     */
    public var intelligencePriority: Double?
    
    public init(
        hints: [ModelHint]? = nil,
        costPriority: Double? = nil,
        speedPriority: Double? = nil,
        intelligencePriority: Double? = nil
    ) {
        self.hints = hints
        self.costPriority = costPriority
        self.speedPriority = speedPriority
        self.intelligencePriority = intelligencePriority
    }
}
