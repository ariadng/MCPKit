# Prompt

## Overview

The `Prompt` structure represents a prompt or prompt template that the server offers in the MCP system.

## Declaration

```swift
public struct Prompt: Codable
```

## Properties

### name

```swift
public var name: String
```

The name of the prompt or prompt template.

### description

```swift
public var description: String?
```

An optional human-readable description of the prompt.

### arguments

```swift
public var arguments: [PromptArgument]?
```

The arguments that this prompt template accepts, if any.

## Initialization

```swift
public init(name: String, description: String? = nil, arguments: [PromptArgument]? = nil)
```

Creates a new `Prompt` instance with the specified name, optional description, and optional arguments.
