/**
 * This notification is sent from the client to the server after initialization has finished.
 */
public struct InitializedNotification: Notification, Codable {
    public var method: String = "notifications/initialized"
    public var params: NotificationParams?
    
    public init() {
        self.params = nil
    }
}
