# ResourceTemplate

## Overview

The `ResourceTemplate` structure represents a template description for resources available on the server in the MCP system.

## Declaration

```swift
public struct ResourceTemplate: Codable
```

## Properties

### uriTemplate

```swift
public var uriTemplate: String
```

A template for the URI of the resource. The URI can use any protocol; it is up to the server how to interpret it. The template may contain placeholders in the form {name} which can be replaced with values to generate a valid URI.

### name

```swift
public var name: String
```

A human-readable name for the resource template.

### description

```swift
public var description: String?
```

An optional human-readable description of the resource template.

### mimeType

```swift
public var mimeType: String?
```

The MIME type of resources generated from this template, if known.

### annotations

```swift
public var annotations: Annotations?
```

Optional annotations for the client.

## Initialization

```swift
public init(
    uriTemplate: String,
    name: String,
    description: String? = nil,
    mimeType: String? = nil,
    annotations: Annotations? = nil
)
```

Creates a new `ResourceTemplate` instance with the specified URI template, name, and optional properties.
