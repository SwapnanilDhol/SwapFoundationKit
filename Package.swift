// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwapFoundationKit",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "SwapFoundationKit",
            targets: ["SwapFoundationKit"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/BastiaanJansen/Toast-Swift.git",
            exact: "2.1.3"
        )
    ],
    targets: [
        .target(
            name: "SwapFoundationKit",
            dependencies: [
                .product(name: "Toast", package: "Toast-Swift")
            ]
        ),
        .testTarget(
            name: "SwapFoundationKitTests",
            dependencies: ["SwapFoundationKit"]
        ),
    ],
    version: "3.0.0"
)
