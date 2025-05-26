# ModelHint

## Overview

The `ModelHint` structure provides hints to use for model selection in the MCP system. Keys not declared in this structure are currently left unspecified by the specification and are up to the client to interpret.

## Declaration

```swift
public struct ModelHint: Codable
```

## Properties

### name

```swift
public var name: String?
```

The name of a specific model that the server would prefer to use.

## Initialization

```swift
public init(name: String? = nil)
```

Creates a new `ModelHint` instance with an optional model name.
