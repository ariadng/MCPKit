# PromptListChangedNotification

## Overview

The `PromptListChangedNotification` structure represents an optional notification from the server to the client, informing it that the list of prompts it offers has changed in the MCP system. This may be issued by servers without any previous subscription from the client.

## Declaration

```swift
public struct PromptListChangedNotification: Notification, Codable
```

## Properties

### method

```swift
public var method: String = "notifications/prompts/list_changed"
```

A constant string that identifies this notification as a prompt list changed notification.

### params

```swift
public var params: NotificationParams?
```

The parameters for the notification. This is typically nil for the prompt list changed notification.

## Initialization

```swift
public init()
```

Creates a new `PromptListChangedNotification` instance with no parameters.
