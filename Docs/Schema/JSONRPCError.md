# JSONRPCError

## Overview

The `JSONRPCError` structure represents a response to a request that indicates an error occurred in the JSON-RPC protocol used by the MCP system.

## Declaration

```swift
public struct JSONRPCError: Codable
```

## Properties

### jsonrpc

```swift
public var jsonrpc: String = Constants.JSONRPC_VERSION
```

The JSON-RPC version, which is always "2.0".

### id

```swift
public var id: RequestId
```

The ID of the request that caused the error.

### error

```swift
public var error: ErrorObject
```

An object containing information about the error.

## Nested Types

### ErrorObject

```swift
public struct ErrorObject: Codable
```

A structure that contains information about a JSON-RPC error.

#### Properties

##### code

```swift
public var code: Int
```

The error type that occurred. Standard error codes are defined in the Constants enumeration.

##### message

```swift
public var message: String
```

A short description of the error. The message should be limited to a concise single sentence.

##### data

```swift
public var data: AnyCodable?
```

Additional information about the error. The value of this member is defined by the sender (e.g., detailed error information, nested errors, etc.).

#### Initialization

```swift
public init(code: Int, message: String, data: AnyCodable? = nil)
```

Creates a new `ErrorObject` instance with the specified code, message, and optional data.

## Initialization

```swift
public init(id: RequestId, error: ErrorObject)
```

Creates a new `JSONRPCError` instance with the specified request ID and error object.
