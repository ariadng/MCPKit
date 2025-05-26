# Cursor

## Overview

The `Cursor` type represents an opaque token used for pagination in the MCP system.

## Declaration

```swift
public typealias Cursor = String
```

## Usage

A cursor is typically returned by API endpoints that support pagination. When more results are available than can be returned in a single response, the API will include a cursor that can be used in a subsequent request to retrieve the next set of results.

The content of a cursor is opaque and should be treated as a black box by clients. Clients should not attempt to parse or modify the cursor value, but should simply pass it back to the API as provided.
