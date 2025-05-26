# ListToolsResult

## Overview

The `ListToolsResult` structure represents the server's response to a tools/list request from the client in the MCP system.

## Declaration

```swift
public struct ListToolsResult: Result, PaginatedResult, Codable
```

## Properties

### _meta

```swift
public var _meta: [String: AnyCodable]?
```

Optional metadata associated with the result.

### nextCursor

```swift
public var nextCursor: Cursor?
```

An optional cursor that can be used to retrieve the next page of results.

### tools

```swift
public var tools: [Tool]
```

The list of tools returned by the server.

## Initialization

```swift
public init(tools: [Tool], nextCursor: Cursor? = nil, _meta: [String: AnyCodable]? = nil)
```

Creates a new `ListToolsResult` instance with the specified tools, optional next cursor, and optional metadata.
