# ListPromptsResult

## Overview

The `ListPromptsResult` structure represents the server's response to a prompts/list request from the client in the MCP system.

## Declaration

```swift
public struct ListPromptsResult: Result, PaginatedResult, Codable
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

### prompts

```swift
public var prompts: [Prompt]
```

The list of prompts returned by the server.

## Initialization

```swift
public init(prompts: [Prompt], nextCursor: Cursor? = nil, _meta: [String: AnyCodable]? = nil)
```

Creates a new `ListPromptsResult` instance with the specified prompts, optional next cursor, and optional metadata.
