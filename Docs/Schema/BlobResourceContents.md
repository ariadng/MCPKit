# BlobResourceContents

`BlobResourceContents` is a structure that represents the binary contents of a resource. It conforms to the `ResourceContents` and `Codable` protocols.

## Declaration

```swift
public struct BlobResourceContents: ResourceContents, Codable
```

## Properties

### `uri: String`

The URI of the resource. The URI can use any protocol; it is up to the server how to interpret it.

### `mimeType: String?`

The MIME type of the resource, if known (e.g., `"application/octet-stream"`, `"image/png"`).

### `blob: String`

The base64-encoded binary content of the resource.

## Initialization

```swift
public init(uri: String, blob: String, mimeType: String? = nil)
```

Initializes a `BlobResourceContents` instance.

- **Parameters:**
  - `uri`: The URI of the resource.
  - `blob`: The base64-encoded binary content.
  - `mimeType`: An optional MIME type for the resource.
