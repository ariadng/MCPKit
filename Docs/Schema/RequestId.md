# RequestId

## Overview

The `RequestId` enumeration represents a uniquely identifying ID for a request in JSON-RPC used by the MCP system.

## Declaration

```swift
public enum RequestId: Codable, Hashable
```

## Cases

### string

```swift
case string(String)
```

A string-based request ID.

### number

```swift
case number(Int)
```

A number-based request ID.

## Initialization

```swift
public init(from decoder: Decoder) throws
```

Creates a new `RequestId` instance by decoding from the given decoder. The appropriate case is selected based on whether the decoded value is a string or a number.

## Methods

### encode(to:)

```swift
public func encode(to encoder: Encoder) throws
```

Encodes the `RequestId` instance to the given encoder. The encoding depends on the specific case of the enumeration.
