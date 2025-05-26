# ListRootsResult

## Overview

The `ListRootsResult` structure represents the client's response to a roots/list request from the server in the MCP system. This result contains an array of Root objects, each representing a root directory or file that the server can operate on.

## Declaration

```swift
public struct ListRootsResult: Result, Codable
```

## Properties

### _meta

```swift
public var _meta: [String: AnyCodable]?
```

Optional metadata associated with the result.

### roots

```swift
public var roots: [Root]
```

The list of root directories or files that the server can operate on.

## Initialization

```swift
public init(roots: [Root], _meta: [String: AnyCodable]? = nil)
```

Creates a new `ListRootsResult` instance with the specified roots and optional metadata.
