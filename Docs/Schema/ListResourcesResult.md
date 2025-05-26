# ListResourcesResult

## Overview

The `ListResourcesResult` structure represents the server's response to a resources/list request from the client in the MCP system.

## Declaration

```swift
public struct ListResourcesResult: Result, PaginatedResult, Codable
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

### resources

```swift
public var resources: [Resource]
```

The list of resources returned by the server.

## Initialization

```swift
public init(resources: [Resource], nextCursor: Cursor? = nil, _meta: [String: AnyCodable]? = nil)
```

Creates a new `ListResourcesResult` instance with the specified resources, optional next cursor, and optional metadata.
