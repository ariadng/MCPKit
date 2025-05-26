# ReadResourceRequest

## Overview

The `ReadResourceRequest` structure represents a request sent from the client to the server to read a specific resource URI in the MCP system.

## Declaration

```swift
public struct ReadResourceRequest: Request, Codable
```

## Properties

### method

```swift
public var method: String = "resources/read"
```

A constant string that identifies this request as a read resource request.

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

A structure that contains the parameters for the read resource request.

#### Properties

##### uri

```swift
public var uri: String
```

The URI of the resource to read. The URI can use any protocol; it is up to the server how to interpret it.

#### Initialization

```swift
public init(uri: String)
```

Creates a new `Params` instance with the specified URI.

## Initialization

```swift
public init(uri: String)
```

Creates a new `ReadResourceRequest` instance with the specified URI.
