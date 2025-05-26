# ClientNotification

## Overview

The `ClientNotification` enumeration represents a union type of all notifications that can be sent from the client to the server in the MCP system.

## Declaration

```swift
public enum ClientNotification: Codable
```

## Cases

### cancelled

```swift
case cancelled(CancelledNotification)
```

A notification indicating that the client is cancelling a previously-issued request.

### initialized

```swift
case initialized(InitializedNotification)
```

A notification indicating that the client has been initialized.

### rootsListChanged

```swift
case rootsListChanged(RootsListChangedNotification)
```

A notification indicating that the list of roots has changed.

## Initialization

```swift
public init(from decoder: Decoder) throws
```

Creates a new `ClientNotification` instance by decoding from the given decoder. The appropriate case is selected based on the `method` field in the decoded JSON.

## Methods

### encode(to:)

```swift
public func encode(to encoder: Encoder) throws
```

Encodes the `ClientNotification` instance to the given encoder. The encoding depends on the specific case of the enumeration.
