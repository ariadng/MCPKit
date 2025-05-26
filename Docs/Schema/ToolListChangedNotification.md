# ToolListChangedNotification

`ToolListChangedNotification` is a structure that represents an optional notification from the server to the client. It informs the client that the list of tools offered by the server has changed. This notification may be issued by servers without any previous subscription from the client.

It conforms to the `Notification` and `Codable` protocols.

## Properties

### `method: String`

A string indicating the notification method, which is always `"notifications/tools/list_changed"` for this structure.

### `params: NotificationParams?`

Optional parameters for the notification. In this specific notification, `params` is typically `nil` as the notification itself signifies the change, and clients are expected to re-fetch the tool list if needed.

## Initialization

```swift
public init()
```

Initializes a `ToolListChangedNotification` instance. The `params` property is set to `nil` by default.
