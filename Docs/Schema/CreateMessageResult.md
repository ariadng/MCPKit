# CreateMessageResult

## Overview

The `CreateMessageResult` structure represents the client's response to a sampling/create_message request from the server in the MCP system. The client should inform the user before returning the sampled message, to allow them to inspect the response (human in the loop) and decide whether to allow the server to see it.

## Declaration

```swift
public struct CreateMessageResult: Result, Codable
```

## Properties

### _meta

```swift
public var _meta: [String: AnyCodable]?
```

Optional metadata associated with the result.

### role

```swift
public var role: Role
```

The role of the entity that generated the message.

### content

```swift
public var content: SamplingMessage.MessageContent
```

The content of the generated message.

### model

```swift
public var model: String
```

The name of the model that generated the message.

### stopReason

```swift
public var stopReason: String?
```

The reason why sampling stopped, if known.

## Initialization

```swift
public init(role: Role, content: SamplingMessage.MessageContent, model: String, stopReason: String? = nil, _meta: [String: AnyCodable]? = nil)
```

Creates a new `CreateMessageResult` instance with the specified role, content, model, optional stop reason, and optional metadata.
