# Constants

## Overview

The `Constants` enumeration provides constant values used throughout the Model Context Protocol (MCP) system.

## Declaration

```swift
public enum Constants
```

## Constants

### LATEST_PROTOCOL_VERSION

```swift
public static let LATEST_PROTOCOL_VERSION = "2025-03-26"
```

The latest version of the Model Context Protocol.

### JSONRPC_VERSION

```swift
public static let JSONRPC_VERSION = "2.0"
```

The JSON-RPC version used by the MCP system.

### Standard JSON-RPC Error Codes

```swift
public static let PARSE_ERROR = -32700
```

Error code indicating that the JSON received by the server is not well-formed.

```swift
public static let INVALID_REQUEST = -32600
```

Error code indicating that the JSON sent is not a valid Request object.

```swift
public static let METHOD_NOT_FOUND = -32601
```

Error code indicating that the method does not exist or is not available.

```swift
public static let INVALID_PARAMS = -32602
```

Error code indicating that the parameters provided are invalid for the method.

```swift
public static let INTERNAL_ERROR = -32603
```

Error code indicating that an internal error occurred on the server.
