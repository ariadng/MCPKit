# ClientCapabilities

## Overview

The `ClientCapabilities` structure represents the capabilities that a client may support in the MCP system. While known capabilities are defined in this schema, this is not a closed set: any client can define its own additional capabilities.

## Declaration

```swift
public struct ClientCapabilities: Codable
```

## Properties

### experimental

```swift
public var experimental: [String: AnyCodable]?
```

Experimental capabilities. These are not standardized and may change at any time.

### roots

```swift
public var roots: RootsCapabilities?
```

Capabilities related to roots.

### sampling

```swift
public var sampling: SamplingCapabilities?
```

Capabilities related to message sampling, such as handling server-initiated requests to create messages.

## Nested Types

### RootsCapabilities

```swift
public struct RootsCapabilities: Codable
```

A structure that represents capabilities related to roots.

#### Properties

##### listChanged

```swift
public var listChanged: Bool?
```

Whether the client supports notifications for changes to the roots list.

#### Initialization

```swift
public init(listChanged: Bool? = nil)
```

Creates a new `RootsCapabilities` instance with the specified listChanged value.

### SamplingCapabilities

```swift
public struct SamplingCapabilities: Codable
```

A structure that represents capabilities related to message sampling.

#### Properties

##### supportsCreateMessageRequest

```swift
public var supportsCreateMessageRequest: Bool?
```

Whether the client supports handling server-initiated `sampling/createMessage` requests. If `true`, the server may send `sampling/createMessage` requests, and the client is expected to have a handler set for `MCPClient.onSamplingCreateMessage`.

#### Initialization

```swift
public init(supportsCreateMessageRequest: Bool? = nil)
```

Creates a new `SamplingCapabilities` instance.

## Initialization

```swift
public init(experimental: [String: AnyCodable]? = nil, roots: RootsCapabilities? = nil, sampling: SamplingCapabilities? = nil)
```

Creates a new `ClientCapabilities` instance with the specified experimental capabilities, roots capabilities, and sampling capabilities.
