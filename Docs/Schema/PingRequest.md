# PingRequest

## Overview

The `PingRequest` structure represents a ping, issued by either the server or the client, to check that the other party is still alive in the MCP system. The receiver must promptly respond, or else may be disconnected.

## Declaration

```swift
public struct PingRequest: Request, Codable
```

## Properties

### method

```swift
public var method: String = "ping"
```

A constant string that identifies this request as a ping request.

### params

```swift
public var params: RequestParams?
```

The parameters for the request. This is typically nil for the ping request.

## Initialization

```swift
public init()
```

Creates a new `PingRequest` instance with no parameters.
