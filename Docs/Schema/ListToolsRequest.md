# ListToolsRequest

## Overview

The `ListToolsRequest` structure represents a request sent from the client to request a list of tools the server has in the MCP system.

## Declaration

```swift
public struct ListToolsRequest: Request, PaginatedRequest, Codable
```

## Properties

### method

```swift
public var method: String = "tools/list"
```

A constant string that identifies this request as a list tools request.

### params

```swift
public var params: RequestParams?
```

The parameters for the request.

## Initialization

```swift
public init(cursor: Cursor? = nil)
```

Creates a new `ListToolsRequest` instance with an optional cursor for pagination. If a cursor is provided, it will be included in the request parameters.
