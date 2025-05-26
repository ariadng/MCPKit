# JSONRPCResponse

## Overview

The `JSONRPCResponse` structure represents a successful (non-error) response to a request in the JSON-RPC protocol used by the MCP system.

## Declaration

```swift
public struct JSONRPCResponse: Codable
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

The ID of the request that this response is for.

### result

```swift
public var result: AnyCodable
```

The result of the method invocation.

## Initialization

```swift
public init(id: RequestId, result: AnyCodable)
```

Creates a new `JSONRPCResponse` instance with the specified ID and result.
