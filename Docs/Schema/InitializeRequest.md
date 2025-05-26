# InitializeRequest

## Overview

The `InitializeRequest` structure represents a request sent from the client to the server when it first connects, asking it to begin initialization in the MCP system.

## Declaration

```swift
public struct InitializeRequest: Request, Codable
```

## Properties

### method

```swift
public var method: String = "initialize"
```

A constant string that identifies this request as an initialization request.

### params

```swift
public var params: RequestParams?
```

The parameters for the request.

## Nested Types

### Params

```swift
public struct Params: Codable
```

A structure that contains the parameters for the initialization request.

#### Properties

##### protocolVersion

```swift
public var protocolVersion: String
```

The latest version of the Model Context Protocol that the client supports. The client may decide to support older versions as well.

##### capabilities

```swift
public var capabilities: ClientCapabilities
```

The capabilities supported by the client.

##### clientInfo

```swift
public var clientInfo: Implementation
```

Information about the client implementation.

#### Initialization

```swift
public init(protocolVersion: String, capabilities: ClientCapabilities, clientInfo: Implementation)
```

Creates a new `Params` instance with the specified protocol version, capabilities, and client information.

## Initialization

```swift
public init(params: Params)
```

Creates a new `InitializeRequest` instance with the specified parameters.
