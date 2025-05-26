# Result

## Overview

The `Result` protocol serves as the base interface for all results in the MCP system.

## Declaration

```swift
public protocol Result: Codable
```

## Requirements

### _meta

```swift
var _meta: [String: AnyCodable]? { get set }
```

Optional metadata associated with the result.

## Related Types

### ResultMeta

```swift
public struct ResultMeta: Codable
```

A structure that represents metadata associated with a result.

#### Properties

##### additionalProperties

```swift
private var additionalProperties: [String: AnyCodable]
```

A dictionary of additional properties that can be included in the result metadata.

#### Subscript

```swift
public subscript(key: String) -> AnyCodable?
```

Provides dictionary-like access to the additional properties.

#### Initialization

```swift
public init(additionalProperties: [String: AnyCodable] = [:])
```

Creates a new `ResultMeta` instance with the specified additional properties.

```swift
public init(from decoder: Decoder) throws
```

Creates a new `ResultMeta` instance by decoding from the given decoder.
