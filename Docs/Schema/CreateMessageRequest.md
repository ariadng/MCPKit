# CreateMessageRequest

## Overview

The `CreateMessageRequest` structure represents a request from the server to sample a language model (LLM) via the client in the MCP system. The client has full discretion over which model to select and should inform the user before beginning sampling to allow them to inspect the request and decide whether to approve it.

## Declaration

```swift
public struct CreateMessageRequest: Request, Codable
```

## Properties

### method

```swift
public var method: String = "sampling/createMessage"
```

A constant string that identifies this request as a create message request.

### params

```swift
public var params: RequestParams?
```

The parameters for the request.

## Nested Types

### Params

```swift
public struct Params: Codable
```

A structure that contains the parameters for the create message request.

#### Properties

##### messages

```swift
public var messages: [SamplingMessage]
```

The messages to be used for sampling.

##### modelPreferences

```swift
public var modelPreferences: ModelPreferences?
```

The server's preferences for which model to select. The client may ignore these preferences.

##### systemPrompt

```swift
public var systemPrompt: String?
```

An optional system prompt the server wants to use for sampling. The client may modify or omit this prompt.

##### includeContext

```swift
public var includeContext: IncludeContext?
```

A request to include context from one or more MCP servers (including the caller), to be attached to the prompt. The client may ignore this request.

##### temperature

```swift
public var temperature: Double?
```

Temperature for sampling.

##### maxTokens

```swift
public var maxTokens: Int
```

The maximum number of tokens to sample, as requested by the server. The client may choose to sample fewer tokens than requested.

##### stopSequences

```swift
public var stopSequences: [String]?
```

Sequences that will stop generation if encountered.

##### metadata

```swift
public var metadata: AnyCodable?
```

Optional metadata to pass through to the LLM provider. The format of this metadata is provider-specific.

### IncludeContext

```swift
public enum IncludeContext: String, Codable
```

An enumeration that represents options for including context in the sampling.

#### Cases

##### none

```swift
case none = "none"
```

Do not include any context.

##### thisServer

```swift
case thisServer = "thisServer"
```

Include context from the server making the request.

##### allServers

```swift
case allServers = "allServers"
```

Include context from all servers.

## Initialization

```swift
public init(params: Params)
```

Creates a new `CreateMessageRequest` instance with the specified parameters.
