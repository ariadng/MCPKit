# TextResourceContents

`TextResourceContents` is a structure that represents the text content of a resource. It conforms to the `ResourceContents` and `Codable` protocols.

## Properties

### `uri: String`

The URI of the resource. The URI can use any protocol; it is up to the server how to interpret it.

### `mimeType: String?`

The MIME type of the resource, if known (e.g., `"text/plain"`, `"text/markdown"`).

### `text: String`

The text content of the resource.

## Initialization

```swift
public init(uri: String, text: String, mimeType: String? = nil)
```

Initializes a `TextResourceContents` instance.

- **Parameters:**
  - `uri`: The URI of the resource.
  - `text`: The text content of the resource.
  - `mimeType`: An optional MIME type for the resource.
