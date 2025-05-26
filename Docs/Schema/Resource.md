# Resource

## Overview

The `Resource` structure represents a known resource that the server is capable of reading in the MCP system.

## Declaration

```swift
public struct Resource: Codable
```

## Properties

### uri

```swift
public var uri: String
```

The URI of the resource. The URI can use any protocol; it is up to the server how to interpret it.

### name

```swift
public var name: String
```

A human-readable name for the resource.

### description

```swift
public var description: String?
```

An optional human-readable description of the resource.

### mimeType

```swift
public var mimeType: String?
```

The MIME type of the resource, if known.

### annotations

```swift
public var annotations: Annotations?
```

Optional annotations for the client.

### size

```swift
public var size: Int?
```

The size of the resource in bytes, if known.

## Initialization

```swift
public init(
    uri: String,
    name: String,
    description: String? = nil,
    mimeType: String? = nil,
    annotations: Annotations? = nil,
    size: Int? = nil
)
```

Creates a new `Resource` instance with the specified URI, name, and optional properties.
