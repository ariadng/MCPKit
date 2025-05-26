# ClientResult

## Overview

The `ClientResult` enumeration represents a union type of all result types that can be returned from the client to the server in the MCP system.

## Declaration

```swift
public enum ClientResult: Codable
```

## Cases

### empty

```swift
case empty(EmptyResult)
```

An empty result with no specific data.

### listRoots

```swift
case listRoots(ListRootsResult)
```

A result containing a list of roots.

### createMessage

```swift
case createMessage(CreateMessageResult)
```

A result from creating a message.

## Initialization

```swift
public init(from decoder: Decoder) throws
```

Creates a new `ClientResult` instance by decoding from the given decoder. The appropriate case is selected based on the presence of specific fields in the decoded JSON.

## Methods

### encode(to:)

```swift
public func encode(to encoder: Encoder) throws
```

Encodes the `ClientResult` instance to the given encoder. The encoding depends on the specific case of the enumeration.
