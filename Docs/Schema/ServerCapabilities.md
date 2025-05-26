# ServerCapabilities

## Overview

The `ServerCapabilities` structure represents capabilities that a server may support in the MCP system. Known capabilities are defined in this schema, but this is not a closed set: any server can define its own additional capabilities.

## Declaration

```swift
public struct ServerCapabilities: Codable
```

## Properties

### experimental

```swift
public var experimental: [String: AnyCodable]?
```

Experimental capabilities. These are not standardized and may change at any time.

### logging

```swift
public var logging: AnyCodable?
```

Capabilities related to logging.

### completions

```swift
public var completions: AnyCodable?
```

Capabilities related to completions.

### prompts

```swift
public var prompts: PromptsCapabilities?
```

Capabilities related to prompts.

### resources

```swift
public var resources: ResourcesCapabilities?
```

Capabilities related to resources.

### tools

```swift
public var tools: ToolsCapabilities?
```

Capabilities related to tools.

## Nested Types

### PromptsCapabilities

```swift
public struct PromptsCapabilities: Codable
```

A structure that represents capabilities related to prompts.

#### Properties

##### listChanged

```swift
public var listChanged: Bool?
```

Whether this server supports notifications for changes to the prompt list.

#### Initialization

```swift
public init(listChanged: Bool? = nil)
```

Creates a new `PromptsCapabilities` instance with the specified listChanged value.

### ResourcesCapabilities

```swift
public struct ResourcesCapabilities: Codable
```

A structure that represents capabilities related to resources.

#### Properties

##### subscribe

```swift
public var subscribe: Bool?
```

Whether this server supports subscribing to resource updates.

##### listChanged

```swift
public var listChanged: Bool?
```

Whether this server supports notifications for changes to the resource list.

#### Initialization

```swift
public init(subscribe: Bool? = nil, listChanged: Bool? = nil)
```

Creates a new `ResourcesCapabilities` instance with the specified subscribe and listChanged values.

### ToolsCapabilities

```swift
public struct ToolsCapabilities: Codable
```

A structure that represents capabilities related to tools.

#### Properties

##### listChanged

```swift
public var listChanged: Bool?
```

Whether this server supports notifications for changes to the tool list.

#### Initialization

```swift
public init(listChanged: Bool? = nil)
```

Creates a new `ToolsCapabilities` instance with the specified listChanged value.

## Initialization

```swift
public init(
    experimental: [String: AnyCodable]? = nil,
    logging: AnyCodable? = nil,
    completions: AnyCodable? = nil,
    prompts: PromptsCapabilities? = nil,
    resources: ResourcesCapabilities? = nil,
    tools: ToolsCapabilities? = nil
)
```

Creates a new `ServerCapabilities` instance with the specified capabilities.
