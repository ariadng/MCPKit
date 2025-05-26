# Request

## Overview

The `Request` protocol serves as the base interface for all requests in the MCP system.

## Declaration

```swift
public protocol Request: Codable
```

## Requirements

### method

```swift
var method: String { get }
```

The method name of the request.

### params

```swift
var params: RequestParams? { get }
```

The parameters for the request.

## Related Types

### RequestParams

```swift
public struct RequestParams: Codable
```

A structure that represents the parameters for a request.

#### Properties

##### _meta

```swift
public var _meta: RequestMeta?
```

Metadata associated with the request.

##### additionalProperties

```swift
private var additionalProperties: [String: AnyCodable]
```

A dictionary of additional properties that can be included in the request parameters.

#### Subscript

```swift
public subscript(key: String) -> AnyCodable?
```

Provides dictionary-like access to the additional properties.

#### Initialization

```swift
public init(_meta: RequestMeta? = nil, additionalProperties: [String: AnyCodable] = [:])
```

Creates a new `RequestParams` instance with the specified metadata and additional properties.

### RequestMeta

```swift
public struct RequestMeta: Codable
```

A structure that represents metadata associated with a request.

#### Properties

##### progressToken

```swift
public var progressToken: ProgressToken?
```

If specified, the caller is requesting out-of-band progress notifications for this request (as represented by notifications/progress). The value of this parameter is an opaque token that will be attached to any subsequent notifications. The receiver is not obligated to provide these notifications.

#### Initialization

```swift
public init(progressToken: ProgressToken? = nil)
```

Creates a new `RequestMeta` instance with an optional progress token.
