# SetLevelRequest

## Overview

The `SetLevelRequest` structure represents a request from the client to the server to enable or adjust logging in the MCP system.

## Declaration

```swift
public struct SetLevelRequest: Request, Codable
```

## Properties

### method

```swift
public var method: String = "logging/setLevel"
```

A constant string that identifies this request as a set level request.

### params

```swift
public var params: RequestParams?
```

The parameters for the request.

## Nested Types

### Params

```swift
public struct Params: Codable
```

A structure that contains the parameters for the set level request.

#### Properties

##### level

```swift
public var level: LoggingLevel
```

The level of logging that the client wants to receive from the server. The server should send all logs at this level and higher (i.e., more severe) to the client as notifications/message.

#### Initialization

```swift
public init(level: LoggingLevel)
```

Creates a new `Params` instance with the specified logging level.

## Initialization

```swift
public init(level: LoggingLevel)
```

Creates a new `SetLevelRequest` instance with the specified logging level.
