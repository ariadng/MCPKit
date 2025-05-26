# Implementation

## Overview

The `Implementation` structure describes the name and version of an MCP (Model Context Protocol) implementation.

## Declaration

```swift
public struct Implementation: Codable
```

## Properties

### name

```swift
public var name: String
```

The name of the MCP implementation.

### version

```swift
public var version: String
```

The version of the MCP implementation.

## Initialization

```swift
public init(name: String, version: String)
```

Creates a new `Implementation` instance with the specified name and version.
