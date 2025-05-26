/**
 * A notification from the client to the server, informing it that the list of roots has changed.
 * This notification should be sent whenever the client adds, removes, or modifies any root.
 * The server should then request an updated list of roots using the ListRootsRequest.
 */
public struct RootsListChangedNotification: Notification, Codable {
    public var method: String = "notifications/roots/list_changed"
    public var params: NotificationParams?
    
    public init() {
        self.params = nil
    }
}
