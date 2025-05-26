# CompleteResult

## Overview

The `CompleteResult` structure represents the server's response to a completion/complete request in the MCP system.

## Declaration

```swift
public struct CompleteResult: Result, Codable
```

## Properties

### _meta

```swift
public var _meta: [String: AnyCodable]?
```

Optional metadata associated with the result.

### completion

```swift
public var completion: Completion
```

The completion data returned by the server.

## Nested Types

### Completion

```swift
public struct Completion: Codable
```

A structure that contains the completion data.

#### Properties

##### values

```swift
public var values: [String]
```

An array of completion values. Must not exceed 100 items.

##### total

```swift
public var total: Int?
```

The total number of completion options available. This can exceed the number of values actually sent in the response.

##### hasMore

```swift
public var hasMore: Bool?
```

Indicates whether there are additional completion options beyond those provided in the current response, even if the exact total is unknown.

#### Initialization

```swift
public init(values: [String], total: Int? = nil, hasMore: Bool? = nil)
```

Creates a new `Completion` instance with the specified values, total, and hasMore flag.

## Initialization

```swift
public init(completion: Completion, _meta: [String: AnyCodable]? = nil)
```

Creates a new `CompleteResult` instance with the specified completion data and optional metadata.
