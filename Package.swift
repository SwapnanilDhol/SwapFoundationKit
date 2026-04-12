// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwapFoundationKit",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "SwapFoundationKit",
            targets: ["SwapFoundationKit"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/googleads/swift-package-manager-google-mobile-ads.git",
            exact: "13.1.0"
        ),
        .package(
            url: "https://github.com/scalableswift/Toast.git",
            exact: "3.1.2"
        )
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "SwapFoundationKit",
            dependencies: [
                .product(name: "GoogleMobileAds", package: "swift-package-manager-google-mobile-ads"),
                .product(name: "Toast", package: "Toast")
            ]
        ),
        .testTarget(
            name: "SwapFoundationKitTests",
            dependencies: ["SwapFoundationKit"]
        ),
    ]
)
