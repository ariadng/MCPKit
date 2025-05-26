# ResourceListChangedNotification

## Overview

The `ResourceListChangedNotification` structure represents an optional notification from the server to the client, informing it that the list of resources it can read from has changed in the MCP system. This may be issued by servers without any previous subscription from the client.

## Declaration

```swift
public struct ResourceListChangedNotification: Notification, Codable
```

## Properties

### method

```swift
public var method: String = "notifications/resources/list_changed"
```

A constant string that identifies this notification as a resource list changed notification.

### params

```swift
public var params: NotificationParams?
```

The parameters for the notification. This is typically nil for the resource list changed notification.

## Initialization

```swift
public init()
```

Creates a new `ResourceListChangedNotification` instance with no parameters.
