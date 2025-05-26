# ResourceContents

## Overview

The `ResourceContents` protocol represents the contents of a specific resource or sub-resource in the MCP system.

## Declaration

```swift
public protocol ResourceContents: Codable
```

## Requirements

### uri

```swift
var uri: String { get set }
```

The URI of the resource. The URI can use any protocol; it is up to the server how to interpret it.

### mimeType

```swift
var mimeType: String? { get set }
```

The MIME type of the resource, if known.
