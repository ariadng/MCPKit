# PromptMessage

## Overview

The `PromptMessage` structure describes a message returned as part of a prompt in the MCP system. This is similar to `SamplingMessage`, but also supports the embedding of resources from the MCP server.

## Declaration

```swift
public struct PromptMessage: Codable
```

## Properties

### role

```swift
public var role: Role
```

The role of the entity that created the message.

### content

```swift
public var content: MessageContent
```

The content of the message.

## Nested Types

### MessageContent

```swift
public enum MessageContent: Codable
```

An enumeration that represents different types of content that can be included in a prompt message.

#### Cases

##### text

```swift
case text(TextContent)
```

Text content in the message.

##### image

```swift
case image(ImageContent)
```

Image content in the message.

##### audio

```swift
case audio(AudioContent)
```

Audio content in the message.

##### resource

```swift
case resource(EmbeddedResource)
```

Resource content embedded in the message.

## Initialization

```swift
public init(role: Role, content: MessageContent)
```

Creates a new `PromptMessage` instance with the specified role and content.
