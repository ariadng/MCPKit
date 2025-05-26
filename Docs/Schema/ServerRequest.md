# ServerRequest

## Overview

The `ServerRequest` enumeration represents a union type of all requests that can be sent from the server to the client in the MCP system.

## Declaration

```swift
public enum ServerRequest: Codable
```

## Cases

### ping

```swift
case ping(PingRequest)
```

A ping request to check if the client is responsive.

### listRoots

```swift
case listRoots(ListRootsRequest)
```

A request to list the root directories or files that the client can provide access to.

### createMessage

```swift
case createMessage(CreateMessageRequest)
```

A request to create a message using the client's language model capabilities.

## Initialization

```swift
public init(from decoder: Decoder) throws
```

Creates a new `ServerRequest` instance by decoding from the given decoder. The appropriate case is selected based on the `method` field in the decoded JSON.

## Methods

### encode(to:)

```swift
public func encode(to encoder: Encoder) throws
```

Encodes the `ServerRequest` instance to the given encoder. The encoding depends on the specific case of the enumeration.
