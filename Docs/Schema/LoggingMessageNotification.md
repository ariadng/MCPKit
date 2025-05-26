# LoggingMessageNotification

## Overview

The `LoggingMessageNotification` structure represents a notification of a log message passed from server to client in the MCP system. If no logging/setLevel request has been sent from the client, the server may decide which messages to send automatically.

## Declaration

```swift
public struct LoggingMessageNotification: Notification, Codable
```

## Properties

### method

```swift
public var method: String = "notifications/message"
```

A constant string that identifies this notification as a logging message notification.

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

A structure that contains the parameters for the logging message notification.

#### Properties

##### level

```swift
public var level: LoggingLevel
```

The severity of this log message.

##### logger

```swift
public var logger: String?
```

An optional name of the logger issuing this message.

##### data

```swift
public var data: AnyCodable
```

The data to be logged, such as a string message or an object. Any JSON serializable type is allowed here.

#### Initialization

```swift
public init(level: LoggingLevel, logger: String? = nil, data: AnyCodable)
```

Creates a new `Params` instance with the specified level, optional logger, and data.

## Initialization

```swift
public init(params: Params)
```

Creates a new `LoggingMessageNotification` instance with the specified parameters.
