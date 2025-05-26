# CancelledNotification

## Overview

The `CancelledNotification` structure represents a notification that can be sent by either side to indicate that it is cancelling a previously-issued request in the MCP system.

## Declaration

```swift
public struct CancelledNotification: Notification, Codable
```

## Properties

### method

```swift
public var method: String = "notifications/cancelled"
```

A constant string that identifies this notification as a cancellation.

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

A structure that contains the parameters for the cancellation notification.

#### Properties

##### requestId

```swift
public var requestId: RequestId
```

The ID of the request to cancel. This must correspond to the ID of a request previously issued in the same direction.

##### reason

```swift
public var reason: String?
```

An optional string describing the reason for the cancellation. This may be logged or presented to the user.

#### Initialization

```swift
public init(requestId: RequestId, reason: String? = nil)
```

Creates a new `Params` instance with the specified request ID and optional reason.

## Initialization

```swift
public init(params: Params)
```

Creates a new `CancelledNotification` instance with the specified parameters.

## Notes

- The request should still be in-flight, but due to communication latency, it is always possible that this notification may arrive after the request has already finished.
- This notification indicates that the result will be unused, so any associated processing should cease.
- A client must not attempt to cancel its `initialize` request.
