## Guide: Migrating an iOS Project to SwapFoundationKit (SFK)

This guide is written for LLMs to perform a safe, repeatable migration of an iOS app to use SwapFoundationKit (SFK). It provides precise search-and-edit rules, code templates, and validation steps. Follow in order; only deviate if you encounter conflicts.

Note: Prefer modern patterns (async/await, @MainActor where needed, dependency injection for services, minimal globals).

Start with `Docs/migration/catalog.yaml` before using this guide for an app audit. The
catalog is curated against the package's public API, flags audit confidence, and helps avoid
suggesting replacements for helpers that are internal or too generic to audit reliably.

### What SFK provides (commonly used in migrations)

- Haptics: `HapticsHelper` with consistent impact/notification APIs
- Analytics protocol surface: `AnalyticsEvent` (you define your app’s enum); simple fan-out to providers
- App utilities: e.g., `AppLinkOpener`
- Data sync helpers (use an app wrapper like `AppSync` shown below)
- SwiftUI Buttons: `SFKButton(..., style: .primary/.secondary/.toolbar)` for actions and `SFKCloseButton(...)` for standardized dismiss controls
- Custom glass surfaces: `.sfkGlass(material: .regular/.clear, tint:isInteractive:shape:)`

## 4a) Consistent Close/Dismiss UI Pattern

Prefer `SFKCloseButton` for all close/dismiss actions in modal sheets, onboarding flows, and any dismissible views.

- Use the default `.toolbar` chrome inside navigation toolbars (Liquid Glass already wraps the control).
- Use `SFKCloseButton(chrome: .glass)` for freeform chrome over content — full-bleed previews, camera overlays, custom top bars — where an icon-only control is hard to see.

## 4b) Item Picker (`SFKItemPickerView`)

A generic picker view for selecting or managing items from a list, with support for single-select, multi-select, sections, searchable browsing, context-menu actions, and swipe actions.

### Protocols

**`SFKPickableItem`** — protocol for items displayed and selected in the picker:
```swift
public protocol SFKPickableItem: Identifiable, Hashable {
    var pickableItemId: String { get }
    var pickableItemIconKind: SFKPickableItemIconKind { get }
    var pickableItemTitle: String { get }
    var pickableItemSubtitle: String? { get }
    var pickableItemBadgeTitle: String? { get }
    var pickableItemIconTintColor: UIColor? { get }
}
```

`pickableItemBadgeTitle` and `pickableItemIconTintColor` have default implementations, so existing conformers do not need to change.

**`SFKPickableItemIconKind`** — enum for icon display modes:
```swift
public enum SFKPickableItemIconKind {
    case iconImage(uiImage: UIImage)
    case systemIcon(symbolName: String)
    case text(text: String)
    case none
}
```

**`SFKItemPickerSelectionMode`** — selection mode:
```swift
public enum SFKItemPickerSelectionMode: Sendable {
    case single
    case multi
}
```

**`SFKItemPickerSection`** — optional list grouping:
```swift
public struct SFKItemPickerSection: Identifiable {
    public let id: String
    public let title: String?
    public let footer: String?
    public let items: [any SFKPickableItem]
}
```

### Usage

```swift
import SwapFoundationKit

// Present as a sheet
.sheet {
    let viewModel = SFKItemPickerViewModel(
        items: Currency.allCases,
        selectionType: .single,
        initialSelection: [selectedCurrency]
    )

    SFKItemPickerView(
        pageTitle: "Select Currency",
        viewModel: viewModel,
        onSelect: { item in
            if let currency = item as? Currency {
                selectedCurrency = currency
            }
        },
        onDismiss: {
            presentationMode.wrappedValue.dismiss()
        }
    )
}

// Multi-select example
.sheet {
    let viewModel = SFKItemPickerViewModel(
        items: Currency.allCases,
        selectionType: .multi,
        initialSelection: selectedCurrencies
    )

    SFKItemPickerView(
        pageTitle: "Select Currencies",
        viewModel: viewModel,
        onSelect: { item in
            if let currency = item as? Currency {
                toggleSelection(currency)
            }
        },
        onDismiss: {
            presentationMode.wrappedValue.dismiss()
        }
    )
}

// Browsing/management list example
SFKItemPickerView(
    pageTitle: "Accounts",
    viewModel: accountPickerViewModel,
    selectsItems: false,
    toolbarActions: [
        SFKItemPickerToolbarAction(systemImage: "plus.circle.fill") {
            addAccount()
        }
    ],
    onSelect: { item in edit(item) },
    actionsProvider: { item in
        [
            SFKItemPickerItemAction(
                title: "Delete",
                systemImage: "trash",
                role: .destructive,
                presentation: .swipe
            ) {
                delete(item)
            }
        ]
    }
)

// Sectioned picker example
let viewModel = SFKItemPickerViewModel(
    sections: [
        SFKItemPickerSection(title: "System Categories", items: systemCategories),
        SFKItemPickerSection(title: "User-Defined Categories", items: userCategories)
    ],
    selectionType: .single,
    initialSelection: [selectedCategory]
)
```

