# EmbeddedResource

## Overview

The `EmbeddedResource` structure represents the contents of a resource embedded into a prompt or tool call result in the MCP system. It is up to the client how best to render embedded resources for the benefit of the language model and/or the user.

## Declaration

```swift
public struct EmbeddedResource: Codable
```

## Properties

### type

```swift
public var type: String = "resource"
```

A constant string that identifies this as a resource.

### resource

```swift
public var resource: ResourceType
```

The type and contents of the resource.

### annotations

```swift
public var annotations: Annotations?
```

Optional annotations for the client.

## Nested Types

### ResourceType

```swift
public enum ResourceType: Codable
```

An enumeration that represents different types of resource contents.

#### Cases

##### text

```swift
case text(TextResourceContents)
```

Text resource contents.

##### blob

```swift
case blob(BlobResourceContents)
```

Binary resource contents.

## Initialization

```swift
public init(resource: ResourceType, annotations: Annotations? = nil)
```

Creates a new `EmbeddedResource` instance with the specified resource and optional annotations.
