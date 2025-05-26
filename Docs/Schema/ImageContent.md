# ImageContent

## Overview

The `ImageContent` structure represents an image that can be provided to or from a language model (LLM) in the MCP system.

## Declaration

```swift
public struct ImageContent: Codable
```

## Properties

### type

```swift
public var type: String = "image"
```

A constant string that identifies this content as an image.

### data

```swift
public var data: String
```

The base64-encoded image data.

### mimeType

```swift
public var mimeType: String
```

The MIME type of the image. Different providers may support different image types.

### annotations

```swift
public var annotations: Annotations?
```

Optional annotations for the client.

## Initialization

```swift
public init(data: String, mimeType: String, annotations: Annotations? = nil)
```

Creates a new `ImageContent` instance with the specified image data, MIME type, and optional annotations.
