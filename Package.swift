// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwapFoundationKit",
    version: "1.0.0",
    platforms: [
        .iOS(.v16),
        .macOS(.v13),
        .watchOS(.v8)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "SwapFoundationKit",
            targets: ["SwapFoundationKit"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "SwapFoundationKit",
            exclude: [
                "ItemSync/README.md",
                "Currency/README.md",
                "Extensions/README.md", 
                "Services/README.md",
                "ImageProcessor/README.md",
                "Analytics/README.md",
                "Core/README.md"
            ]
        ),
        .testTarget(
            name: "SwapFoundationKitTests",
            dependencies: ["SwapFoundationKit"]
        ),
    ]
)
