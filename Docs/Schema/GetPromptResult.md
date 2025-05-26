# GetPromptResult

## Overview

The `GetPromptResult` structure represents the server's response to a prompts/get request from the client in the MCP system.

## Declaration

```swift
public struct GetPromptResult: Result, Codable
```

## Properties

### _meta

```swift
public var _meta: [String: AnyCodable]?
```

Optional metadata associated with the result.

### description

```swift
public var description: String?
```

An optional human-readable description of the prompt.

### messages

```swift
public var messages: [PromptMessage]
```

The messages that make up the prompt.

## Initialization

```swift
public init(messages: [PromptMessage], description: String? = nil, _meta: [String: AnyCodable]? = nil)
```

Creates a new `GetPromptResult` instance with the specified messages, optional description, and optional metadata.
