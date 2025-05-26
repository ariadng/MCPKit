# ListResourceTemplatesResult

## Overview

The `ListResourceTemplatesResult` structure represents the server's response to a resources/templates/list request from the client in the MCP system.

## Declaration

```swift
public struct ListResourceTemplatesResult: Result, PaginatedResult, Codable
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

### resourceTemplates

```swift
public var resourceTemplates: [ResourceTemplate]
```

The list of resource templates returned by the server.

## Initialization

```swift
public init(resourceTemplates: [ResourceTemplate], nextCursor: Cursor? = nil, _meta: [String: AnyCodable]? = nil)
```

Creates a new `ListResourceTemplatesResult` instance with the specified resource templates, optional next cursor, and optional metadata.
