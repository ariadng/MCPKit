# GetPromptRequest

## Overview

The `GetPromptRequest` structure is used by the client to get a prompt provided by the server in the MCP system.

## Declaration

```swift
public struct GetPromptRequest: Request, Codable
```

## Properties

### method

```swift
public var method: String = "prompts/get"
```

A constant string that identifies this request as a get prompt request.

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

A structure that contains the parameters for the get prompt request.

#### Properties

##### name

```swift
public var name: String
```

The name of the prompt or prompt template.

##### arguments

```swift
public var arguments: [String: String]?
```

Arguments to use for templating the prompt.

#### Initialization

```swift
public init(name: String, arguments: [String: String]? = nil)
```

Creates a new `Params` instance with the specified name and optional arguments.

## Initialization

```swift
public init(name: String, arguments: [String: String]? = nil)
```

Creates a new `GetPromptRequest` instance with the specified name and optional arguments.
