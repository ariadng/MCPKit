# EmptyResult

## Overview

The `EmptyResult` structure represents a response that indicates success but carries no data in the MCP system.

## Declaration

```swift
public struct EmptyResult: Result, Codable
```

## Properties

### _meta

```swift
public var _meta: [String: AnyCodable]?
```

Optional metadata associated with the result.

## Initialization

```swift
public init(_meta: [String: AnyCodable]? = nil)
```

Creates a new `EmptyResult` instance with optional metadata.
