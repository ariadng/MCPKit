# InitializeResult

## Overview

The `InitializeResult` structure represents the response sent by the server after receiving an initialize request from the client in the MCP system.

## Declaration

```swift
public struct InitializeResult: Result, Codable
```

## Properties

### _meta

```swift
public var _meta: [String: AnyCodable]?
```

Optional metadata associated with the result.

### protocolVersion

```swift
public var protocolVersion: String
```

The version of the Model Context Protocol that the server wants to use. This may not match the version that the client requested. If the client cannot support this version, it must disconnect.

### capabilities

```swift
public var capabilities: ServerCapabilities
```

The server's capabilities.

### serverInfo

```swift
public var serverInfo: Implementation
```

Information about the server implementation.

### instructions

```swift
public var instructions: String?
```

Instructions describing how to use the server and its features. This can be used by clients to improve the LLM's understanding of available tools, resources, etc. It can be thought of like a "hint" to the model. For example, this information may be added to the system prompt.

## Initialization

```swift
public init(
    protocolVersion: String,
    capabilities: ServerCapabilities,
    serverInfo: Implementation,
    instructions: String? = nil,
    _meta: [String: AnyCodable]? = nil
)
```

Creates a new `InitializeResult` instance with the specified protocol version, capabilities, server information, optional instructions, and optional metadata.
