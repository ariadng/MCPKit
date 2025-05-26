# SubscribeRequest

## Overview

The `SubscribeRequest` structure represents a request sent from the client to request resources/updated notifications from the server whenever a particular resource changes in the MCP system.

## Declaration

```swift
public struct SubscribeRequest: Request, Codable
```

## Properties

### method

```swift
public var method: String = "resources/subscribe"
```

A constant string that identifies this request as a subscribe request.

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

A structure that contains the parameters for the subscribe request.

#### Properties

##### uri

```swift
public var uri: String
```

The URI of the resource to subscribe to. The URI can use any protocol; it is up to the server how to interpret it.

#### Initialization

```swift
public init(uri: String)
```

Creates a new `Params` instance with the specified URI.

## Initialization

```swift
public init(uri: String)
```

Creates a new `SubscribeRequest` instance with the specified URI.
