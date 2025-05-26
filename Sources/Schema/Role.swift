/**
 * The sender or recipient of messages and data in a conversation.
 */
public typealias Role = String

// Constants for common roles
public extension Role {
    static let system: Role = "system"
    static let user: Role = "user"
    static let assistant: Role = "assistant"
    static let function: Role = "function"
    static let tool: Role = "tool"
}
