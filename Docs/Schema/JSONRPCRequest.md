# JSONRPCRequest

## Overview

The `JSONRPCRequest` structure represents a request that expects a response in the JSON-RPC protocol used by the MCP system.

## Declaration

```swift
public struct JSONRPCRequest: Codable
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

The ID of the request, which is used to match responses to requests.

### method

```swift
public var method: String
```

The name of the method to be invoked.

### params

```swift
public var params: AnyCodable?
```

Optional parameter values to be used during the invocation of the method.

## Initialization

```swift
public init(id: RequestId, method: String, params: AnyCodable? = nil)
```

Creates a new `JSONRPCRequest` instance with the specified ID, method, and optional parameters.
