// swift-tools-version:6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MCPKit",
    platforms: [
        .macOS(.v13) // Specify macOS platform version
    ],
    products: [
        // Library product for the MCPKit framework
        .library(
            name: "MCPKit",
            targets: ["MCPKitLibrary"]),
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
            name: "MCPKitUtils",
            path: "Sources/Utils"
        ),
        .target(
            name: "MCPKitCore",
            dependencies: ["MCPKitUtils"],
            path: "Sources/Core"
        ),
        .target(
            name: "MCPKitTransport",
            dependencies: ["MCPKitCore", "MCPKitUtils"],
            path: "Sources/Transport"
        ),
        .target(
            name: "MCPKitServer",
            dependencies: ["MCPKitCore", "MCPKitTransport", "MCPKitUtils"],
            path: "Sources/Server"
        ),
        // Main library target that aggregates other library components
        .target(
            name: "MCPKitLibrary",
            dependencies: [
                "MCPKitCore",
                "MCPKitTransport",
                "MCPKitServer",
                "MCPKitUtils"
            ],
            path: "Sources/MCPKit" // Using the directory created by 'swift package init'
        ),

        // --- CLI Target ---
        .executableTarget(
            name: "CLI",
            dependencies: [
                "MCPKitLibrary",
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ],
            path: "Sources/CLI"
        ),

        // --- Test Target ---
        .testTarget(
            name: "MCPKitTests",
            dependencies: ["MCPKitLibrary"]
        ),
    ]
)
