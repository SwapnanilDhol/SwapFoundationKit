// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwapFoundationKit",
    platforms: [
        .iOS(.v17),
    ],
    products: [
        .library(
            name: "SwapFoundationKit",
            targets: ["SwapFoundationKit"]
        ),
        .library(
            name: "SwapFoundationKitGoogleMobileAds",
            targets: ["SwapFoundationKitGoogleMobileAds"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/googleads/swift-package-manager-google-mobile-ads.git",
            exact: "13.1.0"
        ),
        .package(
            url: "https://github.com/BastiaanJansen/Toast-Swift.git",
            exact: "2.1.3"
        ),
        .package(
            url: "https://github.com/kean/Pulse.git",
            exact: "5.1.2"
        ),
        .package(
            url: "https://github.com/TelemetryDeck/SwiftClient.git",
            exact: "2.14.1"
        ),
    ],
    targets: [
        .target(
            name: "SwapFoundationKit",
            dependencies: [
                .product(name: "Toast", package: "Toast-Swift"),
                .product(name: "Pulse", package: "Pulse", condition: .when(platforms: [.iOS, .tvOS, .watchOS, .visionOS])),
                .product(name: "PulseUI", package: "Pulse", condition: .when(platforms: [.iOS, .tvOS, .watchOS, .visionOS])),
                .product(name: "PulseProxy", package: "Pulse", condition: .when(platforms: [.iOS, .tvOS, .watchOS, .visionOS])),
                .product(name: "TelemetryClient", package: "SwiftClient", condition: .when(platforms: [.iOS, .tvOS, .watchOS, .visionOS])),
                .product(name: "TelemetryDeck", package: "SwiftClient", condition: .when(platforms: [.iOS, .tvOS, .watchOS, .visionOS])),
            ]
        ),
        .target(
            name: "SwapFoundationKitGoogleMobileAds",
            dependencies: [
                "SwapFoundationKit",
                .product(name: "GoogleMobileAds", package: "swift-package-manager-google-mobile-ads"),
            ]
        ),
        .testTarget(
            name: "SwapFoundationKitTests",
            dependencies: [
                "SwapFoundationKit",
                .product(name: "Pulse", package: "Pulse", condition: .when(platforms: [.iOS, .tvOS, .watchOS, .visionOS])),
            ]
        ),
        .testTarget(
            name: "SwapFoundationKitGoogleMobileAdsTests",
            dependencies: [
                "SwapFoundationKit",
                "SwapFoundationKitGoogleMobileAds",
            ]
        ),
    ]
)
