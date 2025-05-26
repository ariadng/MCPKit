# ToolAnnotations

`ToolAnnotations` is a structure that provides additional properties describing a `Tool` to clients. 

**Important Note:** All properties in `ToolAnnotations` are **hints**. They are not guaranteed to provide a faithful description of tool behavior (including descriptive properties like `title`). Clients should never make tool use decisions based on `ToolAnnotations` received from untrusted servers.

## Properties

### `title: String?`

A human-readable title for the tool.

### `readOnlyHint: Bool?`

Indicates that the tool does not modify any state. If `true`, the tool is considered read-only.

### `destructiveHint: Bool?`

Indicates that the tool may modify state in a way that cannot be undone. If `true`, the tool may have destructive side effects.

### `idempotentHint: Bool?`

Indicates that the tool is idempotent. Calling it multiple times with the same arguments has the same effect as calling it once. If `true`, the tool is considered idempotent.

### `openWorldHint: Bool?`

Indicates that the tool may accept arguments not explicitly listed in its schema. If `true`, the tool might operate with an open-world assumption regarding its arguments.

## Initialization

```swift
public init(
    title: String? = nil,
    readOnlyHint: Bool? = nil,
    destructiveHint: Bool? = nil,
    idempotentHint: Bool? = nil,
    openWorldHint: Bool? = nil
)
```

Initializes a `ToolAnnotations` instance.

- **Parameters:**
  - `title`: An optional human-readable title for the tool.
  - `readOnlyHint`: An optional boolean indicating if the tool is read-only.
  - `destructiveHint`: An optional boolean indicating if the tool may have destructive effects.
  - `idempotentHint`: An optional boolean indicating if the tool is idempotent.
  - `openWorldHint`: An optional boolean indicating if the tool may accept additional arguments.
