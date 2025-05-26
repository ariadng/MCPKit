# Root

## Overview

The `Root` structure represents a root directory or file that the server can operate on in the MCP system.

## Declaration

```swift
public struct Root: Codable
```

## Properties

### uri

```swift
public var uri: String
```

The URI of the root. The URI can use any protocol; it is up to the server how to interpret it.

### name

```swift
public var name: String?
```

A human-readable name for the root.

## Initialization

```swift
public init(uri: String, name: String? = nil)
```

Creates a new `Root` instance with the specified URI and optional name.
