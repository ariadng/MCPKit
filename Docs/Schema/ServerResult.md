# ServerResult

## Overview

The `ServerResult` enumeration represents a union type of all result types that can be returned from the server to the client in the MCP system.

## Declaration

```swift
public enum ServerResult: Codable
```

## Cases

### empty

```swift
case empty(EmptyResult)
```

An empty result with no specific data.

### initialize

```swift
case initialize(InitializeResult)
```

A result from initializing the connection between the server and client.

### listResources

```swift
case listResources(ListResourcesResult)
```

A result containing a list of resources.

### listResourceTemplates

```swift
case listResourceTemplates(ListResourceTemplatesResult)
```

A result containing a list of resource templates.

### readResource

```swift
case readResource(ReadResourceResult)
```

A result containing the contents of a resource.

### listPrompts

```swift
case listPrompts(ListPromptsResult)
```

A result containing a list of prompts.

### getPrompt

```swift
case getPrompt(GetPromptResult)
```

A result containing a specific prompt.

### listTools

```swift
case listTools(ListToolsResult)
```

A result containing a list of tools.

### callTool

```swift
case callTool(CallToolResult)
```

A result from calling a tool.

### complete

```swift
case complete(CompleteResult)
```

A result from completing a prompt.

## Initialization

```swift
public init(from decoder: Decoder) throws
```

Creates a new `ServerResult` instance by decoding from the given decoder. The appropriate case is selected based on the presence of specific fields in the decoded JSON.

## Methods

### encode(to:)

```swift
public func encode(to encoder: Encoder) throws
```

Encodes the `ServerResult` instance to the given encoder. The encoding depends on the specific case of the enumeration.
