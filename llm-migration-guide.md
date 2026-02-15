## Guide: Migrating an iOS Project to SwapFoundationKit (SFK)

This guide is written for LLMs to perform a safe, repeatable migration of an iOS app to use SwapFoundationKit (SFK). It provides precise search-and-edit rules, code templates, and validation steps. Follow in order; only deviate if you encounter conflicts.

Note: Prefer modern patterns (async/await, @MainActor where needed, dependency injection for services, minimal globals).

### What SFK provides (commonly used in migrations)

- Haptics: `HapticsHelper` with consistent impact/notification APIs
- Analytics protocol surface: `AnalyticsEvent` (you define your app’s enum); simple fan-out to providers
- App utilities: e.g., `AppLinkOpener`
- Data sync helpers (use an app wrapper like `AppSync` shown below)

---

## 1) Add SFK to the project

- Add `SwapFoundationKit` via Swift Package Manager.
- Link to the app target.
- Verify `import SwapFoundationKit` compiles.

---

## 2) Centralize Widget reloads into AppSync

Goal: Remove all scattered `WidgetCenter.shared.reloadAllTimelines()` calls. Only one place should reload widgets after data writes.

Create/update `AppSync.swift` to encapsulate data sync and widget reloads:

```swift
import Foundation
import SwapFoundationKit
import WidgetKit

enum AppSync {
    static let appGroupIdentifier = "group.YOUR.APP.GROUP"
    static let service: DataSyncService = {
        #if os(iOS)
        return ItemSyncServiceFactory.createWithWatch(appGroupIdentifier: appGroupIdentifier)
        #else
        return ItemSyncServiceFactory.create(appGroupIdentifier: appGroupIdentifier)
        #endif
    }()

    @MainActor
    static func initialSync() async {
        do {
            let items = try await /* Load your app’s data model list */
            try await service.save(items)
            WidgetCenter.shared.reloadAllTimelines()
        } catch {
            print("❌ Initial ItemSync failed: \(error)")
        }
    }

    @MainActor
    static func save(_ items: [/* Your item type */]) async throws {
        try await service.save(items)
        WidgetCenter.shared.reloadAllTimelines()
    }
}
```

Transformations (apply across the codebase):

- Replace calls that manually reload widgets:
  - Find: `WidgetCenter.shared.reloadAllTimelines(` → remove
- Replace direct calls to `AppSync.service.save(...)` with `try await AppSync.save(...)`
- For external changes (e.g., purchases/restores/imports) that used to call widget reloads directly, call:
  - `Task { await AppSync.initialSync() }`

Imports cleanup:

- Remove `import WidgetKit` everywhere in the app target except `AppSync.swift`
- Keep WidgetKit imports inside widget extension targets

Validation:

- Grep confirms no strays:
  - `WidgetCenter.shared.reloadAllTimelines(` appears only in `AppSync.swift`
  - `import WidgetKit` appears only in `AppSync.swift` and widget targets

---

## 3) Migrate Haptics to SFK

Use SFK’s `HapticsHelper` everywhere.

Pattern:

- If a file triggers haptics more than once, create a class-scoped instance:

```swift
private let hapticsHelper = HapticsHelper()
```

- Otherwise, instantiate inline for a one-off:

```swift
HapticsHelper().mediumImpact()
```

Replace older/custom calls with SFK equivalents:

- medium tap: `HapticsHelper.shared.mediumButtonTap()` → `hapticsHelper.mediumImpact()`
- hard tap: `HapticsHelper.shared.hardButtonTap()` → `hapticsHelper.heavyImpact()`
- success: `HapticsHelper().success()` → `hapticsHelper.successNotification()`
- error: `HapticsHelper.shared.error()` / `HapticsHelper().error()` → `hapticsHelper.errorNotification()`
- warning: ensure `hapticsHelper.warningNotification()` where needed
- light touch: `HapticsHelper().lightImpact()` → `hapticsHelper.lightImpact()`

Cleanup:

- Remove app-local copies of haptics helpers
- If there were static/singleton accessors, change usage to local instance as above

Validation:

- No occurrences of `HapticsHelper.shared`
- No `HapticsHelper().success()` (should be `successNotification()`)
- Files with multiple calls have `private let hapticsHelper = HapticsHelper()`

---

## 4) Standardize Analytics using SFK’s AnalyticsEvent

Step A — Define your app’s analytics events (conform to `AnalyticsEvent`):