### Making a Type Conform to `SFKPickableItem`

Conformance should be in a dedicated extension:

```swift
extension Currency: SFKPickableItem {
    public var pickableItemId: String { rawValue }

    public var pickableItemIconKind: SFKPickableItemIconKind {
        .systemIcon(symbolName: currencySymbol)
    }

    public var pickableItemTitle: String { rawValue }

    public var pickableItemSubtitle: String? {
        "\(description)" // Use string interpolation to get human-readable name
    }
}
```

### Components

- **`SFKItemPickerView`** — main picker/list view with NavigationStack, close button, search, selection, and optional row actions
- **`SFKItemPickerSection`** — optional section wrapper with header/footer strings and pickable items
- **`SFKItemPickerRow`** — individual row with icon, title, subtitle, optional badge, and checkmark; includes haptic feedback on selection
- **`SFKItemPickerToolbarAction`** — navigation bar action rendered inside the picker toolbar
- **`SFKItemPickerItemAction`** — row action rendered as a context-menu item or trailing swipe action

### Rules

- Always put `SFKPickableItem` conformance in its own `extension` (not in the type declaration)
- Use `"\(description)"` for `LocalizedStringResource` or `LocalizedStringKey` to get the human-readable string
- `Currency` already conforms to `SFKPickableItem` via extension at the bottom of `Currency.swift`

```swift
import SwapFoundationKit

struct MyModalView: View {
    let onClose: () -> Void

    var body: some View {
        VStack {
            // Place in top-left or top-right corner
            HStack {
                SFKCloseButton(action: onClose)
                Spacer()
            }
            .padding()

            // modal content
        }
        .presentationDetents([.medium, .large])
    }
}
```

For onboarding flows specifically:

```swift
struct OnboardingScreen: View {
    @ObservedObject var state: OnboardingState
    let onDismiss: () -> Void

    var body: some View {
        ZStack {
            // content

            VStack {
                HStack {
                    SFKCloseButton(action: onDismiss)
                    Spacer()
                }
                .padding()

                Spacer()
            }
        }
    }
}
```

**Rules:**
- Prefer `SFKCloseButton` instead of repeating custom close button styling
- If the close affordance needs a different visible label, use `SFKCloseButton("Dismiss", action: ...)`
- Never create custom close buttons using text + icon combinations
- For UIKit modal presentations, use `SwapProManager` or the appropriate dismiss method
- The close-button variants include haptic feedback and the same built-in button styling automatically
- Alert presentation: `AlertPresenter` is the single main-actor API for alerts, confirmations, action sheets, and text input
- Settings UI: `SettingsItem` protocol, `SFKSettingsRow`, `SFKSettingsScreen` for building reusable settings screens; `SFKInformationSectionItem` and `SFKDeveloperSectionItem` for standard section items
- Toast notifications: `ToastManager` wrapping the Toast library, with `ToastType` protocol for app-specific types, `ToastStyle` for styling, and `ToastConfiguration` for display options
- File Export/Import: `FileExportService` for presenting `UIActivityViewController` with data, `FileImportService` for `UIDocumentPickerViewController` with custom `UTType` registration
- Deeplink handling: `DeeplinkHandler` protocol with `DefaultDeeplinkHandler` implementation, `DeeplinkRoute` protocol for type-safe routes, `DeeplinkEvent` for Combine-based callbacks handling cold launch, resume, universal links, and Handoff
- On-device JSON backups: `BackupService` — `performBackup` writes under `Documents/<FileType>/`; `restoreBackup` reads the **newest** backup (same order as `listBackupFiles(for:).first`). Use the same `Decodable` type (and `JSONDecoder` date strategy) as the `Encodable` payload you store. For tests, `BackupService(documentsDirectoryOverride: tempURL)` keeps files out of the real Documents folder.
- Update available banner: moved out of `SwapFoundationKit`. Use `UpdateAvailableKit` directly.

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
        return ItemSyncServiceFactory.createWithWatch(
            appGroupIdentifier: appGroupIdentifier,
            options: WatchSyncOptions(
                preferredTransport: .applicationContext,
                fallbackOrder: [.userInfo, .messageData, .file]
            )
        )
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

Watch sync contract notes:

- SFK now uses `WatchSyncEnvelope` (`identifier`, `payload`, `version`, `timestamp`) as the canonical watch wire format.
- Prefer `WatchSyncService` / `ItemSyncServiceFactory.createWithWatch(..., options:)` over direct `WCSession` usage in app/watch targets.
- If migrating older apps, allow one release cycle for legacy payload compatibility before removing app-local watch decoding code.

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

## 3a) Migrate SwiftUI buttons to `SFKButton`

Use `SFKButton(...)` for straightforward cases. Use `SFKCloseButton(...)` for the shared close or dismiss treatment, and wrap `SFKButton(...)` in an app-local helper when another init-based style repeats across screens.

Preferred mappings:

- Full-width primary CTA -> `SFKButton("...", color: ..., action: ...)`
- Primary CTA with icon or subtitle -> `SFKButton("...", leadingIconName: ..., subtitle: ..., action: ...)`
- Inline loading CTA -> `SFKButton("...", isLoading: true, color: ..., action: ...)`
- Reusable dismiss / close action -> `SFKCloseButton(action: ...)`
- App-specific custom variants -> wrap `SFKButton(...)` in an app-local helper when the same init-based styling repeats

Examples:

```swift
import SwapFoundationKit

SFKButton(
    "Add Transaction",
    leadingIconName: "wand.and.stars",
    subtitle: "Recommended",
    color: .blue
) {
    // action
}

SFKCloseButton {
    dismiss()
}

SFKCloseButton("Dismiss") {
    dismiss()
}
```

Migration rules:

- Prefer `SFKButton(...)` for simple one-off buttons and `SFKCloseButton(...)` for standardized dismiss actions
- Use `SFKCloseButton` as the default close-button starting point
- When another button style repeats, create an app-local wrapper around `SFKButton(...)` instead of copying the same init arguments everywhere
- Use `controlSize: .small` for compact inline actions and chips, then tune `verticalPadding` only when the label needs additional breathing room
- `SFKSelectableChip` also accepts `controlSize: .small` for dense wrapping chip groups
- Loading buttons disable taps, replace their label with a spinner, and temporarily stop being full-width

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

### BackupService (on-device JSON backups)

Use `BackupService` when the host app keeps timestamped JSON snapshots on disk (not CloudKit-specific).

```swift
import SwapFoundationKit

let backups = BackupService()

struct AppSnapshot: Codable, Sendable {
    var version: Int
    var items: [String]
}

try await backups.performBackup(AppSnapshot(version: 1, items: ["a"]), fileType: .data)

// Loads the newest file under Documents/data/ (or documentsDirectoryOverride in tests)
let latest = try backups.restoreBackup(AppSnapshot.self, fileType: .data)
```

Rules for LLM migrations:

- Do not assume `restoreBackup` reads a fixed filename; it always resolves the **newest** file under `Documents/<FileType.rawValue>/` (matching `listBackupFiles`).
- If the app wrapped payloads (e.g. encoded `Data` then backed up), decode the same type you passed to `performBackup` first, then decode inner models with a matching `JSONDecoder`.
- Prefer `BackupService(documentsDirectoryOverride:)` in **tests** so backup files do not collide with dev data in Documents.

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

### ImageProcessor with Shared Storage
```swift
import SwapFoundationKit

let imageProcessor = ImageProcessor.shared

// In-memory caching (NSCache)
imageProcessor.cacheImage(image, forKey: "profile")
if let cached = imageProcessor.cachedImage(forKey: "profile") {
    // Use cached image
}

// Remote URL caching
let profileURL = URL(string: "https://example.com/profile.jpg")!
let processed = try await imageProcessor.cacheImage(
    from: profileURL,
    targetSize: CGSize(width: 150, height: 150)
)

if let cachedRemote = imageProcessor.cachedImage(
    from: profileURL,
    targetSize: CGSize(width: 150, height: 150)
) {
    // Use cached remote image
}

// Configure shared app group storage for widget/extension access
imageProcessor.configure(
    shouldCacheToSharedStorage: true,
    appGroupIdentifier: "group.com.yourapp.widget"
)

// Cache to shared storage (accessible by app extensions)
try imageProcessor.cacheImageToSharedStorage(image, forKey: "profile", quality: 0.8)

// Retrieve from shared storage
if let sharedCached = imageProcessor.cachedImageFromSharedStorage(forKey: "profile") {
    // Use shared cached image
}

// Remove from shared storage
imageProcessor.removeCachedImageFromSharedStorage(forKey: "profile")

// Clear caches
imageProcessor.clearCache()                      // In-memory
imageProcessor.clearSharedStorageCache()         // Shared storage
```

