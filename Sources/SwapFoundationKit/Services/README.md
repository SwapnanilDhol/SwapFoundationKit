# Services

Application-level services for haptics, logging, analytics, user defaults, deeplinks, toasts, file I/O, pasteboard, location, app links, notifications, and Pro gating.

## Public API

| Type | Kind | Description |
|------|------|-------------|
| `HapticsHelper` | class | Impact (light/medium/heavy/custom) and notification haptics |
| `Logger` | enum | Colored console logging with emoji prefixes, analytics fan-out on errors |
| `LogLevel` | enum | debug, info, warning, error |
| `AnalyticsManager` | class | Protocol-based fan-out to multiple `AnalyticsLogger` providers |
| `AnalyticsLogger` | protocol | Implement to forward events to Firebase, TelemetryDeck, PostHog, etc. |
| `AnalyticsEvent` | protocol | Event type with `rawValue` and optional `parameters` |
| `DefaultAnalyticsEvent` | struct | Concrete event for ad-hoc tracking |
| `UserDefault` | property wrapper | Type-safe, observable UserDefaults with SwiftUI binding support |
| `UserDefaultKeyProtocol` | protocol | Enum-based key definition for UserDefaults |
| `ToastManager` | class | Type-safe toast presentation via `SFKToastKind` |
| `SFKToastKind` | protocol | App-specific toast type definition |
| `SFKToastConfiguration` | struct | Toast display timing configuration |
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
| `ItemDetailSource` | protocol | Shareable item with link metadata support |
| `DefaultItemDetailSource` | struct | Concrete implementation of `ItemDetailSource` |
| `SFKProGate` | enum | Closure-based IAP feature gating with automatic upsell |
| `SFKNotificationService` | class | Generic `UNUserNotificationCenter` wrapper |
| `SFKFirebaseLogger` | class | Pre-built `AnalyticsLogger` for Firebase |
| `SFKTelemetryLogger` | class | Pre-built `AnalyticsLogger` for TelemetryDeck |
| `SFKPostHogLogger` | class | Pre-built `AnalyticsLogger` for PostHog with feature flags |

## Quick Examples

```swift
// Haptics
let helper = HapticsHelper()
helper.mediumImpact()
helper.successNotification()

// Logger
Logger.info("User signed in", context: "Auth")
Logger.error("Network timeout", context: "API")

// Analytics
AnalyticsManager.shared.addLogger(SFKFirebaseLogger())
AnalyticsManager.shared.logEvent(event: myEvent)

// UserDefaults
enum AppKeys: String, UserDefaultKeyProtocol {
    case hasOnboarded
    var keyString: String { rawValue }
}
@UserDefault(AppKeys.hasOnboarded, default: false) var hasOnboarded

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

## Source Files

### Analytics
- `AnalyticsProtocol.swift` — AnalyticsManager, AnalyticsLogger, AnalyticsEvent
- `Analytics/SFKFirebaseLogger.swift` — Firebase adapter
- `Analytics/SFKTelemetryLogger.swift` — TelemetryDeck adapter
- `Analytics/SFKPostHogLogger.swift` — PostHog adapter

### Deeplinks
- `DeeplinkHandler/DeeplinkHandler.swift` — DefaultDeeplinkHandler
- `DeeplinkHandler/DeeplinkRoute.swift` — Route protocol
- `DeeplinkHandler/DeeplinkEvent.swift` — Event struct

### Other
- `HapticsHelper.swift` — Haptic feedback
- `Logger.swift` — Colored logging
- `ToastManager.swift` — Toast notifications
- `UserDefault.swift` + `UserDefaults+.swift` — Type-safe defaults
- `PasteboardService.swift` — Clipboard access
- `LocationSearchService.swift` — MapKit search
- `DeviceInfo.swift` — Hardware info
- `AppLinkOpener.swift` — URL opening
- `AppStoreSearch/AppStoreSearchResult.swift` — iTunes search
- `FileExportService.swift` + `FileImportService.swift` — File I/O
- `ItemDetailSource.swift` + `DefaultItemDetailSource.swift` — Sharing
- `SFKProGate.swift` — Feature gating
- `SFKNotificationService.swift` — Local notifications
