# JSONRPCMessage

## Overview

The `JSONRPCMessage` enumeration represents any valid JSON-RPC object that can be decoded from or encoded to the wire in the MCP system.

## Declaration

```swift
public enum JSONRPCMessage: Codable
```

## Cases

### request

```swift
case request(JSONRPCRequest)
```

A JSON-RPC request with an ID.

### notification

```swift
case notification(JSONRPCNotification)
```

A JSON-RPC notification without an ID.

### batchRequest

```swift
case batchRequest(JSONRPCBatchRequest)
```

A batch of JSON-RPC requests and/or notifications.

### response

```swift
case response(JSONRPCResponse)
```

A successful JSON-RPC response with a result.

### error

```swift
case error(JSONRPCError)
```

A JSON-RPC error response.

### batchResponse

```swift
case batchResponse(JSONRPCBatchResponse)
```

A batch of JSON-RPC responses and/or errors.

## Initialization

```swift
public init(from decoder: Decoder) throws
```

Creates a new `JSONRPCMessage` instance by decoding from the given decoder. The appropriate case is selected based on the structure of the decoded JSON.

## Methods

### encode(to:)

```swift
public func encode(to encoder: Encoder) throws
```

Encodes the `JSONRPCMessage` instance to the given encoder. The encoding depends on the specific case of the enumeration.
