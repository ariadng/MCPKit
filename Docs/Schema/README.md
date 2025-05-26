# MCPKit Schema Documentation

This directory contains the documentation for the various data structures and protocols defined in the MCPKit Schema. These components form the backbone of communication and data representation within the Model-Context Protocol implementation.

Below is an categorized index of the available schema documentation. Each item links to its detailed documentation page and provides a brief description.

## Categories

- [Requests](#requests)
- [Results & Responses](#results--responses)
- [Notifications](#notifications)
- [Content & Resource Structures](#content--resource-structures)
- [Capabilities & Configuration](#capabilities--configuration)
- [Prompts & Tools](#prompts--tools)
- [JSON-RPC Specific](#json-rpc-specific)
- [Core & Utility Structures](#core--utility-structures)

---

## Requests

- [`CallToolRequest`](./CallToolRequest.md): The `CallToolRequest` structure is used by the client to invoke a tool provided by the server in the MCP system.
- [`ClientRequest`](./ClientRequest.md): The `ClientRequest` enumeration represents a union type of all requests that can be sent from the client to the server in the MCP system.
- [`CompleteRequest`](./CompleteRequest.md): The `CompleteRequest` structure represents a request from the client to the server to ask for completion options in the MCP system.
- [`CreateMessageRequest`](./CreateMessageRequest.md): The `CreateMessageRequest` structure represents a request from the server to sample a language model (LLM) via the client in the MCP system. The client has full discretion over which model to select and should inform the user before beginning sampling to allow them to inspect the request and decide whether to approve it.
- [`GetPromptRequest`](./GetPromptRequest.md): The `GetPromptRequest` structure is used by the client to get a prompt provided by the server in the MCP system.
- [`InitializeRequest`](./InitializeRequest.md): The `InitializeRequest` structure represents a request sent from the client to the server when it first connects, asking it to begin initialization in the MCP system.
- [`ListPromptsRequest`](./ListPromptsRequest.md): The `ListPromptsRequest` structure represents a request sent from the client to request a list of prompts and prompt templates the server has in the MCP system.
- [`ListResourceTemplatesRequest`](./ListResourceTemplatesRequest.md): The `ListResourceTemplatesRequest` structure represents a request sent from the client to request a list of resource templates the server has in the MCP system.
- [`ListResourcesRequest`](./ListResourcesRequest.md): The `ListResourcesRequest` structure represents a request sent from the client to request a list of resources the server has in the MCP system.
- [`ListRootsRequest`](./ListRootsRequest.md): The `ListRootsRequest` structure represents a request sent from the server to request a list of root URIs from the client in the MCP system. Roots allow servers to ask for specific directories or files to operate on. A common example for roots is providing a set of repositories or directories a server should operate on.
- [`ListToolsRequest`](./ListToolsRequest.md): The `ListToolsRequest` structure represents a request sent from the client to request a list of tools the server has in the MCP system.
- [`ServerNotification`](./ServerNotification.md): The `ServerNotification` enumeration represents a union type of all notifications that can be sent from the server to the client in the MCP system.
- [`ServerRequest`](./ServerRequest.md): The `ServerRequest` enumeration represents a union type of all requests that can be sent from the server to the client in the MCP system.
- [`ServerResult`](./ServerResult.md): The `ServerResult` enumeration represents a union type of all result types that can be returned from the server to the client in the MCP system.
- [`SubscribeRequest`](./SubscribeRequest.md): The `SubscribeRequest` structure represents a request sent from the client to request resources/updated notifications from the server whenever a particular resource changes in the MCP system.
- [`UnsubscribeRequest`](./UnsubscribeRequest.md): `UnsubscribeRequest` is a structure sent from the client to the server to request the cancellation of notifications for updates to a specific resource. This request should typically follow a previous `resources/subscribe` request for that same resource.

---

## Results & Responses

- [`CallToolResult`](./CallToolResult.md): The `CallToolResult` structure represents the server's response to a tool call in the MCP system.
- [`ClientResult`](./ClientResult.md): The `ClientResult` enumeration represents a union type of all result types that can be returned from the client to the server in the MCP system.
- [`CompleteResult`](./CompleteResult.md): The `CompleteResult` structure represents the server's response to a completion/complete request in the MCP system.
- [`CreateMessageResult`](./CreateMessageResult.md): The `CreateMessageResult` structure represents the client's response to a sampling/create_message request from the server in the MCP system. The client should inform the user before returning the sampled message, to allow them to inspect the response (human in the loop) and decide whether to allow the server to see it.
- [`EmptyResult`](./EmptyResult.md): The `EmptyResult` structure represents a response that indicates success but carries no data in the MCP system.
- [`GetPromptResult`](./GetPromptResult.md): The `GetPromptResult` structure represents the server's response to a prompts/get request from the client in the MCP system.
- [`InitializeResult`](./InitializeResult.md): The `InitializeResult` structure represents the response sent by the server after receiving an initialize request from the client in the MCP system.
- [`ListPromptsResult`](./ListPromptsResult.md): The `ListPromptsResult` structure represents the server's response to a prompts/list request from the client in the MCP system.
- [`ListResourceTemplatesResult`](./ListResourceTemplatesResult.md): The `ListResourceTemplatesResult` structure represents the server's response to a resources/templates/list request from the client in the MCP system.
- [`ListResourcesResult`](./ListResourcesResult.md): The `ListResourcesResult` structure represents the server's response to a resources/list request from the client in the MCP system.
- [`ListRootsResult`](./ListRootsResult.md): The `ListRootsResult` structure represents the client's response to a roots/list request from the server in the MCP system. This result contains an array of Root objects, each representing a root directory or file that the server can operate on.
- [`ListToolsResult`](./ListToolsResult.md): The `ListToolsResult` structure represents the server's response to a tools/list request from the client in the MCP system.
- [`ServerResult`](./ServerResult.md): The `ServerResult` enumeration represents a union type of all result types that can be returned from the server to the client in the MCP system.

---

## Notifications

- [`CancelledNotification`](./CancelledNotification.md): Notifies about the cancellation of a request or operation.
- [`ClientNotification`](./ClientNotification.md): Represents a generic notification sent from the client.
- [`InitializedNotification`](./InitializedNotification.md): Notifies that the initialization handshake is complete.
- [`LoggingMessageNotification`](./LoggingMessageNotification.md): The `LoggingMessageNotification` structure represents a notification of a log message passed from server to client in the MCP system. If no logging/setLevel request has been sent from the client, the server may decide which messages to send automatically.
- [`ProgressNotification`](./ProgressNotification.md): The `ProgressNotification` structure represents an out-of-band notification used to inform the receiver of a progress update for a long-running request in the MCP system.
- [`PromptListChangedNotification`](./PromptListChangedNotification.md): Notifies that the list of available prompts has changed.
- [`ResourceListChangedNotification`](./ResourceListChangedNotification.md): Notifies that the list of available resources has changed.
- [`ResourceUpdatedNotification`](./ResourceUpdatedNotification.md): Notifies that a specific resource has been updated.
- [`RootsListChangedNotification`](./RootsListChangedNotification.md): Notifies that the list of available roots has changed.
- [`ServerNotification`](./ServerNotification.md): The `ServerNotification` enumeration represents a union type of all notifications that can be sent from the server to the client in the MCP system.
- [`ToolListChangedNotification`](./ToolListChangedNotification.md): `ToolListChangedNotification` is a structure that represents an optional notification from the server to the client. It informs the client that the list of tools offered by the server has changed. This notification may be issued by servers without any previous subscription from the client.

---

## Content & Resource Structures

- [`Annotations`](./Annotations.md): `Annotations` is a structure that provides optional metadata for the client. The client can use these annotations to inform how objects are used or displayed.
- [`AnyCodable`](./AnyCodable.md): The `AnyCodable` structure provides a type-erased `Codable` value that can be used to encode and decode values of any type that conforms to the `Codable` protocol in the MCP system.
- [`AudioContent`](./AudioContent.md): `AudioContent` is a structure that represents audio data provided to or from a Large Language Model (LLM).
- [`BlobResourceContents`](./BlobResourceContents.md): `BlobResourceContents` is a structure that represents the binary contents of a resource. It conforms to the `ResourceContents` and `Codable` protocols.
- [`Cursor`](./Cursor.md): The `Cursor` type represents an opaque token used for pagination in the MCP system.
- [`EmbeddedResource`](./EmbeddedResource.md): The `EmbeddedResource` structure represents the contents of a resource embedded into a prompt or tool call result in the MCP system. It is up to the client how best to render embedded resources for the benefit of the language model and/or the user.
- [`ImageContent`](./ImageContent.md): The `ImageContent` structure represents an image that can be provided to or from a language model (LLM) in the MCP system.
- [`MCPSchema`](./MCPSchema.md): The `MCPSchema` file provides a convenient way to import all the Model Context Protocol schema types in the MCPKit framework. It serves as the Swift equivalent of a TypeScript index.ts file.
- [`PaginatedResult`](./PaginatedResult.md): The `PaginatedResult` protocol serves as the base interface for paginated results in the MCP system.
- [`Prompt`](./Prompt.md): The `Prompt` structure represents a prompt or prompt template that the server offers in the MCP system.
- [`ProgressToken`](./ProgressToken.md): The `ProgressToken` enumeration represents a progress token, used to associate progress notifications with the original request in the MCP system.
- [`RequestId`](./RequestId.md): The `RequestId` enumeration represents a uniquely identifying ID for a request in JSON-RPC used by the MCP system.
- [`Resource`](./Resource.md): The `Resource` structure represents a known resource that the server is capable of reading in the MCP system.
- [`ResourceContents`](./ResourceContents.md): The `ResourceContents` protocol represents the contents of a specific resource or sub-resource in the MCP system.
- [`ResourceTemplate`](./ResourceTemplate.md): The `ResourceTemplate` structure represents a template description for resources available on the server in the MCP system.
- [`Result`](./Result.md): The `Result` protocol serves as the base interface for all results in the MCP system.
- [`Role`](./Role.md): The `Role` type represents the sender or recipient of messages and data in a conversation in the MCP system.
- [`Root`](./Root.md): The `Root` structure represents a root directory or file that the server can operate on in the MCP system.
- [`TextContent`](./TextContent.md): `TextContent` is a structure that represents text provided to or from a Large Language Model (LLM).
- [`TextResourceContents`](./TextResourceContents.md): `TextResourceContents` is a structure that represents the text content of a resource. It conforms to the `ResourceContents` and `Codable` protocols.
- [`Tool`](./Tool.md): `Tool` is a structure that defines a tool that the client can call. It includes information about the tool's name, description, input schema, and optional annotations.
- [`ToolAnnotations`](./ToolAnnotations.md): `ToolAnnotations` is a structure that provides additional properties describing a `Tool` to clients.

- [`AudioContent`](./AudioContent.md): `AudioContent` is a structure that represents audio data provided to or from an LLM.
- [`BlobResourceContents`](./BlobResourceContents.md): `BlobResourceContents` is a structure that represents the binary contents of a resource.
- [`EmbeddedResource`](./EmbeddedResource.md): Represents a resource that is embedded directly.
- [`ImageContent`](./ImageContent.md): Represents image data provided to or from an LLM.
- [`ListResourceTemplatesRequest`](./ListResourceTemplatesRequest.md): Defines a request to list available resource templates.
- [`ListResourceTemplatesResult`](./ListResourceTemplatesResult.md): Represents the result of listing available resource templates.
- [`ListResourcesRequest`](./ListResourcesRequest.md): Defines a request to list available resources.
- [`ListResourcesResult`](./ListResourcesResult.md): Represents the result of listing available resources.
- [`ListRootsRequest`](./ListRootsRequest.md): Defines a request to list available roots (e.g., workspace directories).
- [`ListRootsResult`](./ListRootsResult.md): Represents the result of listing available roots.
- [`ReadResourceRequest`](./ReadResourceRequest.md): Defines a request to read a specific resource.
- [`ReadResourceResult`](./ReadResourceResult.md): Represents the result of a read resource request, containing the resource contents.
- [`Resource`](./Resource.md): Represents a server-readable resource.
- [`ResourceContents`](./ResourceContents.md): Defines a protocol for the contents of a resource.
- [`ResourceReference`](./ResourceReference.md): Provides a reference to a specific resource.
- [`ResourceTemplate`](./ResourceTemplate.md): Describes a template for creating resources.
- [`Root`](./Root.md): Represents a server-operable directory or file system root.
- [`SubscribeRequest`](./SubscribeRequest.md): Defines a request to subscribe to updates for a specific resource.
- [`TextContent`](./TextContent.md): `TextContent` is a structure that represents text provided to or from an LLM.
- [`TextResourceContents`](./TextResourceContents.md): `TextResourceContents` is a structure that represents the text content of a resource.
- [`UnsubscribeRequest`](./UnsubscribeRequest.md): `UnsubscribeRequest` is a structure sent from the client to request cancellation of resource update notifications.

---

## Capabilities & Configuration

- [`ClientCapabilities`](./ClientCapabilities.md): The `ClientCapabilities` structure represents the capabilities that a client may support in the MCP system. While known capabilities are defined in this schema, this is not a closed set: any client can define its own additional capabilities.
- [`Constants`](./Constants.md): The `Constants` enumeration provides constant values used throughout the Model Context Protocol (MCP) system.
- [`Implementation`](./Implementation.md): The `Implementation` structure describes the name and version of an MCP (Model Context Protocol) implementation.
- [`LoggingLevel`](./LoggingLevel.md): The `LoggingLevel` enumeration represents the severity of a log message in the MCP system. These map to syslog message severities, as specified in [RFC-5424](https://datatracker.ietf.org/doc/html/rfc5424#section-6.2.1).
- [`ModelHint`](./ModelHint.md): The `ModelHint` structure provides hints to use for model selection in the MCP system. Keys not declared in this structure are currently left unspecified by the specification and are up to the client to interpret.
- [`ModelPreferences`](./ModelPreferences.md): The `ModelPreferences` structure represents the server's preferences for model selection, requested of the client during sampling in the MCP system.

- [`ClientCapabilities`](./ClientCapabilities.md): Describes the capabilities of the client.
- [`LoggingLevel`](./LoggingLevel.md): Defines the different levels for logging.
- [`ModelHint`](./ModelHint.md): Provides hints for model selection.
- [`ModelPreferences`](./ModelPreferences.md): Details server preferences for model selection.
- [`ServerCapabilities`](./ServerCapabilities.md): Describes the capabilities of the server.

---

## Prompts & Tools

- [`CallToolRequest`](./CallToolRequest.md): Defines a request to call a specific tool with given arguments.
- [`CallToolResult`](./CallToolResult.md): Represents the result of a tool call.
- [`CompleteRequest`](./CompleteRequest.md): Defines a request for a model completion.
- [`CompleteResult`](./CompleteResult.md): Represents the result of a model completion request.
- [`CreateMessageRequest`](./CreateMessageRequest.md): Defines a request to create a new message in a conversation.
- [`CreateMessageResult`](./CreateMessageResult.md): Represents the result of a create message request.
- [`GetPromptRequest`](./GetPromptRequest.md): Defines a request to retrieve a specific prompt.
- [`GetPromptResult`](./GetPromptResult.md): Represents the result of a get prompt request, containing the prompt details.
- [`ListPromptsRequest`](./ListPromptsRequest.md): Defines a request to list available prompts.
- [`ListPromptsResult`](./ListPromptsResult.md): Represents the result of listing available prompts.
- [`ListToolsRequest`](./ListToolsRequest.md): Defines a request to list available tools.
- [`ListToolsResult`](./ListToolsResult.md): Represents the result of listing available tools.
- [`Prompt`](./Prompt.md): Represents a prompt template.
- [`PromptArgument`](./PromptArgument.md): Describes an argument for a prompt template.
- [`PromptMessage`](./PromptMessage.md): Represents a message within a prompt or conversation.
- [`PromptReference`](./PromptReference.md): Provides a reference to a specific prompt.
- [`SamplingMessage`](./SamplingMessage.md): Represents a message used with LLM sampling APIs.
- [`Tool`](./Tool.md): `Tool` is a structure that defines a tool that the client can call.
- [`ToolAnnotations`](./ToolAnnotations.md): `ToolAnnotations` is a structure that provides additional properties describing a `Tool` to clients.

---

## JSON-RPC Specific

- [`JSONRPCNotification`](./JSONRPCNotification.md): The `JSONRPCNotification` structure represents a notification which does not expect a response in the JSON-RPC protocol used by the MCP system.
- [`JSONRPCRequest`](./JSONRPCRequest.md): The `JSONRPCRequest` structure represents a request that expects a response in the JSON-RPC protocol used by the MCP system.
- [`JSONRPCResponse`](./JSONRPCResponse.md): The `JSONRPCResponse` structure represents a successful (non-error) response to a request in the JSON-RPC protocol used by the MCP system.
- [`JSONRPCBatchRequest`](./JSONRPCBatchRequest.md): The `JSONRPCBatchRequest` type represents a JSON-RPC batch request, as described in the [JSON-RPC 2.0 Specification](https://www.jsonrpc.org/specification#batch). It allows multiple requests and notifications to be sent in a single batch.
- [`JSONRPCBatchResponse`](./JSONRPCBatchResponse.md): The `JSONRPCBatchResponse` type represents a JSON-RPC batch response, as described in the [JSON-RPC 2.0 Specification](https://www.jsonrpc.org/specification#batch). It contains multiple responses to a batch request.
- [`JSONRPCError`](./JSONRPCError.md): The `JSONRPCError` structure represents a response to a request that indicates an error occurred in the JSON-RPC protocol used by the MCP system.
- [`JSONRPCMessage`](./JSONRPCMessage.md): The `JSONRPCMessage` enumeration represents any valid JSON-RPC object that can be decoded from or encoded to the wire in the MCP system.
- [`JSONRPCBatchRequest`](./JSONRPCBatchRequest.md): Defines a batch of JSON-RPC requests.
- [`JSONRPCBatchResponse`](./JSONRPCBatchResponse.md): Defines a batch of JSON-RPC responses.
- [`JSONRPCError`](./JSONRPCError.md): Defines the structure for errors in JSON-RPC communication.
- [`JSONRPCMessage`](./JSONRPCMessage.md): Defines the base structure for a JSON-RPC message.
- [`JSONRPCNotification`](./JSONRPCNotification.md): Defines a JSON-RPC notification.
- [`JSONRPCRequest`](./JSONRPCRequest.md): Defines a JSON-RPC request.
- [`JSONRPCResponse`](./JSONRPCResponse.md): Defines a JSON-RPC response.

---

## Core & Utility Structures

- [`Annotations`](./Annotations.md): `Annotations` is a structure that provides optional metadata for the client. The client can use these annotations to inform how objects are used or displayed.
- [`AnyCodable`](./AnyCodable.md): The `AnyCodable` structure provides a type-erased `Codable` value that can be used to encode and decode values of any type that conforms to the `Codable` protocol in the MCP system.
- [`Constants`](./Constants.md): Defines various constants used within the MCPKit schema.
- [`Cursor`](./Cursor.md): Defines a cursor used for pagination in requests and results.
- [`Implementation`](./Implementation.md): Provides details about the server's implementation of the MCP.
- [`MCPSchema`](./MCPSchema.md): Provides an overview or entry point for the MCPKit schema definitions.
- [`ModelHint`](./ModelHint.md): The `ModelHint` structure provides hints to use for model selection in the MCP system. Keys not declared in this structure are currently left unspecified by the specification and are up to the client to interpret.
- [`ModelPreferences`](./ModelPreferences.md): The `ModelPreferences` structure represents the server's preferences for model selection, requested of the client during sampling in the MCP system.
- [`ProgressToken`](./ProgressToken.md): Defines a token for associating progress notifications with requests.
- [`RequestId`](./RequestId.md): Defines a unique identifier for a request.
- [`Role`](./Role.md): Represents the role of a participant in a message or conversation.
