# ListResourcesRequest

## Overview

The `ListResourcesRequest` structure represents a request sent from the client to request a list of resources the server has in the MCP system.

## Declaration

```swift
public struct ListResourcesRequest: Request, PaginatedRequest, Codable
```

## Properties

### method

```swift
public var method: String = "resources/list"
```

A constant string that identifies this request as a list resources request.

### params

```swift
public var params: RequestParams?
```

The parameters for the request.

## Initialization

```swift
public init(cursor: Cursor? = nil)
```

Creates a new `ListResourcesRequest` instance with an optional cursor for pagination. If a cursor is provided, it will be included in the request parameters.
