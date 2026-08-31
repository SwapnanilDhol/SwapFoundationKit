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
        .library(
            name: "SwapFoundationKitFeedback",
            targets: ["SwapFoundationKitFeedback"]
        ),
        .library(
            name: "SwapFoundationKitPulse",
            targets: ["SwapFoundationKitPulse"]
        ),
        .library(
            name: "SwapFoundationKitToast",
            targets: ["SwapFoundationKitToast"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/googleads/swift-package-manager-google-mobile-ads.git",
            exact: "13.6.0"
        ),
        .package(
            url: "https://github.com/BastiaanJansen/Toast-Swift.git",
            exact: "2.1.3"
        ),
        .package(
            url: "https://github.com/kean/Pulse.git",
            exact: "5.2.3"
        ),
    ],
    targets: [
        .target(
            name: "SwapFoundationKit",
            dependencies: []
        ),
        .target(
            name: "SwapFoundationKitGoogleMobileAds",
            dependencies: [
                "SwapFoundationKit",
                .product(name: "GoogleMobileAds", package: "swift-package-manager-google-mobile-ads"),
            ]
        ),
        .target(
            name: "SwapFoundationKitFeedback",
            dependencies: ["SwapFoundationKit"],
            exclude: ["README.md"]
        ),
        .target(
            name: "SwapFoundationKitPulse",
            dependencies: [
                "SwapFoundationKit",
                .product(name: "Pulse", package: "Pulse", condition: .when(platforms: [.iOS, .tvOS, .watchOS, .visionOS])),
                .product(name: "PulseUI", package: "Pulse", condition: .when(platforms: [.iOS, .tvOS, .watchOS, .visionOS])),
                .product(name: "PulseProxy", package: "Pulse", condition: .when(platforms: [.iOS, .tvOS, .watchOS, .visionOS])),
            ]
        ),
        .target(
            name: "SwapFoundationKitToast",
            dependencies: [
                "SwapFoundationKit",
                .product(name: "Toast", package: "Toast-Swift"),
            ]
        ),
        .testTarget(
            name: "SwapFoundationKitTests",
            dependencies: [
                "SwapFoundationKit",
            ]
        ),
        .testTarget(
            name: "SwapFoundationKitGoogleMobileAdsTests",
            dependencies: [
                "SwapFoundationKit",
                "SwapFoundationKitGoogleMobileAds",
            ]
        ),
        .testTarget(
            name: "SwapFoundationKitFeedbackTests",
            dependencies: ["SwapFoundationKitFeedback"]
        ),
        .testTarget(
            name: "SwapFoundationKitPulseTests",
            dependencies: [
                "SwapFoundationKit",
                "SwapFoundationKitPulse",
                .product(name: "Pulse", package: "Pulse", condition: .when(platforms: [.iOS, .tvOS, .watchOS, .visionOS])),
            ]
        ),
        .testTarget(
            name: "SwapFoundationKitToastTests",
            dependencies: [
                "SwapFoundationKit",
                "SwapFoundationKitToast",
            ]
        ),
    ]
)
