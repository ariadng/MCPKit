/**
 * A ping, issued by either the server or the client, to check that the other party is still alive. The receiver must promptly respond, or else may be disconnected.
 */
public struct PingRequest: Request, Codable {
    public var method: String = "ping"
    public var params: RequestParams?
    
    public init() {
        self.params = nil
    }
}
