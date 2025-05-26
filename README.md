# MCPKit

MCPKit is a Swift-native developer toolkit that lets Apple developers build, run, and debug AI agents using the Model-Context Protocol with zero config and beautiful local-first DX.

## Overview

The Model Context Protocol (MCP) is a standardized way to structure and exchange context for language models, enabling clean separation between agent logic, resources, and communication layers.

**MCPKit** is a Swift-native framework and CLI that makes it easy to:

- Build MCP-compliant servers entirely in Swift
- Define agents, resources, and tools using protocol-oriented design
- Route and handle standard MCP messages with minimal setup
- Stream responses using industry-standard transports:
  - `stdio` for agent subprocesses
  - Server-Sent Events (SSE) for real-time response streaming
  - Streamable HTTP (chunked transfer) for async or partial replies
- Scaffold and debug MCP projects with a powerful CLI
- Validate and test messages in a structured, schema-safe way

Built with native Apple devs in mind, MCPKit prioritizes:
- Beautiful developer experience
- Strong typing and schema safety
- Security
- Seamless local development and test tooling
- Full compliance with the MCP v1 specification

Whether you're building on macOS or preparing for iOS/Shortcuts integration, **MCPKit** gives you everything you need to create, test, and run your own MCP-compliant servers with zero external dependencies.

## Development

Currently, we are in Phase 1 of the development:

Build a Swift-native MCP client and server framework with core JSON-RPC message handling, transport support (stdio, SSE, streamable HTTP), and a CLI to scaffold, run, and test MCP-compliant servers locally.

Here is the project checklist for Phase 1:

- Implement official MCP schema into Swift
- `MCPClient` to create MCP-enabled apps using Swift and SwiftUI
- `MCPServer` to create MCP servers using Swift
- CLI tool to scaffold, run, and test MCP servers