```swift
import SwapFoundationKit

public enum AppEvent: AnalyticsEvent {
    case screenOpened(name: String)
    case purchaseCompleted(reason: String)
    case purchaseFailed(reason: String)
    case errorLogged(error: String)

    public var rawValue: String {
        switch self {
        case .screenOpened: return "screen_opened"
        case .purchaseCompleted: return "purchase_completed"
        case .purchaseFailed: return "purchase_failed"
        case .errorLogged: return "error_logged"
        }
    }

    public var parameters: [String: String]? {
        switch self {
        case .screenOpened(let name): return ["name": name]
        case .purchaseCompleted(let reason): return ["reason": reason]
        case .purchaseFailed(let reason): return ["reason": reason]
        case .errorLogged(let error): return ["error": error]
        }
    }
}
```

Step B — Implement an analytics manager that fans out to providers (Telemetry/Mixpanel/Firebase):

```swift
#if os(iOS)
import Mixpanel
#if canImport(Firebase)
import Firebase
#endif
#if canImport(FirebaseAnalytics)
import FirebaseAnalytics
#endif
import TelemetryClient
import SwapFoundationKit

final class TelemetryLogger {
    func logEvent(event: AnalyticsEvent) {
        TelemetryManager.shared.send(event.rawValue, with: event.parameters ?? [:])
    }
}

final class FirebaseLogger {
    func logEvent(event: AnalyticsEvent) {
        #if canImport(FirebaseAnalytics)
        Analytics.logEvent(event.rawValue, parameters: event.parameters)
        #endif
    }
}

final class MixpanelLogger {
    func logEvent(event: AnalyticsEvent) {
        Mixpanel.mainInstance().track(event: event.rawValue, properties: event.parameters)
    }
}

final class AppAnalyticsManager {
    static let shared = AppAnalyticsManager()
    private let telemetryLogger = TelemetryLogger()
    private let firebaseLogger = FirebaseLogger()
    private let mixpanelLogger = MixpanelLogger()
    private init() {}

    public func setupAnalytics() {
        let telemetryAppID = /* load from Info.plist or config */ ""
        let configuration = TelemetryManagerConfiguration(appID: telemetryAppID)
        TelemetryManager.initialize(with: configuration)
        Mixpanel.initialize(token: "YOUR_MIXPANEL_TOKEN", trackAutomaticEvents: true)
        // Firebase: configure in AppDelegate if present
    }

    public func logEvent(event: AppEvent) {
        telemetryLogger.logEvent(event: event)
        firebaseLogger.logEvent(event: event)
        mixpanelLogger.logEvent(event: event)
    }
}
#endif
```

Step C — Migrate call sites to use dot shorthand:

- From: `AppAnalyticsManager.shared.logEvent(event: AppEvent.purchaseFailed(reason: foo))`
- To: `AppAnalyticsManager.shared.logEvent(event: .purchaseFailed(reason: foo))`

Imports cleanup:

- Only analytics infrastructure should import `TelemetryClient`; remove elsewhere if unused

Validation:

- Grep: no `logEvent(event: AppEvent.`

---

## 5) Notifications service (recommended)

Encapsulate notifications behind a service that logs analytics and uses haptics for feedback:

```swift
@MainActor
final class NotificationService: NotificationServiceProtocol {
    private let scheduler: NotificationSchedulerProtocol
    private let permissionManager: NotificationPermissionManagerProtocol
    private let analyticsManager: AppAnalyticsManager
    private let hapticsHelper = HapticsHelper()

    init(
        scheduler: NotificationSchedulerProtocol = UNNotificationScheduler(),
        permissionManager: NotificationPermissionManagerProtocol = UNNotificationPermissionManager(),
        analyticsManager: AppAnalyticsManager = .shared
    ) {
        self.scheduler = scheduler
        self.permissionManager = permissionManager
        self.analyticsManager = analyticsManager
    }

    func requestPermission() async -> Bool {
        let granted = await permissionManager.requestAuthorization(options: [.alert, .sound, .badge])
        analyticsManager.logEvent(event: .screenOpened(name: granted ? "notification_permission_granted" : "notification_permission_denied"))
        return granted
    }
}
```

---

## 6) Remove redundant local utilities

Delete local files superseded by SFK (only after verifying zero references):

- Local `HapticsHelper.swift`
- Legacy helpers: `NetworkManager.swift`, `UserDefaultsWrapper.swift`, `View+Conditional.swift`, `UIImage+*`, etc.
- Unused config files like `TelemetryKey.swift`
- Unused debug UI like `DebugView.swift`

Validation:

- Grep before removal; proceed only if no references remain

---

## 7) Systematic search-and-replace plan

