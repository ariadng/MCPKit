// swift-tools-version:6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MCP",
    platforms: [
        .macOS(.v13) // Specify macOS platform version
    ],
    products: [
        // Library product for the MCPKit framework
        .library(
            name: "MCP",
            targets: ["MCPLibrary"]),
        // Executable product for the CLI tool
        .executable(
            name: "mcpkit",
            targets: ["CLI"])
    ],
    dependencies: [
        // Dependency for command-line argument parsing
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.2.0")
    ],
    targets: [
        // --- Core Library Targets ---
        .target(
            name: "MCPUtils",
            path: "Sources/Utils"
        ),
        .target(
            name: "MCPSchema",
            dependencies: ["MCPUtils"], 
            path: "Sources/Schema"
        ),
        .target(
            name: "MCPTransport",
            dependencies: ["MCPUtils"],
            path: "Sources/Transport"
        ),
        .target(
            name: "MCPClient",
            dependencies: [
                "MCPSchema",
                "MCPTransport",
                "MCPUtils"
            ],
            path: "Sources/MCPClient"
        ),
        .target(
            name: "MCPServer",
            dependencies: [
                "MCPSchema", 
                "MCPTransport",
                "MCPUtils"
            ],
            path: "Sources/Server"
        ),
        // Main library target that aggregates other library components
        .target(
            name: "MCPLibrary",
            dependencies: [
                "MCPClient",   
                "MCPSchema",   
                "MCPTransport",
                "MCPServer",
                "MCPUtils"
            ],
            path: "Sources/MCPKit" 
        ),

        // --- CLI Target ---
        .executableTarget(
            name: "CLI",
            dependencies: [
                "MCPLibrary",
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ],
            path: "Sources/CLI"
        ),

        // --- Test Target ---
        .testTarget(
            name: "MCPTests",
            dependencies: ["MCPLibrary"]
        ),
    ]
)
