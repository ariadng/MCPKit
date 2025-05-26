# Role

## Overview

The `Role` type represents the sender or recipient of messages and data in a conversation in the MCP system.

## Declaration

```swift
public typealias Role = String
```

## Constants

The following constants are provided for common roles:

### system

```swift
static let system: Role = "system"
```

Represents the system role, typically used for system instructions or prompts.

### user

```swift
static let user: Role = "user"
```

Represents the user role, typically the person interacting with the AI.

### assistant

```swift
static let assistant: Role = "assistant"
```

Represents the assistant role, typically the AI responding to the user.

### function

```swift
static let function: Role = "function"
```

Represents the function role, typically used for function calls or responses.

### tool

```swift
static let tool: Role = "tool"
```

Represents the tool role, typically used for tool calls or responses.
