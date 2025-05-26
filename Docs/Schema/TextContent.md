# TextContent

`TextContent` is a structure that represents text provided to or from a Large Language Model (LLM).

## Properties

### `type: String`

Indicates the type of content, which is always `"text"` for this structure.

### `text: String`

The text content of the message.

### `annotations: Annotations?`

Optional annotations for the client, providing additional metadata about the text content.

## Initialization

```swift
public init(text: String, annotations: Annotations? = nil)
```

Initializes a `TextContent` instance.

- **Parameters:**
  - `text`: The text content.
  - `annotations`: Optional `Annotations` for the text content.
