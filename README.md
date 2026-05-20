# SwapFoundationKit

A comprehensive Swift package providing essential utilities, extensions, UI components, and services for iOS development.

## Requirements

- **iOS**: 17.0+
- **Swift**: 5.9+
- **Dependencies (core)**: [Toast-Swift](https://github.com/BastiaanJansen/Toast-Swift) 2.1.3
- **Optional**: `SwapFoundationKitGoogleMobileAds` + Google Mobile Ads 13.1.0

## Installation

```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/SwapnanilDhol/SwapFoundationKit", from: "1.0.0")
],
targets: [
    .target(name: "YourApp", dependencies: [
        .product(name: "SwapFoundationKit", package: "SwapFoundationKit"),
    ]),
]
```

## Quick Start

```swift
import SwapFoundationKit

@main
struct MyApp: App {
    init() {
        let config = SwapFoundationKitConfiguration(
            appMetadata: AppMetaData(
                appGroupIdentifier: "group.com.yourapp.widget",
                appName: "MyApp",
                appVersion: "1.0.0"
            ),
            enableWatchConnectivity: true,
            enableAnalytics: true,
            enableItemSync: true,
            enableNetworking: true
        )
        Task {
            try? await SwapFoundationKit.shared.start(with: config)
            await ExchangeRateManager.shared.start()
        }
    }

    var body: some Scene {
        WindowGroup { ContentView() }
    }
}
```

## Module Index

| Module | Description |
|--------|-------------|
| [Core](Sources/SwapFoundationKit/Core/README.md) | Networking, security, backup, configuration |
| [Services](Sources/SwapFoundationKit/Services/README.md) | Haptics, logging, analytics, defaults, deeplinks, toasts, files, location, pro gating, notifications |
| [UI](Sources/SwapFoundationKit/UI/README.md) | Buttons, settings, onboarding, pickers, glass, aura, barcode, alerts, appearance |
| [Extensions](Sources/SwapFoundationKit/Extensions/README.md) | Date, String, Number, Collection, Bundle, URL, FileManager, Result, Data, JSON, async collections |
| [Utilities](Sources/SwapFoundationKit/Utilities/README.md) | Debouncer, Throttler, environment detection, launch arguments |
| [Currency](Sources/SwapFoundationKit/Currency/README.md) | 35 currencies with flags/symbols, formatting, sorting, exchange rates |
| [ImageProcessor](Sources/SwapFoundationKit/ImageProcessor/README.md) | Image resize, filters, caching, JPEG compression |
| [ItemSync](Sources/SwapFoundationKit/ItemSync/README.md) | App Group data sync for widgets and extensions |
| [WatchSync](Sources/SwapFoundationKit/WatchSync/README.md) | Type-safe Watch Connectivity transport |
| [Protocols](Sources/SwapFoundationKit/Protocols/README.md) | Coordinator, ValueDefaultProvider, AppMetaData |
| [Compatibility](Sources/SwapFoundationKit/Compatibility/README.md) | iOS 26+ forward-compatible wrappers |
| [Ads](Sources/SwapFoundationKit/Ads/README.md) | Google Mobile Ads integration (optional module) |

## Documentation

| Resource | Description |
|----------|-------------|
| [Docs/README.md](Docs/README.md) | Documentation index |
| [Docs/capabilities.yaml](Docs/capabilities.yaml) | Agent-first feature discovery catalog |
| [Docs/migration/catalog.yaml](Docs/migration/catalog.yaml) | Audit catalog for host-app overlap detection |
| [Docs/migration/migration-guide.md](Docs/migration/migration-guide.md) | Step-by-step migration guide |
| [Docs/guides/](Docs/guides/) | In-depth guides (networking, ads, onboarding, settings) |

## Agent Workflow

For LLM agents working with this package:

| File | Purpose |
|------|---------|
| [AGENTS.md](AGENTS.md) | Package-traveling workflow document |
| [SKILL.md](SKILL.md) | Environment-specific trigger + quick lookup |
| [Docs/capabilities.yaml](Docs/capabilities.yaml) | Check SFK before building host-app features |
| [Docs/development/feature-discovery.md](Docs/development/feature-discovery.md) | Feature discovery workflow |

## Architecture

- **Protocol-Oriented**: Easy to implement, test, and extend
- **Modern Swift**: async/await, actors, Swift concurrency
- **Modular**: 12 subdirectories with clear boundaries
- **SFK prefix**: Public UI types use `SFK` prefix; protocols and services do not

## Support

- **Issues**: [GitHub Issues](https://github.com/SwapnanilDhol/SwapFoundationKit/issues)
- **Discussions**: [GitHub Discussions](https://github.com/SwapnanilDhol/SwapFoundationKit/discussions)

---

**Made with ❤️ by [Swapnanil Dhol](https://github.com/SwapnanilDhol)**
