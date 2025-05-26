# CompleteRequest

## Overview

The `CompleteRequest` structure represents a request from the client to the server to ask for completion options in the MCP system.

## Declaration

```swift
public struct CompleteRequest: Request, Codable
```

## Properties

### method

```swift
public var method: String = "completion/complete"
```

A constant string that identifies this request as a completion request.

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

A structure that contains the parameters for the completion request.

#### Properties

##### ref

```swift
public var ref: Reference
```

Reference to a prompt or resource.

##### argument

```swift
public var argument: Argument
```

The argument's information.

#### Initialization

```swift
public init(ref: Reference, argument: Argument)
```

Creates a new `Params` instance with the specified reference and argument.

### Reference

```swift
public enum Reference: Codable
```

An enumeration that represents a reference to either a prompt or a resource.

#### Cases

##### prompt

```swift
case prompt(PromptReference)
```

A reference to a prompt.

##### resource

```swift
case resource(ResourceReference)
```

A reference to a resource.

### Argument

```swift
public struct Argument: Codable
```

A structure that represents an argument for completion.

#### Properties

##### name

```swift
public var name: String
```

The name of the argument.

##### value

```swift
public var value: String
```

The value of the argument to use for completion matching.

#### Initialization

```swift
public init(name: String, value: String)
```

Creates a new `Argument` instance with the specified name and value.

## Initialization

```swift
public init(ref: Params.Reference, argument: Params.Argument)
```

Creates a new `CompleteRequest` instance with the specified reference and argument.
