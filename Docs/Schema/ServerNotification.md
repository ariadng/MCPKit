# ServerNotification

## Overview

The `ServerNotification` enumeration represents a union type of all notifications that can be sent from the server to the client in the MCP system.

## Declaration

```swift
public enum ServerNotification: Codable
```

## Cases

### cancelled

```swift
case cancelled(CancelledNotification)
```

A notification indicating that the server is cancelling a previously-issued request.

### progress

```swift
case progress(ProgressNotification)
```

A notification providing progress information for a long-running request.

### resourceListChanged

```swift
case resourceListChanged(ResourceListChangedNotification)
```

A notification indicating that the list of resources has changed.

### resourceUpdated

```swift
case resourceUpdated(ResourceUpdatedNotification)
```

A notification indicating that a specific resource has been updated.

### promptListChanged

```swift
case promptListChanged(PromptListChangedNotification)
```

A notification indicating that the list of prompts has changed.

### toolListChanged

```swift
case toolListChanged(ToolListChangedNotification)
```

A notification indicating that the list of tools has changed.

### loggingMessage

```swift
case loggingMessage(LoggingMessageNotification)
```

A notification containing a logging message.

## Initialization

```swift
public init(from decoder: Decoder) throws
```

Creates a new `ServerNotification` instance by decoding from the given decoder. The appropriate case is selected based on the `method` field in the decoded JSON.

## Methods

### encode(to:)

```swift
public func encode(to encoder: Encoder) throws
```

Encodes the `ServerNotification` instance to the given encoder. The encoding depends on the specific case of the enumeration.
