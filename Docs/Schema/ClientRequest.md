# ClientRequest

## Overview

The `ClientRequest` enumeration represents a union type of all requests that can be sent from the client to the server in the MCP system.

## Declaration

```swift
public enum ClientRequest: Codable
```

## Cases

### initialize

```swift
case initialize(InitializeRequest)
```

A request to initialize the connection between the client and server.

### ping

```swift
case ping(PingRequest)
```

A ping request to check if the server is responsive.

### listResources

```swift
case listResources(ListResourcesRequest)
```

A request to list available resources.

### listResourceTemplates

```swift
case listResourceTemplates(ListResourceTemplatesRequest)
```

A request to list available resource templates.

### readResource

```swift
case readResource(ReadResourceRequest)
```

A request to read a specific resource.

### subscribe

```swift
case subscribe(SubscribeRequest)
```

A request to subscribe to notifications.

### unsubscribe

```swift
case unsubscribe(UnsubscribeRequest)
```

A request to unsubscribe from notifications.

### listPrompts

```swift
case listPrompts(ListPromptsRequest)
```

A request to list available prompts.

### getPrompt

```swift
case getPrompt(GetPromptRequest)
```

A request to get a specific prompt.

### listTools

```swift
case listTools(ListToolsRequest)
```

A request to list available tools.

### callTool

```swift
case callTool(CallToolRequest)
```

A request to call a specific tool.

### setLevel

```swift
case setLevel(SetLevelRequest)
```

A request to set the logging level.

### complete

```swift
case complete(CompleteRequest)
```

A request to complete a prompt.

## Initialization

```swift
public init(from decoder: Decoder) throws
```

Creates a new `ClientRequest` instance by decoding from the given decoder. The appropriate case is selected based on the `method` field in the decoded JSON.

## Methods

### encode(to:)

```swift
public func encode(to encoder: Encoder) throws
```

Encodes the `ClientRequest` instance to the given encoder. The encoding depends on the specific case of the enumeration.
