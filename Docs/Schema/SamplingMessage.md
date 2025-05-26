# SamplingMessage

## Overview

The `SamplingMessage` structure describes a message issued to or received from a language model (LLM) API in the MCP system.

## Declaration

```swift
public struct SamplingMessage: Codable
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

An enumeration that represents different types of content that can be included in a sampling message.

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

## Initialization

```swift
public init(role: Role, content: MessageContent)
```

Creates a new `SamplingMessage` instance with the specified role and content.
