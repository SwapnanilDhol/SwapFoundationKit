# SwapFoundationKit

Composable SwiftUI components, semantic design tokens, and opt-in services for iOS development.

This checkout contains the breaking v4 API cleanup. See the [implementation status](Docs/development/v4-implementation-status.md) and [migration guide](Docs/migration/v4-simplification-migration-guide.md) before upgrading; these changes are not a released v4 tag.

## Requirements

- **iOS**: 17.0+
- **Swift**: 5.9+
- **Dependencies (default product)**: none
- **Optional products**: `SwapFoundationKitPulse` + [Pulse](https://github.com/kean/Pulse) 5.2.3, `SwapFoundationKitToast` + [Toast-Swift](https://github.com/BastiaanJansen/Toast-Swift) 2.1.3, and `SwapFoundationKitGoogleMobileAds` + Google Mobile Ads 13.6.0

Networking, Authentication, Sync, Media, Currency, RemoteAI, and Firebase
have explicit opt-in products. The Firebase
adapter requires host-owned forwarding handlers; the Firebase SDK is not a dependency
of the default product.

## Installation

```swift
// Package.swift
dependencies: [
    // Use this local checkout while v4 is unreleased; adjust the path as needed.
    .package(path: "../SwapFoundationKit")
],
targets: [
    .target(name: "YourApp", dependencies: [
        .product(name: "SwapFoundationKit", package: "SwapFoundationKit"),
    ]),
]
```

## Quick Start

```swift
import SwiftUI
import SwapFoundationKit

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .sfkTheme(.system.accent(.indigo))
        }
    }
}
```

UI needs no SFK startup, App Group, network client, or authentication configuration.
Customize colors, semantic typography, spacing, radii, motion, and feedback through
`SFKTheme`; individual controls can override only what they need. Construct optional
services at your app's composition root when their feature is used.

### Optional Pulse integration

Add the `SwapFoundationKitPulse` product only when the app needs Pulse. Configure it before
constructing `HTTPClient` instances, so those instances
use the Pulse instrumentation seam:

```swift
import SwapFoundationKit
import SwapFoundationKitPulse
import SwapFoundationKitNetworking

@main
struct MyApp: App {
    init() {
        SFKPulseService.configure(
            SFKPulseConfiguration(networkCaptureMode: .sfkHTTPClientOnly)
        )
        _ = HTTPClient()
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
| [Core and infrastructure](Sources/SwapFoundationKit/Core/README.md) | Security/backup in the default product; Networking and Authentication require their own imports |
| [Networking](Sources/SwapFoundationKitNetworking/README.md) | HTTP client, reachability, request contracts, instrumentation |
| [Authentication](Sources/SwapFoundationKitAuthentication/README.md) | App Attest, authenticated sessions, secure transport |
| [Sync](Sources/SwapFoundationKitSync/README.md) | Explicit App Group storage and watch synchronization |
| [Media](Sources/SwapFoundationKitMedia/README.md) | Image processing and remote image transport |
| [Remote AI](Sources/SwapFoundationKitRemoteAI/README.md) | Host-configured AI requests over Networking |
| [Firebase](Sources/SwapFoundationKitFirebase/README.md) | Host-handler-injected analytics adapter |
| [Services](Sources/SwapFoundationKit/Services/README.md) | Haptics, logging, analytics, defaults, deeplinks, files, location, pro gating, notifications (Pulse and Toast are opt-in products) |
| [UI](Sources/SwapFoundationKit/UI/README.md) | Buttons, text fields, settings, onboarding, pickers, glass, aura, barcode, alerts, appearance |
| [Extensions](Sources/SwapFoundationKit/Extensions/README.md) | Date, String, Number, Collection, Bundle, URL, FileManager, Result, Data, JSON, async collections |
| [Utilities](Sources/SwapFoundationKit/Utilities/README.md) | Persistent TTL storage, debounce/throttle, environment detection, launch arguments |
| [Currency](Sources/SwapFoundationKitCurrency/Currency/README.md) | 58 currencies with flags/symbols, formatting, sorting, exchange rates |
| [ImageProcessor](Sources/SwapFoundationKitMedia/ImageProcessor/README.md) | Image resize, filters, caching, JPEG compression |
| [ItemSync](Sources/SwapFoundationKitSync/ItemSync/README.md) | App Group data sync for widgets and extensions |
| [WatchSync](Sources/SwapFoundationKitSync/WatchSync/README.md) | Type-safe Watch Connectivity transport |
| [Protocols](Sources/SwapFoundationKit/Protocols/README.md) | Coordinator, ValueDefaultProvider, AppMetaData |
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
