# Services

Application-level services for haptics, logging, analytics, user defaults, deeplinks, file I/O, pasteboard, location, app links, notifications, and Pro gating.

Pulse-backed log/network inspection and toast presentation are opt-in products —
`SwapFoundationKitPulse` and `SwapFoundationKitToast` — and are no longer part of this default
target. See [SFKPulseService and ToastManager have moved](#sfkpulseservice-and-toastmanager-have-moved)
below.

## Public API

| Type | Kind | Description |
|------|------|-------------|
| `HapticsHelper` | class | Impact (light/medium/heavy/custom) and notification haptics |
| `Logger` | enum | Colored console logging with emoji prefixes, log-sink and analytics fan-out on errors |
| `LogLevel` | enum | debug, info, warning, error |
| `SFKLogSink` | protocol | Destination that receives every `Logger.log` message |
| `SFKLogSinkRegistry` | enum | Registers `SFKLogSink` destinations; `SwapFoundationKitPulse` registers into it |
| `AnalyticsManager` | class | Protocol-based fan-out to multiple `AnalyticsLogger` providers |
| `AnalyticsLogger` | protocol | Implement to forward events to the host app's analytics provider. |
| `AnalyticsEvent` | protocol | Event type with `rawValue` and optional `parameters` |
| `DefaultAnalyticsEvent` | struct | Concrete event for ad-hoc tracking |
| `UserDefault` | property wrapper | Type-safe, observable UserDefaults with SwiftUI binding support |
| `SharedUserDefaults` | property wrapper | Type-safe app-group defaults resolved from configured app metadata |
| `UserDefaultKeyProtocol` | protocol | Enum-based key definition for UserDefaults |
| `DeeplinkHandler` | protocol | URL and user activity handling with Combine publisher |
| `DeeplinkRoute` | protocol | Parsable route types for deeplink routing |
| `DeeplinkEvent` | struct | Emitted event with route, URL, and source |
| `PasteboardService` | class | Wraps `UIPasteboard.general` with typed payloads |
| `LocationSearchService` | class | MapKit location autocomplete and reverse geocoding |
| `DeviceInfo` | enum | Device model, OS version, screen size, idiom checks |
| `AppLinkOpener` | enum | URL opening with App Store, Maps, reviews support |
| `AppStoreSearchService` | class | iTunes Search API with debounce and task cancellation |
| `FileExportService` | class | Share sheet presenter for data and Encodable objects |
| `FileImportService` | class | Document picker for importing files with delegate |
| `ItemDetailSource` | protocol | Shareable item metadata (title/text/image/url) |
| `DefaultItemDetailSource` | struct | Concrete implementation of `ItemDetailSource` |
| `ActivityItemDetailSource` | class | `UIActivityItemSource` bridge — use `makeActivityItem()` |
| `SFKProGate` | enum | Closure-based IAP feature gating with automatic upsell |
| `SFKNotificationService` | class | Generic `UNUserNotificationCenter` wrapper |
| `SFKFirebaseLogger` | class | Temporary guarded `AnalyticsLogger` adapter for Firebase; planned move to opt-in `SwapFoundationKitFirebase` |

## Quick Examples

```swift
// Haptics
let helper = HapticsHelper()
helper.mediumImpact()
helper.successNotification()

// Logger
Logger.info("User signed in", context: "Auth")
Logger.error("Network timeout", context: "API")

// Log sink (opt-in products like SwapFoundationKitPulse register into this)
struct MySink: SFKLogSink {
    func record(level: LogLevel, message: String, context: String?, function: String, file: String, line: Int) {
        // forward elsewhere
    }
}
SFKLogSinkRegistry.register(MySink())

// Analytics
AnalyticsManager.shared.addLogger(SFKFirebaseLogger())
AnalyticsManager.shared.logEvent(event: myEvent)

// UserDefaults
enum AppKeys: String, UserDefaultKeyProtocol {
    case hasOnboarded
    var keyString: String { rawValue }
}
@UserDefault(AppKeys.hasOnboarded, default: false) var hasOnboarded

@SharedUserDefaults(AppKeys.hasOnboarded, default: false)
var sharedHasOnboarded

// App bootstrap: make metadata-backed stores available synchronously.
let config = SwapFoundationKitConfiguration.basic(
    appMetadata: AppMetaData(appGroupIdentifier: "group.com.example.app")
)
try SwapFoundationKit.shared.configure(with: config)
Task { try await SwapFoundationKit.shared.start() }
sharedHasOnboarded = true

// Deeplink
enum AppRoute: DeeplinkRoute {
    case home, settings
    static func parse(from url: URL) -> Self? { ... }
}
// Configure in SwapFoundationKitConfiguration.supportedRoutes

// Pro Gating
SFKProGate.isProEnabled = { ProManager.shared.isPro }
SFKProGate.presentProSheet = { reason in ... }
SFKProGate.require("exportCSV") { export() }

// Notifications
await SFKNotificationService.shared.requestAuthorization()
await SFKNotificationService.shared.post(title: "Reminder", body: "...")
```

## SFKPulseService and ToastManager have moved

`SFKPulseService`, `SFKPulseConfiguration`, `SFKPulseConsoleView`, and their supporting enums now
ship in the opt-in `SwapFoundationKitPulse` product. `ToastManager`, `SFKToastKind`, and
`SFKToastStyle`/`SFKToastConfiguration` now ship in the opt-in `SwapFoundationKitToast` product. Add the product
you need and change `import SwapFoundationKit` to `import SwapFoundationKitPulse` /
`import SwapFoundationKitToast` at call sites — the APIs themselves are unchanged. See
[Docs/migration/v4-phase-1-product-extraction.md](../../../Docs/migration/v4-phase-1-product-extraction.md).

This target still owns the seams those products plug into: `SFKLogSink`/`SFKLogSinkRegistry`
here, and `SFKURLSessionPerforming`/`SFKNetworkInstrumentation` in `Core/`.

Host-app Pulse integration guidance lives in [Docs/guides/pulse-integration.md](../../../Docs/guides/pulse-integration.md).

`SFKFirebaseLogger` remains source-compatible in the default target only as a
temporary `#if canImport(FirebaseAnalytics)` adapter. It is not a permanent
default-target vendor integration: move Firebase usage to the planned explicit
`SwapFoundationKitFirebase` product when that product is introduced.

## Source Files

### Analytics
- `AnalyticsProtocol.swift` — AnalyticsManager, AnalyticsLogger, AnalyticsEvent
- `Analytics/SFKFirebaseLogger.swift` — Firebase adapter

### Deeplinks
- `DeeplinkHandler/DeeplinkHandler.swift` — DefaultDeeplinkHandler
- `DeeplinkHandler/DeeplinkRoute.swift` — Route protocol
- `DeeplinkHandler/DeeplinkEvent.swift` — Event struct

### Other
- `HapticsHelper.swift` — Haptic feedback
- `Logger.swift` — Colored logging
- `SFKLogSink.swift` — Log sink protocol and registry (`SwapFoundationKitPulse` registers into this)
- `UserDefault.swift` + `UserDefaults+.swift` — Type-safe defaults
- `PasteboardService.swift` — Clipboard access
- `LocationSearchService.swift` — MapKit search
- `DeviceInfo.swift` — Hardware info
- `AppLinkOpener.swift` — URL opening
- `AppStoreSearch/AppStoreSearchResult.swift` — iTunes search
- `FileExportService.swift` + `FileImportService.swift` — File I/O
- `ItemDetailSource.swift` + `DefaultItemDetailSource.swift` + `ActivityItemDetailSource` — Sharing (`makeActivityItem()`)
- `SFKProGate.swift` — Feature gating
- `SFKNotificationService.swift` — Local notifications
