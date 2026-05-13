# SwapFoundationKit

A comprehensive Swift package providing essential utilities, extensions, UI components, and services for iOS development.

## Quick Navigation

| Section | Description |
|---------|-------------|
| [Requirements](#requirements) | Platform and tooling requirements |
| [Installation](#installation) | SPM setup instructions |
| [Quick Start](#quick-start) | Framework initialization |
| [Documentation](Docs/README.md) | Full documentation index |
| [Migration Guide](Docs/migration/migration-guide.md) | Migrate a host app to SFK |
| [Audit Catalog](Docs/migration/catalog.yaml) | 48 capabilities for auditing host apps |
| [Testing](#testing) | How to run tests |
| [Support](#support) | Issues, discussions, contact |

---

## Requirements

- **iOS**: 17.0+
- **Swift**: 5.9+
- **Xcode**: 15.0+
- **Dependencies (core)**: Toast-Swift (2.1.3)
- **Optional**: `SwapFoundationKitGoogleMobileAds` product + Google Mobile Ads **13.1.0**

---

## Installation

### Swift Package Manager

1. In Xcode: **File** → **Add Package Dependencies**
2. Enter: `https://github.com/SwapnanilDhol/SwapFoundationKit`
3. Select version and click **Add Package**

Or in `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/SwapnanilDhol/SwapFoundationKit", from: "1.0.0")
],
targets: [
    .target(
        name: "YourApp",
        dependencies: [
            .product(name: "SwapFoundationKit", package: "SwapFoundationKit"),
            // Optional — only if you show ads:
            .product(name: "SwapFoundationKitGoogleMobileAds", package: "SwapFoundationKit"),
        ]
    ),
]
```

Ads setup: see [Docs/guides/google-mobile-ads.md](Docs/guides/google-mobile-ads.md)
Settings UI guide: see [Docs/guides/settings.md](Docs/guides/settings.md)

---

## GitHub / CI Usage

The package graph uses remote GitHub URLs only — safe for CI and downstream consumers.

For local development: use Xcode's local package override flow, then revert to the GitHub URL before committing.

---

## Quick Start

Initialize the framework in your `App` struct:

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
            enableNetworking: true,
            networkTimeout: 30.0,
            networkLogLevel: .info
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

---

## Migrating a Host App

See [Docs/migration/migration-guide.md](Docs/migration/migration-guide.md) for the full migration guide.

**Quick audit workflow**:
1. Read [Docs/migration/catalog.yaml](Docs/migration/catalog.yaml) for 48 capabilities
2. Start with `audit_tier: exact` items for highest confidence
3. Replace redundant implementations with SFK equivalents
4. Run tests after each migration

---

## Key Capabilities

### Core Services
- **Haptics**: `HapticsHelper` — impact, notification, selection feedback
- **Logging**: `Logger` — configurable with analytics integration
- **Analytics**: `AnalyticsManager` — protocol-based fan-out to providers
- **Networking**: `HTTPClient` (modern async/await) or `NetworkService` (reachability)
- **Security**: `SecurityService` — encryption, keychain, hashing
- **Backup**: `BackupService` — data export and restore

### UI Components
- **Buttons**: `SFKButton`, `SFKButtonConfigurator` with presets
- **Settings**: Full settings module — `SFKSettingsScreen`, 14+ row types
- **Onboarding**: `SFKChipFlowLayout`, `SFKSelectableChip`, `SFKSegmentedProgress`
- **Pickers**: `SFKItemPickerView` for single/multi-select
- **Glass wrappers**: `.glassCompat()`, `.glassProminentCompat()`, `.glassEffectCompat()`

### Data Sync
- **ItemSync**: Sync data between app, widgets, and extensions
- **WatchSync**: Type-safe Watch connectivity transport

### Extensions
- **Date**: Formatting, components, manipulation
- **String**: Validation, manipulation, hashing
- **UIColor**: Hex colors, manipulation
- **Collection**: Safe subscript, chunking

Full API reference: see [Docs/README.md](Docs/README.md)

---

## Testing

```bash
cd /path/to/SwapFoundationKit
xcodebuild test -scheme SwapFoundationKit -destination 'platform=iOS Simulator,name=iPhone 16'
```

---

## Architecture

- **Protocol-Oriented**: Easy to implement, test, and extend
- **Modern Swift**: async/await, actors, Swift concurrency
- **Modular**: Core, Services, UI, Extensions, Utilities
- **Comprehensive**: Well-tested with mock support

---

## Support

- **Issues**: [GitHub Issues](https://github.com/SwapnanilDhol/SwapFoundationKit/issues)
- **Discussions**: [GitHub Discussions](https://github.com/SwapnanilDhol/SwapFoundationKit/discussions)

---

**Made with ❤️ by [Swapnanil Dhol](https://github.com/SwapnanilDhol)**
