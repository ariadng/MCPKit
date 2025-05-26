# JSONRPCNotification

## Overview

The `JSONRPCNotification` structure represents a notification which does not expect a response in the JSON-RPC protocol used by the MCP system.

## Declaration

```swift
public struct JSONRPCNotification: Codable
```

## Properties

### jsonrpc

```swift
public var jsonrpc: String = Constants.JSONRPC_VERSION
```

The JSON-RPC version, which is always "2.0".

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
public init(method: String, params: AnyCodable? = nil)
```

Creates a new `JSONRPCNotification` instance with the specified method and optional parameters.
