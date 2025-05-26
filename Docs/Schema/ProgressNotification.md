# ProgressNotification

## Overview

The `ProgressNotification` structure represents an out-of-band notification used to inform the receiver of a progress update for a long-running request in the MCP system.

## Declaration

```swift
public struct ProgressNotification: Notification, Codable
```

## Properties

### method

```swift
public var method: String = "notifications/progress"
```

A constant string that identifies this notification as a progress notification.

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

A structure that contains the parameters for the progress notification.

#### Properties

##### progressToken

```swift
public var progressToken: ProgressToken
```

The progress token which was given in the initial request, used to associate this notification with the request that is proceeding.

##### progress

```swift
public var progress: Int
```

The progress thus far. This should increase every time progress is made, even if the total is unknown.

##### total

```swift
public var total: Int?
```

Total number of items to process (or total progress required), if known.

##### message

```swift
public var message: String?
```

An optional message describing the current progress.

#### Initialization

```swift
public init(progressToken: ProgressToken, progress: Int, total: Int? = nil, message: String? = nil)
```

Creates a new `Params` instance with the specified progress token, progress, optional total, and optional message.

## Initialization

```swift
public init(params: Params)
```

Creates a new `ProgressNotification` instance with the specified parameters.
