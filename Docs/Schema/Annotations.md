# Annotations

`Annotations` is a structure that provides optional metadata for the client. The client can use these annotations to inform how objects are used or displayed.

## Declaration

```swift
public struct Annotations: Codable
```

## Properties

### `audience: [Role]?`

Describes who the intended customer of this object or data is. It can include multiple entries to indicate content useful for multiple audiences (e.g., `["user", "assistant"]`).

### `priority: Double?`

Describes how important this data is for operating the server.

- A value of `1` means "most important," and indicates that the data is effectively required.
- A value of `0` means "least important," and indicates that the data is entirely optional.

## Initialization

```swift
public init(audience: [Role]? = nil, priority: Double? = nil)
```

Initializes an `Annotations` instance.

- **Parameters:**
  - `audience`: An optional array of `Role` indicating the intended audience.
  - `priority`: An optional `Double` indicating the importance of the data.
