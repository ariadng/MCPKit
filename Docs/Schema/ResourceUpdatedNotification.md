# ResourceUpdatedNotification

## Overview

The `ResourceUpdatedNotification` structure represents a notification from the server to the client, informing it that a resource has changed and may need to be read again in the MCP system. This should only be sent if the client previously sent a resources/subscribe request.

## Declaration

```swift
public struct ResourceUpdatedNotification: Notification, Codable
```

## Properties

### method

```swift
public var method: String = "notifications/resources/updated"
```

A constant string that identifies this notification as a resource updated notification.

### params

```swift
public var params: NotificationParams?
```

The parameters for the notification.

## Nested Types

### Params

```swift
public struct Params: Codable
```

A structure that contains the parameters for the resource updated notification.

#### Properties

##### uri

```swift
public var uri: String
```

The URI of the resource that has been updated. This might be a sub-resource of the one that the client actually subscribed to.

#### Initialization

```swift
public init(uri: String)
```

Creates a new `Params` instance with the specified URI.

## Initialization

```swift
public init(uri: String)
```

Creates a new `ResourceUpdatedNotification` instance with the specified URI.
