# PaginatedRequest

## Overview

The `PaginatedRequest` protocol serves as the base interface for paginated requests in the MCP system.

## Declaration

```swift
public protocol PaginatedRequest
```

## Requirements

### params

```swift
var params: RequestParams? { get }
```

The parameters for the request.

## Extension Methods

### cursor

```swift
var cursor: Cursor? { get }
```

An opaque token representing the current pagination position. If provided, the server should return results starting after this cursor.

### setCursor(_:)

```swift
mutating func setCursor(_ cursor: Cursor?)
```

Sets the cursor for the paginated request. If the cursor is nil, it removes the cursor parameter. If the params property is nil and the cursor is not nil, it creates a new params object with the cursor.
