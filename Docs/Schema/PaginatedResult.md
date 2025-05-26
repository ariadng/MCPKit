# PaginatedResult

## Overview

The `PaginatedResult` protocol serves as the base interface for paginated results in the MCP system.

## Declaration

```swift
public protocol PaginatedResult
```

## Requirements

### nextCursor

```swift
var nextCursor: Cursor? { get set }
```

An opaque token representing the next pagination position. If provided, there are more results available after this cursor.
