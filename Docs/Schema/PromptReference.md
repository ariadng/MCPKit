# PromptReference

## Overview

The `PromptReference` structure identifies a prompt in the MCP system.

## Declaration

```swift
public struct PromptReference: Codable
```

## Properties

### type

```swift
public var type: String = "ref/prompt"
```

A constant string that identifies this as a prompt reference.

### name

```swift
public var name: String
```

The name of the prompt.

## Initialization

```swift
public init(name: String)
```

Creates a new `PromptReference` instance with the specified prompt name.
