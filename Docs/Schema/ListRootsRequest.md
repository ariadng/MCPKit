# ListRootsRequest

## Overview

The `ListRootsRequest` structure represents a request sent from the server to request a list of root URIs from the client in the MCP system. Roots allow servers to ask for specific directories or files to operate on. A common example for roots is providing a set of repositories or directories a server should operate on.

This request is typically used when the server needs to understand the file system structure or access specific locations that the client has permission to read from.

## Declaration

```swift
public struct ListRootsRequest: Request, Codable
```

## Properties

### method

```swift
public var method: String = "roots/list"
```

A constant string that identifies this request as a list roots request.

### params

```swift
public var params: RequestParams?
```

The parameters for the request. This is typically nil for the list roots request.

## Initialization

```swift
public init()
```

Creates a new `ListRootsRequest` instance with no parameters.
