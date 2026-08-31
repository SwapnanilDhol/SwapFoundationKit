# SwapFoundationKit

A comprehensive Swift package providing essential utilities, extensions, UI components, and services for iOS development.

## Requirements

- **iOS**: 17.0+
- **Swift**: 5.9+
- **Dependencies (default product)**: none
- **Optional products**: `SwapFoundationKitPulse` + [Pulse](https://github.com/kean/Pulse) 5.2.3, `SwapFoundationKitToast` + [Toast-Swift](https://github.com/BastiaanJansen/Toast-Swift) 2.1.3, and `SwapFoundationKitGoogleMobileAds` + Google Mobile Ads 13.6.0

`SFKFirebaseLogger` is a temporary guarded compatibility adapter; Firebase will
move to a planned explicit `SwapFoundationKitFirebase` product before v4.

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
                appName: "MyApp"
            )
        )
        try? SwapFoundationKit.shared.configure(with: config)
        Task {
            try? await SwapFoundationKit.shared.start()
            await ExchangeRateManager.shared.start()
        }
    }

    var body: some Scene {
        WindowGroup { ContentView() }
    }
}
```

### Optional Pulse integration

Add the `SwapFoundationKitPulse` product only when the app needs Pulse. Configure it before
constructing `HTTPClient` instances or touching `SwapFoundationKit.shared`, so those instances
use the Pulse instrumentation seam:

```swift
import SwapFoundationKit
import SwapFoundationKitPulse

@main
struct MyApp: App {
    init() {
        SFKPulseService.configure(
            SFKPulseConfiguration(networkCaptureMode: .sfkHTTPClientOnly)
        )
        _ = HTTPClient()
        try? SwapFoundationKit.shared.configure(
            with: SwapFoundationKitConfiguration(
                appMetadata: AppMetaData(
                    appGroupIdentifier: "group.com.yourapp.widget",
                    appName: "MyApp"
                )
            )
        )
    }

    var body: some Scene {
        WindowGroup { ContentView() }
    }
}
```

To inspect logs, present `SFKPulseConsoleView()` from a host-owned debug entry point.

## Component Catalog

`SwapFoundationKitHost` is an installable iPhone and iPad catalog for browsing SFK's visual components and foundation APIs. It uses the local package directly, so component changes appear in the catalog on the next build.

Open [`SwapFoundationKitHost.xcodeproj`](SwapFoundationKitHost/SwapFoundationKitHost.xcodeproj) in Xcode, select the `SwapFoundationKitHost` scheme and your device, then Run. See the [catalog guide](SwapFoundationKitHost/README.md) for maintenance and installation details.

## Module Index

| Module | Description |
|--------|-------------|
| [Core](Sources/SwapFoundationKit/Core/README.md) | Networking, security, App Attest authenticated sessions, backup, configuration |
| [Services](Sources/SwapFoundationKit/Services/README.md) | Haptics, logging, analytics, defaults, deeplinks, files, location, pro gating, notifications (Pulse and Toast are opt-in products) |
| [UI](Sources/SwapFoundationKit/UI/README.md) | Buttons, text fields, settings, onboarding, pickers, glass, aura, barcode, alerts, appearance |
| [Extensions](Sources/SwapFoundationKit/Extensions/README.md) | Date, String, Number, Collection, Bundle, URL, FileManager, Result, Data, JSON, async collections |
| [Utilities](Sources/SwapFoundationKit/Utilities/README.md) | Persistent TTL storage, debounce/throttle, environment detection, launch arguments |
| [Currency](Sources/SwapFoundationKit/Currency/README.md) | 58 currencies with flags/symbols, formatting, sorting, exchange rates |
| [ImageProcessor](Sources/SwapFoundationKit/ImageProcessor/README.md) | Image resize, filters, caching, JPEG compression |
| [ItemSync](Sources/SwapFoundationKit/ItemSync/README.md) | App Group data sync for widgets and extensions |
| [WatchSync](Sources/SwapFoundationKit/WatchSync/README.md) | Type-safe Watch Connectivity transport |
| [Protocols](Sources/SwapFoundationKit/Protocols/README.md) | Coordinator, ValueDefaultProvider, AppMetaData |
| [Compatibility](Sources/SwapFoundationKit/Compatibility/README.md) | iOS 26+ forward-compatible wrappers |
| [Ads](Sources/SwapFoundationKit/Ads/README.md) | Google Mobile Ads integration (optional module) |
| [Pulse](Sources/SwapFoundationKitPulse/README.md) | Pulse network logging and debug console (optional product) |
| [Toast](Sources/SwapFoundationKitToast/README.md) | Toast presentation (optional product) |

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
- **Modular**: clearly bounded core modules plus explicit opt-in products
- **SFK prefix**: Public UI types use `SFK` prefix; protocols and services do not

## Support

- **Issues**: [GitHub Issues](https://github.com/SwapnanilDhol/SwapFoundationKit/issues)
- **Discussions**: [GitHub Discussions](https://github.com/SwapnanilDhol/SwapFoundationKit/discussions)

---

**Made with ❤️ by [Swapnanil Dhol](https://github.com/SwapnanilDhol)**
