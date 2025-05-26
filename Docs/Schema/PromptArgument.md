# PromptArgument

## Overview

The `PromptArgument` structure describes an argument that a prompt can accept in the MCP system.

## Declaration

```swift
public struct PromptArgument: Codable
```

## Properties

### name

```swift
public var name: String
```

The name of the argument.

### description

```swift
public var description: String?
```

An optional human-readable description of the argument.

### required

```swift
public var required: Bool?
```

Whether this argument is required.

## Initialization

```swift
public init(name: String, description: String? = nil, required: Bool? = nil)
```

Creates a new `PromptArgument` instance with the specified name, optional description, and optional required flag.
