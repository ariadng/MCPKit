# ProgressToken

## Overview

The `ProgressToken` enumeration represents a progress token, used to associate progress notifications with the original request in the MCP system.

## Declaration

```swift
public enum ProgressToken: Codable, Hashable
```

## Cases

### string

```swift
case string(String)
```

A string-based progress token.

### number

```swift
case number(Int)
```

A number-based progress token.

## Initialization

```swift
public init(from decoder: Decoder) throws
```

Creates a new `ProgressToken` instance by decoding from the given decoder. The appropriate case is selected based on whether the decoded value is a string or a number.

## Methods

### encode(to:)

```swift
public func encode(to encoder: Encoder) throws
```

Encodes the `ProgressToken` instance to the given encoder. The encoding depends on the specific case of the enumeration.