- Widgets:

  - Remove all `WidgetCenter.shared.reloadAllTimelines(` calls
  - Replace `AppSync.service.save(...)` with `try await AppSync.save(...)`
  - Use `Task { await AppSync.initialSync() }` after external changes
  - Keep `import WidgetKit` only in `AppSync.swift` and widget targets

- Haptics:

  - `.mediumButtonTap()` → `.mediumImpact()`
  - `.hardButtonTap()` → `.heavyImpact()`
  - `.success()` → `.successNotification()`
  - `.error()` → `.errorNotification()`
  - Add `private let hapticsHelper = HapticsHelper()` where used often

- Analytics:

  - `logEvent(event: AppEvent.` → `logEvent(event: .`
  - Keep `TelemetryClient` imports in analytics stack only

- File deletion:
  - Remove redundant local helpers once unused

---

## 8) Post-migration validation checklist

- Build succeeds; no missing imports/symbols
- Grep checks:
  - No `WidgetCenter.shared.reloadAllTimelines(` outside `AppSync.swift`
  - No `HapticsHelper.shared`
  - No `HapticsHelper().success()` (should be `successNotification()`)
  - No stray `import TelemetryClient` outside analytics stack
- Functional smoke tests:
  - Haptics fire at tap points without crashes
  - Analytics events log as expected
  - Data changes trigger widget refresh via `AppSync`

---

## 9) Commit and push

Group commits meaningfully:

- `chore(sfk): add SwapFoundationKit + AppSync centralization`
- `refactor(haptics): migrate to SFK HapticsHelper; add local instances`
- `refactor(analytics): migrate callsites to dot shorthand; define AppEvent`
- `cleanup: remove unused imports and redundant local helpers`

Ensure CI/build is green before merging.

---

## 10) New Helper Functions Available in SFK

SFK now provides many helper utilities that can replace common local implementations:

### FileManager Extensions
```swift
import SwapFoundationKit

// Convenience directories
let docsDir = FileManager.default.documentsDirectory
let cachesDir = FileManager.default.cachesDirectory
let tempDir = FileManager.default.temporaryDirectory

// File operations
let size = FileManager.default.fileSize(at: path)
let formattedSize = FileManager.default.fileSizeFormatted(at: path)
let dirSize = FileManager.default.directorySize(at: url)
try FileManager.default.createDirectoryIfNeeded(at: url)
FileManager.default.removeItemSafely(at: url)
```

### JSON Codable Helpers
```swift
import SwapFoundationKit

// Encode/Decode
let data = try JSONCodable.encode(myObject, prettyPrinted: true)
let object = try JSONCodable.decode(MyType.self, from: data)

// String encoding
let jsonString = try JSONCodable.encodeToString(myObject)

// Load from file
let config = try JSONCodable.jsonFromFile("config", in: .main)
```

### URL Extensions
```swift
import SwapFoundationKit

// Query parameters
let params = myURL.queryParameters  // [String: String]?
let newURL = myURL.appendingQueryItem(name: "key", value: "value")
let cleanURL = myURL.removingQueryParameters()

// Validation
let isValid = URL.isValid("https://example.com")
```

### Device Information
```swift
import SwapFoundationKit

let model = DeviceInfo.deviceModel       // "iPhone 14 Pro"
let identifier = DeviceInfo.deviceModelIdentifier  // "iPhone15,2"
let isSimulator = DeviceInfo.isSimulator
let hasNotch = DeviceInfo.hasNotch
let version = DeviceInfo.appVersion       // "1.0.0"
let build = DeviceInfo.appBuildNumber     // "123"
let isIPad = DeviceInfo.isIPad
let screenSize = DeviceInfo.screenSize
```

### Throttler (complements existing Debouncer)
```swift
import SwapFoundationKit

let throttler = Throttler(interval: 1.0)  // Execute once per second
throttler.throttle {
    // This runs immediately on first call,
    // subsequent calls within 1 second are ignored
}

// Async version
let asyncThrottler = AsyncThrottler(interval: 1.0)
```

### Result Extensions
```swift
import SwapFoundationKit

let result: Result<String, Error> = .success("value")
let isSuccess = result.isSuccess
let isFailure = result.isFailure
let value = result.getOrElse("default")
let optional = result.getOrNil
```

### Collection Extensions (chunked)
```swift
import SwapFoundationKit

let chunks = [1,2,3,4,5,6].chunked(into: 2)  // [[1,2], [3,4], [5,6]]
```

