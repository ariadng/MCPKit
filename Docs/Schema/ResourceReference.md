# ResourceReference

## Overview

The `ResourceReference` structure represents a reference to a resource or resource template definition in the MCP system.

## Declaration

```swift
public struct ResourceReference: Codable
```

## Properties

### type

```swift
public var type: String = "ref/resource"
```

A constant string that identifies this as a resource reference.

### uri

```swift
public var uri: String
```

The URI of the resource. The URI can use any protocol; it is up to the server how to interpret it.

## Initialization

```swift
public init(uri: String)
```

Creates a new `ResourceReference` instance with the specified resource URI.
