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
    ],
    targets: [
        .target(
            name: "SwapFoundationKit",
            dependencies: [
                .product(name: "Toast", package: "Toast-Swift"),
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
            dependencies: ["SwapFoundationKit"]
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
