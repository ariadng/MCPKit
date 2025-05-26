# AudioContent

`AudioContent` is a structure that represents audio data provided to or from a Large Language Model (LLM).

## Properties

### `type: String`

Indicates the type of content, which is always `"audio"` for this structure.

### `data: String`

The base64-encoded audio data.

### `mimeType: String`

The MIME type of the audio (e.g., `"audio/mpeg"`, `"audio/wav"`). Different providers may support different audio types.

### `annotations: Annotations?`

Optional annotations for the client, providing additional metadata about the audio content.

## Initialization

```swift
public init(data: String, mimeType: String, annotations: Annotations? = nil)
```

Initializes an `AudioContent` instance.

- **Parameters:**
  - `data`: The base64-encoded audio data.
  - `mimeType`: The MIME type of the audio.
  - `annotations`: Optional `Annotations` for the audio content.
