# RootsListChangedNotification

## Overview

The `RootsListChangedNotification` structure represents a notification from the client to the server, informing it that the list of roots has changed in the MCP system. This notification should be sent whenever the client adds, removes, or modifies any root. The server should then request an updated list of roots using the ListRootsRequest.

## Declaration

```swift
public struct RootsListChangedNotification: Notification, Codable
```

## Properties

### method

```swift
public var method: String = "notifications/roots/list_changed"
```

A constant string that identifies this notification as a roots list changed notification.

### params

```swift
public var params: NotificationParams?
```

The parameters for the notification. This is typically nil for the roots list changed notification.

## Initialization

```swift
public init()
```

Creates a new `RootsListChangedNotification` instance with no parameters.