### CGTypes Extensions
```swift
import SwapFoundationKit

let distance = point1.distance(to: point2)
let aspectRatio = size.aspectRatio
let fitted = size.fitted(into: boundingSize)
let center = rect.center
```

### Additional String Extensions
```swift
import SwapFoundationKit

// Regex
let matches = "hello".matches(regex: "l+")
let allMatches = "hello".matches(of: "l")

// Validation
let isURL = "https://example.com".isValidURL
let isPhone = "+1234567890".isValidPhoneNumber
let isCard = "4111111111111111".isValidCreditCard

// Encoding
let encoded = "hello".base64Encoded
let decoded = "aGVsbG8=".base64Decoded
let md5 = "hello".md5

// Misc
let stripped = "<p>hello</p>".htmlStripped
let distance = "hello".levenshteinDistance(to: "world")
let truncated = "long string".truncated(to: 10)  // "long str..."
```

### Additional Date Extensions
```swift
import SwapFoundationKit

let startOfMonth = date.startOfMonth
let endOfMonth = date.endOfMonth
let startOfYear = date.startOfYear
let isWeekend = date.isWeekend
let daysInMonth = date.daysInMonth
let workingDays = date.workingDays(until: otherDate)
let quarter = date.quarter
let isCurrentYear = date.isInCurrentYear

// Create date
let newDate = Date.from(year: 2025, month: 1, day: 15)
```

---

## 11) Known Refactoring Opportunities in SFK (for contributors)

When working on SFK itself, be aware of these refactoring opportunities:

### Critical Issues

1. **Duplicate NetworkError Definitions**
   - Files: `NetworkService.swift` (lines 8-32) and `Networking.swift` (lines 95-125)
   - Two different `NetworkError` enums with similar but not identical cases
   - Recommendation: Consolidate into a single `NetworkError` enum

### Code Duplication

2. **DateFormatter Creation** (`Date+Extensions.swift`)
   - `DateFormatter()` instantiated 17+ times
   - Should use cached formatters or a shared formatter pool

3. **Calendar.current Access** (`Date+Extensions.swift`)
   - Accessed 18+ times throughout the file
   - Should cache as a static property

4. **UIColor Component Extraction** (`UIColor+.swift`)
   - Pattern of getting RGBA components repeated 10+ times
   - Should extract a helper method

5. **Duplicate Type Conversion Logic** (`Bundle+InfoPlist.swift`)
   - Type conversion switch statement duplicated in two methods

### Large Files That Could Be Split

6. **UIColor+.swift** (393 lines)
   - Could split into: `UIColor+Hex.swift`, `UIColor+Components.swift`, `UIColor+Blending.swift`, `UIColor+Analysis.swift`

7. **Date+Extensions.swift** (321 lines)
   - Could split into: `DateFormatting.swift`, `DateComponents.swift`, `DateManipulation.swift`

8. **String+.swift** (315 lines)
   - Multiple extension blocks that could be reorganized

9. **ConfigurationService.swift** (407 lines)
   - Could extract convenience methods to a separate protocol

### Naming Inconsistencies

10. **String Validation Methods**
    - `isNumeric` vs `isValidDecimal`
    - `isValidEmail` vs `isEmail`
    - `removingWhitespaces` vs `withoutWhitespace`
    - `toInt` vs `intValue`
    - Recommendation: Standardize naming conventions

11. **HTTPClient vs NetworkService**
    - Two networking abstractions with overlapping functionality
    - Should clarify or consolidate

### Magic Strings

12. **Hardcoded URLs**
    - `ExchangeRateManager.swift` line 24: ECB exchange rate URL
    - `AppMetaData.swift`: Multiple hardcoded App Store URLs

---

## End-state examples

- View model with multiple haptics:

```swift
@MainActor
final class SomeViewModel: ObservableObject {
    private let hapticsHelper = HapticsHelper()

    func didTap() {
        hapticsHelper.mediumImpact()
    }
}
```

- Save pathway with centralized widget refresh:

```swift
do {
    let items = try await MyCoreDataManager.appInstance.allMappedItems()
    try await AppSync.save(items)
} catch {
    AppAnalyticsManager.shared.logEvent(event: .errorLogged(error: error.localizedDescription))
}
```

- Analytics shorthand:

```swift
AppAnalyticsManager.shared.logEvent(event: .purchaseCompleted(reason: "User Accept"))
```

- App startup:

```swift
AppAnalyticsManager.shared.setupAnalytics()
Task { await AppSync.initialSync() }
```

If you follow the above steps precisely, an LLM can safely migrate most codebases to use SwapFoundationKit with minimal developer intervention.
