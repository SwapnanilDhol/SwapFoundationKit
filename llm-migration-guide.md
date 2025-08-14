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
