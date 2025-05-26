# UnsubscribeRequest

`UnsubscribeRequest` is a structure sent from the client to the server to request the cancellation of notifications for updates to a specific resource. This request should typically follow a previous `resources/subscribe` request for that same resource.

It conforms to the `Request` and `Codable` protocols.

## Properties

### `method: String`

A string indicating the request method, which is always `"resources/unsubscribe"` for this structure.

### `params: RequestParams?`

Parameters for the request, containing the URI of the resource to unsubscribe from. See `Params` for more details.

## Initialization

```swift
public init(uri: String)
```

Initializes an `UnsubscribeRequest` instance.

- **Parameters:**
  - `uri`: The URI of the resource to unsubscribe from.

---

## Nested Structures

### `Params`

`Params` is a nested structure within `UnsubscribeRequest` that holds the parameters for the unsubscribe request.

#### Properties

##### `uri: String`

The URI of the resource from which the client wishes to unsubscribe from updates.

#### Initialization

```swift
public init(uri: String)
```

Initializes a `Params` instance.

- **Parameters:**
  - `uri`: The URI of the resource.
