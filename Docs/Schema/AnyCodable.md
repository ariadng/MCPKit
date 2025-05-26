# AnyCodable

## Overview

The `AnyCodable` structure provides a type-erased `Codable` value that can be used to encode and decode values of any type that conforms to the `Codable` protocol in the MCP system.

## Declaration

```swift
public struct AnyCodable: Codable
```

## Properties

### value

```swift
private let value: Any
```

The underlying value stored in the `AnyCodable` instance.

## Initialization

```swift
public init<T>(_ value: T)
```

Creates a new `AnyCodable` instance that wraps the specified value.

```swift
public init(from decoder: Decoder) throws
```

Creates a new `AnyCodable` instance by decoding from the given decoder.

## Methods

### encode(to:)

```swift
public func encode(to encoder: Encoder) throws
```

Encodes the `AnyCodable` instance to the given encoder.

## Supported Types

The `AnyCodable` structure supports the following types:
- `nil` values
- `Bool`
- `Int`
- `Double`
- `String`
- Arrays of `AnyCodable` values
- Dictionaries with `String` keys and `AnyCodable` values

Attempting to encode or decode values of unsupported types will result in an error.
