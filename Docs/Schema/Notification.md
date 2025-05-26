# Notification

## Overview

The `Notification` protocol serves as the base interface for all notifications in the MCP system.

## Declaration

```swift
public protocol Notification: Codable
```

## Requirements

### method

```swift
var method: String { get }
```

The method name of the notification.

### params

```swift
var params: NotificationParams? { get }
```

The parameters for the notification.

## Related Types

### NotificationParams

```swift
public struct NotificationParams: Codable
```

A structure that represents the parameters for a notification.

#### Properties

##### _meta

```swift
public var _meta: [String: AnyCodable]?
```

This parameter name is reserved by MCP to allow clients and servers to attach additional metadata to their notifications.

##### additionalProperties

```swift
private var additionalProperties: [String: AnyCodable]
```

A dictionary of additional properties that can be included in the notification parameters.

#### Subscript

```swift
public subscript(key: String) -> AnyCodable?
```

Provides dictionary-like access to the additional properties.

#### Initialization

```swift
public init(_meta: [String: AnyCodable]? = nil, additionalProperties: [String: AnyCodable] = [:])
```

Creates a new `NotificationParams` instance with the specified metadata and additional properties.

```swift
public init(from decoder: Decoder) throws
```

Creates a new `NotificationParams` instance by decoding from the given decoder.

#### Methods

##### encode(to:)

```swift
public func encode(to encoder: Encoder) throws
```

Encodes the `NotificationParams` instance to the given encoder.
