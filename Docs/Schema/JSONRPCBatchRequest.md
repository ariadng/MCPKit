# JSONRPCBatchRequest

## Overview

The `JSONRPCBatchRequest` type represents a JSON-RPC batch request, as described in the [JSON-RPC 2.0 Specification](https://www.jsonrpc.org/specification#batch). It allows multiple requests and notifications to be sent in a single batch.

## Declaration

```swift
public typealias JSONRPCBatchRequest = [JSONRPCBatchRequestItem]
```

## Related Types

### JSONRPCBatchRequestItem

```swift
public enum JSONRPCBatchRequestItem: Codable
```

An enumeration that represents an item in a JSON-RPC batch request, which can be either a request or a notification.

#### Cases

##### request

```swift
case request(JSONRPCRequest)
```

A JSON-RPC request with an ID.

##### notification

```swift
case notification(JSONRPCNotification)
```

A JSON-RPC notification without an ID.

#### Initialization

```swift
public init(from decoder: Decoder) throws
```

Creates a new `JSONRPCBatchRequestItem` instance by decoding from the given decoder. The appropriate case is selected based on the presence of an ID field in the decoded JSON.

#### Methods

##### encode(to:)

```swift
public func encode(to encoder: Encoder) throws
```

Encodes the `JSONRPCBatchRequestItem` instance to the given encoder. The encoding depends on the specific case of the enumeration.
