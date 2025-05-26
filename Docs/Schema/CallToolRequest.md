# CallToolRequest

## Overview

The `CallToolRequest` structure is used by the client to invoke a tool provided by the server in the MCP system.

## Declaration

```swift
public struct CallToolRequest: Request, Codable
```

## Properties

### method

```swift
public var method: String = "tools/call"
```

A constant string that identifies this request as a tool call.

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

A structure that contains the parameters for the tool call.

#### Properties

##### name

```swift
public var name: String
```

The name of the tool to call.

##### arguments

```swift
public var arguments: [String: AnyCodable]?
```

Arguments to pass to the tool.

#### Initialization

```swift
public init(name: String, arguments: [String: AnyCodable]? = nil)
```

Creates a new `Params` instance with the specified tool name and optional arguments.

## Initialization

```swift
public init(name: String, arguments: [String: Any]? = nil)
```

Creates a new `CallToolRequest` instance with the specified tool name and optional arguments. The arguments are automatically converted to `AnyCodable` values.
