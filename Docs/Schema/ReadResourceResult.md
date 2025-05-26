# ReadResourceResult

## Overview

The `ReadResourceResult` structure represents the server's response to a resources/read request from the client in the MCP system.

## Declaration

```swift
public struct ReadResourceResult: Result, Codable
```

## Properties

### _meta

```swift
public var _meta: [String: AnyCodable]?
```

Optional metadata associated with the result.

### contents

```swift
public var contents: [ResourceContentsType]
```

The contents of the requested resource.

## Nested Types

### ResourceContentsType

```swift
public enum ResourceContentsType: Codable
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
public init(contents: [ResourceContentsType], _meta: [String: AnyCodable]? = nil)
```

Creates a new `ReadResourceResult` instance with the specified contents and optional metadata.
