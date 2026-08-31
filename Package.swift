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
        .library(
            name: "SwapFoundationKitNetworking",
            targets: ["SwapFoundationKitNetworking"]
        ),
        .library(
            name: "SwapFoundationKitAuthentication",
            targets: ["SwapFoundationKitAuthentication"]
        ),
        .library(
            name: "SwapFoundationKitSync",
            targets: ["SwapFoundationKitSync"]
        ),
        .library(
            name: "SwapFoundationKitMedia",
            targets: ["SwapFoundationKitMedia"]
        ),
        .library(
            name: "SwapFoundationKitCurrency",
            targets: ["SwapFoundationKitCurrency"]
        ),
        .library(
            name: "SwapFoundationKitRemoteAI",
            targets: ["SwapFoundationKitRemoteAI"]
        ),
        .library(
            name: "SwapFoundationKitFirebase",
            targets: ["SwapFoundationKitFirebase"]
        ),
        .library(
            name: "SwapFoundationKitLegacy",
            targets: ["SwapFoundationKitLegacy"]
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
            dependencies: ["SwapFoundationKit", "SwapFoundationKitMedia"],
            exclude: ["README.md"]
        ),
        .target(
            name: "SwapFoundationKitPulse",
            dependencies: [
                "SwapFoundationKit",
                "SwapFoundationKitNetworking",
                .product(name: "Pulse", package: "Pulse", condition: .when(platforms: [.iOS, .tvOS, .watchOS, .visionOS])),
                .product(name: "PulseUI", package: "Pulse", condition: .when(platforms: [.iOS, .tvOS, .watchOS, .visionOS])),
                .product(name: "PulseProxy", package: "Pulse", condition: .when(platforms: [.iOS, .tvOS, .watchOS, .visionOS])),
            ],
            exclude: ["README.md"]
        ),
        .target(
            name: "SwapFoundationKitToast",
            dependencies: [
                "SwapFoundationKit",
                .product(name: "Toast", package: "Toast-Swift"),
            ],
            exclude: ["README.md"]
        ),
        .target(
            name: "SwapFoundationKitNetworking",
            dependencies: ["SwapFoundationKit"],
            path: "Sources/SwapFoundationKitNetworking",
            exclude: ["README.md"]
        ),
        .target(
            name: "SwapFoundationKitAuthentication",
            dependencies: ["SwapFoundationKit", "SwapFoundationKitNetworking"],
            path: "Sources/SwapFoundationKitAuthentication",
            exclude: ["README.md"]
        ),
        .target(
            name: "SwapFoundationKitSync",
            dependencies: ["SwapFoundationKit"],
            path: "Sources/SwapFoundationKitSync",
            exclude: ["README.md", "ItemSync/README.md", "WatchSync/README.md"]
        ),
        .target(
            name: "SwapFoundationKitMedia",
            dependencies: ["SwapFoundationKit", "SwapFoundationKitNetworking"],
            path: "Sources/SwapFoundationKitMedia",
            exclude: ["README.md", "ImageProcessor/README.md"]
        ),
        .target(
            name: "SwapFoundationKitCurrency",
            dependencies: ["SwapFoundationKit", "SwapFoundationKitNetworking"],
            path: "Sources/SwapFoundationKitCurrency",
            exclude: ["README.md", "Currency/README.md"]
        ),
        .target(
            name: "SwapFoundationKitRemoteAI",
            dependencies: ["SwapFoundationKit", "SwapFoundationKitNetworking"],
            path: "Sources/SwapFoundationKitRemoteAI",
            exclude: ["README.md"]
        ),
        .target(
            name: "SwapFoundationKitFirebase",
            dependencies: ["SwapFoundationKit"],
            path: "Sources/SwapFoundationKitFirebase",
            exclude: ["README.md"]
        ),
        .target(
            name: "SwapFoundationKitLegacy",
            dependencies: ["SwapFoundationKit", "SwapFoundationKitNetworking", "SwapFoundationKitSync"],
            path: "Sources/SwapFoundationKitLegacy",
            exclude: ["README.md"]
        ),
        .testTarget(
            name: "SwapFoundationKitTests",
            dependencies: [
                "SwapFoundationKit",
                "SwapFoundationKitNetworking",
                "SwapFoundationKitAuthentication",
                "SwapFoundationKitSync",
                "SwapFoundationKitMedia",
                "SwapFoundationKitCurrency",
                "SwapFoundationKitRemoteAI",
                "SwapFoundationKitFirebase",
                "SwapFoundationKitLegacy",
                "SwapFoundationKitGoogleMobileAds",
            ]
        ),
        .testTarget(
            name: "SwapFoundationKitGoogleMobileAdsTests",
            dependencies: [
                "SwapFoundationKit",
                "SwapFoundationKitGoogleMobileAds",
                "SwapFoundationKitLegacy",
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
                "SwapFoundationKitNetworking",
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