### Toast Notifications
```swift
import SwapFoundationKit

// Define your app's toast types conforming to SFKToastKind
enum AppToastType: SFKToastKind {
    case itemAdded
    case itemDeleted
    case exportSuccess
    case error(String)

    var title: String {
        switch self {
        case .itemAdded: return "Added!"
        case .itemDeleted: return "Deleted!"
        case .exportSuccess: return "Exported!"
        case .error: return "Error"
        }
    }

    var subtitle: String? {
        switch self {
        case .itemAdded: return "Item has been added."
        case .itemDeleted: return "Item removed."
        case .exportSuccess: return "Export complete."
        case .error(let msg): return msg
        }
    }

    var style: SFKToastStyle {
        switch self {
        case .itemAdded, .itemDeleted, .exportSuccess: return .success
        case .error: return .error
        }
    }

    var image: UIImage? {
        switch style {
        case .success: return UIImage(systemName: "checkmark.circle")
        case .error: return UIImage(systemName: "xmark.circle.fill")
        case .warning: return UIImage(systemName: "exclamationmark.triangle")
        case .informational: return UIImage(systemName: "info.circle")
        }
    }
}

// Show a toast
ToastManager.shared.show(kind: AppToastType.itemAdded)

// With custom config
ToastManager.shared.show(kind: AppToastType.error("Something went wrong"), config: SFKToastConfiguration(displayTime: 4.0))
```

### File Export and Import
```swift
import SwapFoundationKit

// Export: present a share sheet with JSON data
let subscriptions: [SubscriptionProxy] = ...
let encoder = JSONEncoder()
encoder.dateEncodingStrategy = .iso8601
try FileExportService.shared.export(
    subscriptions,
    filename: "subscriptions.json",
    encoder: encoder,
    from: presentingViewController
)

// Import: present a document picker and handle the result
FileImportService.shared.importFile(
    contentTypes: [.json],
    from: presentingViewController,
    delegate: self
)

// Register a custom file type
let recurType = FileImportService.shared.registerCustomType(
    fileExtension: "recur",
    conformingTo: .json
)
FileImportService.shared.importFile(
    contentTypes: [recurType],
    from: presentingViewController,
    delegate: self
)

// FileImportDelegate implementation
extension MyViewController: FileImportDelegate {
    func fileImportDidPick(data: Data, url: URL) {
        // Parse data and import
    }
    func fileImportDidCancel() {
        // Handle cancellation
    }
}
```

### Deeplink Handler
```swift
import SwapFoundationKit

// Define your app's routes conforming to DeeplinkRoute
enum AppRoute: DeeplinkRoute {
    case product(id: String)
    case profile(userId: String)
    case cart

    var path: String {
        switch self {
        case .product: return "/product"
        case .profile: return "/profile"
        case .cart: return "/cart"
        }
    }

    var queryItems: [URLQueryItem] {
        switch self {
        case let .product(id): return [URLQueryItem(name: "id", value: id)]
        case let .profile(userId): return [URLQueryItem(name: "userId", value: userId)]
        case .cart: return []
        }
    }

    static func parse(from url: URL) -> AppRoute? {
        // Parse URL into route
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return nil
        }
        switch components.path {
        case "/product":
            if let id = components.queryItems?.first(where: { $0.name == "id" })?.value {
                return .product(id: id)
            }
        case "/profile":
            if let userId = components.queryItems?.first(where: { $0.name == "userId" })?.value {
                return .profile(userId: userId)
            }
        case "/cart":
            return .cart
        default:
            return nil
        }
        return nil
    }
}

// Configure routes in SwapFoundationKitConfiguration
let config = SwapFoundationKitConfiguration(
    appMetadata: myAppMeta,
    supportedRoutes: [AppRoute.self]
)

// Subscribe to deeplinks
SwapFoundationKit.shared.deeplinkHandler?
    .deeplinkPublisher
    .receive(on: DispatchQueue.main)
    .sink { event in
        if let route = event.route as? AppRoute {
            switch route {
            case let .product(id):
                coordinator.showProduct(id: id)
            case let .profile(userId):
                coordinator.showProfile(userId: userId)
            case .cart:
                coordinator.showCart()
            }
        } else {
            // Fallback to raw URL handling
            coordinator.handleRawDeeplink(url: event.url, source: event.source)
        }
    }
    .store(in: &cancellables)

// SceneDelegate integration:
func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    if let url = connectionOptions.urlContexts.first?.url {
        SwapFoundationKit.shared.deeplinkHandler?.handle(url: url, source: .coldLaunch)
    }
    if let userActivity = connectionOptions.userActivities.first {
        SwapFoundationKit.shared.deeplinkHandler?.handle(userActivity: userActivity)
    }
}

func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
    if let url = URLContexts.first?.url {
        SwapFoundationKit.shared.deeplinkHandler?.handle(url: url, source: .resume)
    }
}

func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
    SwapFoundationKit.shared.deeplinkHandler?.handle(userActivity: userActivity)
}
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

---

## 12) Ad Integration Architecture (Wrapper-Only)

Keep Google Mobile Ads types out of generic app code when possible: link the optional **`SwapFoundationKitGoogleMobileAds`** product and use **`AdsManager`** / **`AdaptiveBannerAdView`**. Core **`SwapFoundationKit`** no longer pulls in the Google Mobile Ads SDK.

### Architecture

```
App Target (with ads)
├── SwapFoundationKit (core — config types only)
├── SwapFoundationKitGoogleMobileAds → GoogleMobileAds
└── (optional) SwapProKit / SwapProKitAdMob for subscription + attribution stacks

