/**
 * An optional notification from the server to the client, informing it that the list of tools it offers has changed. This may be issued by servers without any previous subscription from the client.
 */
public struct ToolListChangedNotification: Notification, Codable {
    public var method: String = "notifications/tools/list_changed"
    public var params: NotificationParams?
    
    public init() {
        self.params = nil
    }
}
