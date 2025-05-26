# InitializedNotification

## Overview

The `InitializedNotification` structure represents a notification sent from the client to the server after initialization has finished in the MCP system.

## Declaration

```swift
public struct InitializedNotification: Notification, Codable
```

## Properties

### method

```swift
public var method: String = "notifications/initialized"
```

A constant string that identifies this notification as an initialized notification.

### params

```swift
public var params: NotificationParams?
```

The parameters for the notification. This is typically nil for the initialized notification.

## Initialization

```swift
public init()
```

Creates a new `InitializedNotification` instance with no parameters.
