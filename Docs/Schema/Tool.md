# Tool

`Tool` is a structure that defines a tool that the client can call. It includes information about the tool's name, description, input schema, and optional annotations.

## Properties

### `name: String`

The name of the tool.

### `description: String?`

An optional human-readable description of the tool.

### `inputSchema: InputSchema`

The schema for the input to the tool. See `InputSchema` for more details.

### `annotations: ToolAnnotations?`

Optional additional tool information. See `ToolAnnotations` for more details.

## Initialization

```swift
public init(
    name: String,
    description: String? = nil,
    inputSchema: InputSchema,
    annotations: ToolAnnotations? = nil
)
```

Initializes a `Tool` instance.

- **Parameters:**
  - `name`: The name of the tool.
  - `description`: An optional description of the tool.
  - `inputSchema`: The input schema for the tool.
  - `annotations`: Optional `ToolAnnotations` for the tool.

---

## Nested Structures

### `InputSchema`

`InputSchema` defines the schema for the input parameters of a `Tool`.

#### Properties

##### `type: String`

Indicates the type of the schema, which is always `"object"` for this structure.

##### `properties: [String: AnyCodable]?`

A dictionary describing the properties of the input object. The keys are property names, and the values (of type `AnyCodable`) define the schema for each property (e.g., type, description).

##### `required: [String]?`

An optional array of strings listing the names of required properties.

#### Initialization

```swift
public init(properties: [String: AnyCodable]? = nil, required: [String]? = nil)
```

Initializes an `InputSchema` instance.

- **Parameters:**
  - `properties`: An optional dictionary of property schemas.
  - `required`: An optional array of required property names.
