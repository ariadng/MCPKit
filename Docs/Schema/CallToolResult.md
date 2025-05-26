# CallToolResult

## Overview

The `CallToolResult` structure represents the server's response to a tool call in the MCP system.

## Declaration

```swift
public struct CallToolResult: Result, Codable
```

## Properties

### _meta

```swift
public var _meta: [String: AnyCodable]?
```

Optional metadata associated with the result.

### content

```swift
public var content: [ContentType]
```

The content returned by the tool.

### isError

```swift
public var isError: Bool?
```

Indicates whether the tool call resulted in an error. Any errors that originate from the tool should be reported inside the result object with `isError` set to true, not as an MCP protocol-level error response. This allows the LLM to see that an error occurred and self-correct.

## Nested Types

### ContentType

```swift
public enum ContentType: Codable
```

An enumeration that represents different types of content that can be returned by a tool.

#### Cases

##### text

```swift
case text(TextContent)
```

Text content returned by the tool.

##### image

```swift
case image(ImageContent)
```

Image content returned by the tool.

##### audio

```swift
case audio(AudioContent)
```

Audio content returned by the tool.

##### resource

```swift
case resource(EmbeddedResource)
```

Resource content returned by the tool.

## Initialization

```swift
public init(content: [ContentType], isError: Bool? = nil, _meta: [String: AnyCodable]? = nil)
```

Creates a new `CallToolResult` instance with the specified content, error status, and optional metadata.

## Notes

Errors in finding the tool, errors indicating that the server does not support tool calls, or any other exceptional conditions should be reported as an MCP error response, not as a `CallToolResult` with `isError` set to true.