App target should use:
├── AdsManager (SwapFoundationKitGoogleMobileAds) — SDK init and wrapper
├── AdaptiveBannerAdView (SwapFoundationKitGoogleMobileAds) — banner display
└── AdsConfiguration / AdUnitConfiguration (SwapFoundationKit) — config
```

### Why the split

1. **Optional dependency**: Apps that do not show ads link only `SwapFoundationKit` and avoid the GMA binary.
2. **Explicit version**: You can add Google’s `GoogleMobileAds` package on the app target and pin the same version as SFK’s ads module (see `Package.swift`).
3. **Simulator / previews**: `AdsManager.startIfNeeded` and the ads module’s stubs avoid loading real ads on simulator; see [GOOGLE_MOBILE_ADS.md](GOOGLE_MOBILE_ADS.md).

### Correct Usage

**After `SwapFoundationKit.shared.start` — SDK setup:**
```swift
import SwapFoundationKit
import SwapFoundationKitGoogleMobileAds

private func setupAds() {
    Task { @MainActor in
        await AdsManager.startIfNeeded(
            configuration: AdsConfiguration(
                provider: .google(GoogleAdsConfiguration()),
                adUnits: AdUnitConfiguration(
                    banner: "ca-app-pub-xxxxxxx/banner",
                    interstitial: "ca-app-pub-xxxxxxx/interstitial",
                    rewarded: "ca-app-pub-xxxxxxx/rewarded"
                ),
                preloadOnStart: [.interstitial],
                isEligibleToShowAds: {
                    !ProManager.shared.isProEnabled
                },
                presentingViewController: {
                    UIApplication.topViewController()
                },
                eventHandler: { event in
                    switch event {
                    case .impression(.banner):
                        AppAnalyticsManager.shared.logEvent(event: .didRecordBannerAdImpressions)
                    case .click(.banner):
                        AppAnalyticsManager.shared.logEvent(event: .didRecordBannerAdClick)
                    // ... handle other events
                    }
                }
            )
        )
    }
}
```

**Views — Banner display:**
```swift
import SwapFoundationKitGoogleMobileAds

struct MyView: View {
    var body: some View {
        VStack {
            AdaptiveBannerAdView()
                .frame(height: 80)
        }
    }
}
```

### What NOT To Do

- Do not pass `adsConfiguration` into `SwapFoundationKitConfiguration` (removed); call `AdsManager.startIfNeeded` or `AdsManager.shared.start` from the ads module instead.
- Do not create inline `UIViewControllerRepresentable` wrappers for `BannerView` unless you have a strong reason — use `AdaptiveBannerAdView`.

### RevenueCat Ad Attribution

If you use SwapProKitAdMob / RevenueCatAdMob, keep that integration in the wrapper layer you own; SFK’s `GoogleAdsProvider` focuses on loading and presenting ads.

### Simulator Behavior

Ads do not load on simulator. `AdaptiveBannerAdView` uses an empty container when the provider is unavailable. `AdsManager.startIfNeeded` is a no-op on simulator; `AdsManager.shared.start` uses the simulator stub provider.

### Validation

- Build succeeds in both Debug and Release
- Archive succeeds
- Banner renders on physical device (not simulator)
- RevenueCat dashboard shows ad revenue attribution (check sandbox data)

---

## 14) Update Available Banner

This feature has moved out of `SwapFoundationKit`.

Use `UpdateAvailableKit` directly for:
- App Store version checks
- reactive update availability state
- update available banner UI

`SFKSettingsScreen` no longer includes built-in update-banner placement hooks.

// Show
bannerState = .available(newVersion: "2.1.0")
```
