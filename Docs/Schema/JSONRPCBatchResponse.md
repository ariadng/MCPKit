# JSONRPCBatchResponse

## Overview

The `JSONRPCBatchResponse` type represents a JSON-RPC batch response, as described in the [JSON-RPC 2.0 Specification](https://www.jsonrpc.org/specification#batch). It contains multiple responses to a batch request.

## Declaration

```swift
public typealias JSONRPCBatchResponse = [JSONRPCBatchResponseItem]
```

## Related Types

### JSONRPCBatchResponseItem

```swift
public enum JSONRPCBatchResponseItem: Codable
```

An enumeration that represents an item in a JSON-RPC batch response, which can be either a successful response or an error.

#### Cases

##### response

```swift
case response(JSONRPCResponse)
```

A successful JSON-RPC response with a result.

##### error

```swift
case error(JSONRPCError)
```

A JSON-RPC error response.

#### Initialization

```swift
public init(from decoder: Decoder) throws
```

Creates a new `JSONRPCBatchResponseItem` instance by decoding from the given decoder. The appropriate case is selected based on the presence of a result or error field in the decoded JSON.

#### Methods

##### encode(to:)

```swift
public func encode(to encoder: Encoder) throws
```

Encodes the `JSONRPCBatchResponseItem` instance to the given encoder. The encoding depends on the specific case of the enumeration.
