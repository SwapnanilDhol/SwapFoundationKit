# SwapFoundationKit

A comprehensive Swift package providing essential utilities, extensions, and services for iOS, macOS, and watchOS development. Built with modern Swift features and designed for developer productivity.

## 🎯 Migration Guide: Replacing Redundant Implementations

When integrating SwapFoundationKit into your app, you should **replace all redundant implementations** with the SDK's provided classes and utilities. This guide helps you identify what can be replaced and how to do it.

### Host App Audit

If you want an LLM or code-review agent to audit a host app for overlap with
SwapFoundationKit, use `Docs/host-app-audit-catalog.yaml` as the source of truth
and `AGENTS.md` as the workflow. The catalog only lists public API and marks each
capability as `exact`, `heuristic`, or `manual` to keep audits useful instead of noisy.

### Step-By-Step: Audit A Host App

You do not need a `SKILL.md` to start. The minimum setup is:

- the host app repository
- this `SwapFoundationKit` repository
- an agent that can read both

#### 1. Keep both repos available locally

If you already have both repos on disk, use those paths. Otherwise clone this repo somewhere convenient:

```bash
cd /path/to/workspace
git clone https://github.com/SwapnanilDhol/SwapFoundationKit.git
```

For the examples below, assume:

- host app path: `/path/to/HostApp`
- SwapFoundationKit path: `/path/to/SwapFoundationKit`

#### 2. Run a high-confidence audit first

Start with the `exact` tier only. That gives you the least noisy report.

Use this prompt with any coding agent:

```text
Use /path/to/SwapFoundationKit/AGENTS.md and /path/to/SwapFoundationKit/Docs/host-app-audit-catalog.yaml as the source of truth.

Audit this host app for redundant implementations that already exist in SwapFoundationKit.

Rules:
- Start with audit_tier: exact only.
- Classify each finding as replace, review, or keep.
- Cite the host app file and the matching SwapFoundationKit file.
- Do not suggest internal-only SFK helpers as replacements.
- Focus on high-confidence overlaps first.

Return:
1. A short summary.
2. A finding list grouped by replace / review / keep.
3. A suggested migration order.
```

#### 3. Codex

Install Codex if needed:

```bash
npm install -g @openai/codex
codex login
```

Run Codex from the host app root:

```bash
cd /path/to/HostApp
codex
```

Then paste the prompt above.

For a read-only audit, stay in the default suggest mode. Only switch to edit modes after you agree with the findings.

If you want Codex to help migrate after the audit:

```bash
cd /path/to/HostApp
codex --auto-edit
```

Then ask it to replace one capability at a time, starting with the highest-confidence `replace` findings.

#### 4. Claude Code

Install Claude Code if needed:

```bash
npm install -g @anthropic-ai/claude-code
```

Run Claude Code from the host app root:

```bash
cd /path/to/HostApp
claude
```

Then paste the same prompt.

If you prefer non-interactive output, Claude Code also supports a print mode:

```bash
claude -p "Use /path/to/SwapFoundationKit/AGENTS.md and /path/to/SwapFoundationKit/Docs/host-app-audit-catalog.yaml as the source of truth. Audit this host app for redundant implementations that already exist in SwapFoundationKit. Start with audit_tier: exact only. Classify each finding as replace, review, or keep. Cite the host app file and the matching SwapFoundationKit file. Do not suggest internal-only SFK helpers as replacements. Return a short summary, the findings, and a suggested migration order." --cwd /path/to/HostApp
```

#### 5. Expand to broader overlap checks

Once the exact-tier report looks right, run a second prompt:

```text
Now run the heuristic tier from the audit catalog.

Rules:
- Keep false positives low.
- Only flag overlaps that are realistically worth consolidating into SwapFoundationKit.
- Separate likely wins from "review manually" items.
```

Use the `manual` tier last, mainly for generic extensions and utilities where naming overlap alone is not enough.

#### 6. Turn the audit into migration work

After the audit, use a follow-up prompt like this:

```text
Using the exact-tier findings only, create a migration plan for this host app.

Return:
1. The order to migrate capabilities.
2. Risks or behavior changes to watch for.
3. The search-and-replace patterns to use.
4. The tests or smoke checks to run after each migration.
```

#### 7. Recommended workflow

1. Run the `exact` tier.
2. Review the `replace` findings manually.
3. Migrate one capability at a time.
4. Run app tests after each migration.
5. Run the `heuristic` tier only after the obvious overlaps are removed.

#### Notes

- If your agent cannot read files outside the host app directory, either give it access to the SwapFoundationKit path or paste the contents of `AGENTS.md` and `Docs/host-app-audit-catalog.yaml` into the session.
- Keep app-specific facades when they add domain behavior. In those cases, SwapFoundationKit should usually sit underneath the facade rather than replace it completely.

### ⚠️ Important Migration Principle

**If your app already has an implementation for any of the features listed below, replace it with SwapFoundationKit's implementation by importing the library.** This modularizes your codebase and ensures consistency across your app ecosystem.

---

## 📋 Requirements

- **iOS**: 16.0+
- **macOS**: 16.0+
- **watchOS**: 6.0+
- **Swift**: 5.9+
- **Xcode**: 15.0+

## 📦 Installation

### Swift Package Manager

Add SwapFoundationKit to your project in Xcode:

1. Go to **File** → **Add Package Dependencies**
2. Enter the repository URL: `https://github.com/SwapnanilDhol/SwapFoundationKit`
3. Select the version you want to use
4. Click **Add Package**

Or add it to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/SwapnanilDhol/SwapFoundationKit", from: "1.0.0")
]
```

---

## 🔄 Components to Replace

### 1. Haptics Manager / Feedback Generator

**If your app has a haptics manager class, replace it with `HapticsHelper` from SwapFoundationKit.**

```swift
import SwapFoundationKit

// Replace your custom haptics manager with:
let haptics = HapticsHelper()

// Use it throughout your app:
haptics.lightImpact()
haptics.mediumImpact()
haptics.heavyImpact()
haptics.successNotification()
haptics.warningNotification()
haptics.errorNotification()
haptics.customImpact(intensity: 0.8)
```

**Migration Steps:**
1. Search for your custom haptics/feedback classes
2. Replace all instances with `HapticsHelper()`
3. Update method calls to match `HapticsHelper` API
4. Remove your custom implementation

---

### 2. Logger / Logging System

**If your app has a custom logger class, replace it with `Logger` from SwapFoundationKit.**

```swift
import SwapFoundationKit

// Replace your custom logger with:
Logger.info("User signed in successfully")
Logger.debug("Processing request...")
Logger.warning("API rate limit approaching")
Logger.error("Failed to load user data")

// Configure logging level
Logger.minimumLevel = .info

// Enable automatic analytics integration for errors
await Logger.setSendAnalyticsOnError(true)
```

**Migration Steps:**
1. Find all references to your custom logger
2. Replace with `Logger.info()`, `Logger.debug()`, `Logger.warning()`, `Logger.error()`
3. Remove your custom logger implementation
4. The SDK's logger automatically integrates with analytics when configured

---

### 3. UserDefaults Wrapper / Type-Safe UserDefaults

**If your app has a UserDefaults wrapper or type-safe UserDefaults implementation, replace it with `UserDefault` property wrapper from SwapFoundationKit.**

```swift
import SwapFoundationKit

// Define your keys
enum AppKeys: UserDefaultKeyProtocol {
    case userId
    case isFirstLaunch
    case theme
    
    var keyString: String {
        switch self {
        case .userId: return "user_id"
        case .isFirstLaunch: return "is_first_launch"
        case .theme: return "theme"
        }
    }
}

// Use in your classes/views
class SettingsViewModel {
    @UserDefault(AppKeys.userId, default: "")
    var userId: String
    
    @UserDefault(AppKeys.isFirstLaunch, default: true)
    var isFirstLaunch: Bool
    
    @UserDefault(AppKeys.theme, default: "light")
    var theme: String
}

// SwiftUI binding support included
struct SettingsView: View {
    @UserDefault(AppKeys.theme, default: "light")
    var theme: String
    
    var body: some View {
        Picker("Theme", selection: $theme) {
            Text("Light").tag("light")
            Text("Dark").tag("dark")
        }
    }
}
```

**Migration Steps:**
1. Identify your UserDefaults wrapper/helper classes
2. Create a key enum conforming to `UserDefaultKeyProtocol`
3. Replace property declarations with `@UserDefault` wrapper
4. Remove your custom UserDefaults implementation

---

### 4. Analytics Manager / Event Tracking

**If your app has an analytics manager or event tracking system, replace it with `AnalyticsManager` from SwapFoundationKit.**

```swift
import SwapFoundationKit

// Define your analytics events
enum AppAnalyticsEvent: AnalyticsEvent {
    case userSignedIn(userId: String)
    case purchase(amount: Double, currency: String)
    case viewScreen(screenName: String)
    
    var rawValue: String {
        switch self {
        case .userSignedIn: return "user_signed_in"
        case .purchase: return "purchase"
        case .viewScreen: return "view_screen"
        }
    }
    
    var parameters: [String: String]? {
        switch self {
        case .userSignedIn(let userId):
            return ["user_id": userId]
        case .purchase(let amount, let currency):
            return ["amount": String(amount), "currency": currency]
        case .viewScreen(let screenName):
            return ["screen_name": screenName]
        }
    }
}

// Create your analytics logger (e.g., Firebase)
class FirebaseAnalyticsLogger: AnalyticsLogger {
    func logEvent(event: AnalyticsEvent, additionalParameters: [String: String]?) {
        // Your Firebase implementation
        var firebaseParams: [String: Any] = [:]
        if let parameters = additionalParameters {
            for (key, value) in parameters {
                firebaseParams[key] = value
            }
        }
        // Analytics.logEvent(event.rawValue, parameters: firebaseParams)
    }
}

// Setup (in AppDelegate or App struct)
let analyticsManager = AnalyticsManager.shared
analyticsManager.addLogger(FirebaseAnalyticsLogger())
analyticsManager.setGlobalParameters([
    "app_version": "1.0.0",
    "build_number": "100",
    "platform": "ios"
])

// Use throughout your app
let event = AppAnalyticsEvent.userSignedIn(userId: "user123")
AnalyticsManager.shared.logEvent(event: event)
AnalyticsManager.shared.logEvent(event: .viewScreen(screenName: "home"), parameters: ["source": "push"])
```

Parameter merge precedence in `logEvent(event:parameters:)` is:
1. `event.parameters` (lowest)
2. global parameters (`setGlobalParameters`)
3. call-site `parameters` argument (highest)

Use `logEvent(event:)` for standard tracking with event defaults + global metadata.
Use `logEvent(event:parameters:)` when you need per-call context or overrides.

Use `clearGlobalParameters()` when you need to stop injecting shared metadata (for example, after logout).

**Migration Steps:**
1. Find your custom analytics manager/tracker
2. Create event enums conforming to `AnalyticsEvent`
3. Create logger classes conforming to `AnalyticsLogger`
4. Replace all analytics calls with `AnalyticsManager.shared.logEvent()`
5. Remove your custom analytics implementation

---

### 5. Network Client / HTTP Client / API Service

**If your app has a custom network client, HTTP client, or API service, replace it with `HTTPClient` or `NetworkService` from SwapFoundationKit.**

#### Option 1: Using HTTPClient (Modern async/await)

```swift
import SwapFoundationKit

// Initialize in your app configuration
let config = SwapFoundationKitConfiguration(
    appMetadata: AppMetaData(appGroupIdentifier: "group.com.example.app"),
    enableNetworking: true,
    networkTimeout: 30.0
)

try await SwapFoundationKit.shared.start(with: config)

// Get the HTTP client
guard let client = SwapFoundationKit.shared.networkClient else {
    return
}

// Define network requests
struct GetUsersRequest: NetworkRequest {
    var scheme: String { "https" }
    var baseURL: String { "api.example.com" }
    var path: String { "/users" }
    var method: HTTPMethod { .get }
    var parameters: [String: String]? { ["limit": "10"] }
}

// Execute requests
let users: [User] = try await client.executeAndDecode(GetUsersRequest())

// Or use convenience methods
let response = try await client.get(
    baseURL: "api.example.com",
    path: "/users",
    parameters: ["limit": "10"]
)
```

#### Option 2: Using NetworkService (Reachability + Basic HTTP)

```swift
import SwapFoundationKit

let networkService = NetworkService()

// Check connectivity
if networkService.isConnected {
    // Make request
}

// Monitor connectivity
networkService.$isConnected
    .sink { isConnected in
        print("Connected: \(isConnected)")
    }

// Make requests
let data = try await networkService.get(from: url)
let user: User = try await networkService.get(from: url, as: User.self)
```

**Migration Steps:**
1. Identify your custom network/API client classes
2. Replace with `HTTPClient` for modern async/await or `NetworkService` for reachability
3. Update all network calls to use the new API
4. Remove your custom network implementation

---

### 6. Security Service / Encryption / Keychain Manager

**If your app has a security service, encryption utility, or keychain manager, replace it with `SecurityService` from SwapFoundationKit.**

```swift
import SwapFoundationKit

let securityService = SecurityService()

// Encryption/Decryption
let encryptedData = try securityService.encrypt(data)
let decryptedData = try securityService.decrypt(encryptedData)

let encryptedString = try securityService.encryptString("sensitive data")
let decryptedString = try securityService.decryptString(encryptedString)

// Keychain operations
try securityService.storeInKeychain(data, forKey: "user_token")
let storedData = try securityService.retrieveFromKeychain(forKey: "user_token")
try securityService.removeFromKeychain(forKey: "user_token")

// Secure storage (encrypted + keychain)
try securityService.storeSecurely(data, forKey: "sensitive_key")
let secureData = try securityService.retrieveSecurely(forKey: "sensitive_key")

// Hashing
let hash = securityService.sha256Hash(data)
let stringHash = securityService.sha256Hash("string to hash")
```

**Migration Steps:**
1. Find your custom security/encryption/keychain classes
2. Replace with `SecurityService()`
3. Update all security operations to use the new API
4. Remove your custom security implementation

---

### 7. Backup Service / Data Export

**If your app has a backup or data export service, replace it with `BackupService` from SwapFoundationKit.**

```swift
import SwapFoundationKit

let backupService = BackupService()

// Perform backup
struct UserData: Codable {
    let users: [User]
    let settings: Settings
}

let userData = UserData(users: users, settings: settings)
try await backupService.performBackup(userData, fileType: .data)

// Restore the newest on-device backup (same ordering as list: first = newest)
let restoredData = try backupService.restoreBackup(UserData.self, fileType: .data)

// List backup files (newest first)
let backupFiles = backupService.listBackupFiles(for: .data)
```

**On-disk layout:** each `FileType` writes under **`Documents/<rawValue>/`** (e.g. `Documents/data/`) as timestamped `*.backup` files containing **one JSON-encoded payload** (whatever generic you passed to `performBackup`). `restoreBackup` reads the **newest** file in that folder; it no longer uses a mismatched path relative to `performBackup`. Filenames use **second-level** timestamps, so two backups within the same clock second share one filename and the second write **replaces** the first.

**Unit tests:** `BackupService` supports an optional documents root override so tests do not touch the real app sandbox:

```swift
let tempRoot = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString)
let backupService = BackupService(documentsDirectoryOverride: tempRoot)
```

**Migration Steps:**
1. Find your custom backup/export classes
2. Replace with `BackupService()`
3. Update backup/restore calls
4. Remove your custom backup implementation

---

### 8. Currency Converter / Exchange Rate Manager

**If your app has a currency converter or exchange rate manager, replace it with `ExchangeRateManager` and `Currency` from SwapFoundationKit.**

```swift
import SwapFoundationKit

// Start the exchange rate manager (call on app launch)
await ExchangeRateManager.shared.start()

// Convert currencies
let usdAmount = ExchangeRateManager.shared.convert(
    value: 100.0,
    fromCurrency: .EUR,
    toCurrency: .USD
)

// Use Currency enum
let currency: Currency = .USD
print(currency.symbol) // 🇺🇸
print(currency.currencySymbol) // $
print(currency.description) // "US Dollar"
```

**Migration Steps:**
1. Find your custom currency/exchange rate classes
2. Replace with `ExchangeRateManager.shared` and `Currency` enum
3. Update all currency operations
4. Remove your custom currency implementation

---

### 9. Image Processor / Image Utilities

**If your app has an image processor, image cache, or image manipulation utilities, replace it with `ImageProcessor` from SwapFoundationKit.**

```swift
import SwapFoundationKit

let imageProcessor = ImageProcessor.shared

// Resize images
if let resizedImage = imageProcessor.resize(originalImage, to: CGSize(width: 300, height: 300)) {
    imageView.image = resizedImage
}

// Round corners
if let roundedImage = imageProcessor.roundCorners(image, radius: 20) {
    imageView.image = roundedImage
}

// Convert to grayscale
if let grayscaleImage = imageProcessor.toGrayscale(image) {
    imageView.image = grayscaleImage
}

// Apply blur
if let blurredImage = imageProcessor.applyBlur(image, style: .light) {
    imageView.image = blurredImage
}

// Cache images (in-memory NSCache)
imageProcessor.cacheImage(image, forKey: "profile_image")
if let cachedImage = imageProcessor.cachedImage(forKey: "profile_image") {
    imageView.image = cachedImage
}

// Create stable cache keys for remote URLs
let remoteKey = imageProcessor.cacheKey(for: URL(string: "https://example.com/avatar.jpg")!)

// Download, resize, and cache remote images
let avatarURL = URL(string: "https://example.com/avatar.jpg")!
let avatar = try await imageProcessor.cacheImage(
    from: avatarURL,
    targetSize: CGSize(width: 150, height: 150)
)

// Retrieve cached remote images later
if let cachedAvatar = imageProcessor.cachedImage(
    from: avatarURL,
    targetSize: CGSize(width: 150, height: 150)
) {
    imageView.image = cachedAvatar
}

// Configure shared app group storage for extensions
imageProcessor.configure(
    shouldCacheToSharedStorage: true,
    appGroupIdentifier: "group.com.yourapp.widget"
)

// Cache images to shared app group (accessible by widgets/extensions)
try imageProcessor.cacheImageToSharedStorage(image, forKey: "profile_image")

// Retrieve from shared storage
if let sharedCached = imageProcessor.cachedImageFromSharedStorage(forKey: "profile_image") {
    imageView.image = sharedCached
}

// Clear caches
imageProcessor.clearCache()                      // Clear in-memory cache
imageProcessor.clearSharedStorageCache()         // Clear shared storage

// Save/Load images
let url = try imageProcessor.saveImage(image, filename: "profile.jpg", quality: 0.9)
let loadedImage = try imageProcessor.loadImage(filename: "profile.jpg")
```

**Migration Steps:**
1. Find your custom image processing/caching classes
2. Replace with `ImageProcessor.shared`
3. Update all image operations
4. For remote URL caching, use `cacheImage(from:targetSize:)` and `cachedImage(from:targetSize:)`
5. For widget/extension sharing, configure with `configure(shouldCacheToSharedStorage:appGroupIdentifier:)`
6. Remove your custom image implementation

---

### 10. Debouncer / Throttler

**If your app has a debouncer or throttler utility, replace it with `Debouncer` from SwapFoundationKit.**

```swift
import SwapFoundationKit

let debouncer = Debouncer(delay: 0.5)

// Debounce search input
debouncer.call {
    performSearch(query: searchText)
}
```

**Migration Steps:**
1. Find your custom debouncer/throttler classes
2. Replace with `Debouncer(delay:)`
3. Update all debounced operations
4. Remove your custom debouncer implementation

---

### 11. Date Utilities / Date Formatters

**If your app has custom date utilities or formatters, replace them with `Date` extensions from SwapFoundationKit.**

```swift
import SwapFoundationKit

let date = Date()

// Formatting
print(date.iso8601String)        // "2024-01-15T10:30:00Z"
print(date.shortDate)            // "1/15/24"
print(date.mediumDate)           // "Jan 15, 2024"
print(date.longDate)             // "January 15, 2024"
print(date.fullDate)             // "Monday, January 15, 2024"
print(date.timeOnly)             // "10:30 AM"
print(date.yyyyMMdd)             // "2024-01-15"
print(date.relativeTime)         // "2 hours ago"

// Date components
print(date.year)                 // 2024
print(date.month)                // 1
print(date.day)                  // 15
print(date.weekdayName)          // "Monday"

// Date calculations
print(date.isToday)              // true/false
print(date.isYesterday)          // true/false
print(date.isThisWeek)           // true/false
print(date.startOfDay)           // Date at midnight
print(date.endOfDay)             // Date at 23:59:59

// Date manipulation
let tomorrow = date.adding(days: 1)
let nextMonth = date.adding(months: 1)

// Custom formatting
let formatted = date.string(format: "EEE, MMM d @ h:mm a")
```

**Migration Steps:**
1. Find your custom date utility/formatter classes
2. Replace with `Date` extension methods
3. Update all date operations
4. Remove your custom date implementation

---

### 12. String Utilities / String Extensions

**If your app has custom string utilities or extensions, replace them with `String` extensions from SwapFoundationKit.**

```swift
import SwapFoundationKit

let string = "  Hello World  "

// Validation
print(string.isBlank)            // false
print(string.isNotBlank)         // true
print(string.isNumeric)          // false
print(string.isValidEmail)       // false
print(string.isAlphabetic)       // false
print(string.isAlphanumeric)     // false

// Manipulation
print(string.trimmed)            // "Hello World"
print(string.capitalizedFirst)   // "  hello World  "
print(string.removingWhitespaces) // "HelloWorld"
print(string.truncated(to: 5))    // "Hell..."

// Conversion
print(string.toInt)               // nil
print(string.toDouble)            // nil
print(string.boolValue)           // nil
print(string.url)                 // nil
print(string.data)                // Data?

// Security
print(string.sanitized)           // Safe for display
print(string.fileNameSafe)        // Safe for file names

// Hashing
print(string.md5)                 // MD5 hash
print(string.sha1)                // SHA1 hash
print(string.sha256)               // SHA256 hash

// Localization
print(string.localized)            // Localized string
print(string.localizedFormat("arg1", "arg2"))
```

**Migration Steps:**
1. Find your custom string utility classes
2. Replace with `String` extension properties/methods
3. Update all string operations
4. Remove your custom string implementation

---

### 13. Number Formatting / Number Utilities

**If your app has custom number formatting utilities, replace them with number extensions from SwapFoundationKit.**

```swift
import SwapFoundationKit

let number: Double = 1234.56

// Clean formatting
print(number.clean)               // "1,234.56"
print(number.wordRepresentation) // "one thousand two hundred thirty-four point five six"

let floatNumber: Float = 100.0
print(floatNumber.clean)          // "100"
```

**Migration Steps:**
1. Find your custom number formatting classes
2. Replace with `Double`/`Float` extension properties
3. Update all number formatting
4. Remove your custom number implementation

---

### 14. Data Crypto / Hashing Utilities

**If your app has custom crypto or hashing utilities, replace them with `Data` extensions from SwapFoundationKit.**

```swift
import SwapFoundationKit

let data = "Hello World".data(using: .utf8)!

// Hashing
print(data.md5)                   // MD5 hash string
print(data.sha1)                  // SHA1 hash string
print(data.sha256)                // SHA256 hash string
```

**Migration Steps:**
1. Find your custom crypto/hashing classes
2. Replace with `Data` extension properties
3. Update all hashing operations
4. Remove your custom crypto implementation

---

### 15. Bundle / Info.plist Access

**If your app has custom Info.plist access utilities, replace them with `Bundle` extensions from SwapFoundationKit.**

```swift
import SwapFoundationKit

let bundle = Bundle.main

// Access Info.plist values
print(bundle.appName)                      // App name
print(bundle.displayName)                 // Display name
print(bundle.bundleIdentifier)            // Bundle ID
print(bundle.releaseVersionNumber)        // Version
print(bundle.buildVersionNumber)          // Build number
print(bundle.urlSchemes)                  // URL schemes array

// Generic access
let customValue: String = bundle.infoPlistValue(
    forKey: "CustomKey",
    default: "default"
)
```

**Migration Steps:**
1. Find your custom Info.plist access classes
2. Replace with `Bundle` extension properties
3. Update all Info.plist access
4. Remove your custom bundle implementation

---

### 16. Collection Utilities

**If your app has custom collection utilities, replace them with `Collection` extensions from SwapFoundationKit.**

```swift
import SwapFoundationKit

let array = [1, 2, 3, 4, 5]

// Safe subscript
print(array[safe: 10])           // nil (instead of crash)
print(array.isNotEmpty)          // true
```

**Migration Steps:**
1. Find your custom collection utility classes
2. Replace with `Collection` extension properties
3. Update all collection operations
4. Remove your custom collection implementation

---

### 17. ItemSync + WatchSync / Data Synchronization

**If your app has custom data synchronization between app, widgets, and Watch, replace it with `ItemSync` + `WatchSync` from SwapFoundationKit.**

```swift
import SwapFoundationKit.ItemSync

// Define your data model
struct UserProfile: SyncableData {
    let id: String
    let name: String
    static let syncIdentifier = "user_profile"
}

// Create sync service (after SwapFoundationKit.shared.start())
let syncService = ItemSyncServiceFactory.create()

// Save data (automatically syncs to widgets/extensions)
try await syncService.save(userProfile)

// Read data from anywhere in your app ecosystem
let profile = try await syncService.read(UserProfile.self)
```

Watch transport can now be configured with `WatchSyncOptions`:

```swift
#if os(iOS)
let syncService = ItemSyncServiceFactory.createWithWatch(
    appGroupIdentifier: "group.com.yourapp.widget",
    options: WatchSyncOptions(
        preferredTransport: .applicationContext,
        fallbackOrder: [.userInfo, .messageData, .file]
    )
)
#endif
```

**Migration Steps:**
1. Find your custom sync/sharing classes
2. Replace with `ItemSyncServiceFactory.create()` or `createWithWatch(..., options:)`
3. Make your models conform to `SyncableData`
4. Update all sync operations
5. Remove your custom sync implementation

---

### 18. App Link Opener / URL Utilities

**If your app has a URL opener or app link utility, replace it with `AppLinkOpener` from SwapFoundationKit.**

```swift
import SwapFoundationKit

// Open URLs
AppLinkOpener.open(url: url)
AppLinkOpener.open(string: "https://example.com")

// Open maps
let coordinates = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
AppLinkOpener.open(coordinates: coordinates)

// Open App Store
AppLinkOpener.openAppStorePage(appID: "123456789")
AppLinkOpener.openAppReviewPage(appID: "123456789")
```

**Migration Steps:**
1. Find your custom URL/link opener classes
2. Replace with `AppLinkOpener` static methods
3. Update all URL opening operations
4. Remove your custom URL opener implementation

---

### 19. SFKButtons (SwiftUI Button Components)

SwapFoundationKit provides a comprehensive SwiftUI button library with glassmorphism effects, multiple styles, loading states, and built-in haptic feedback.

#### SFKButton
Single button API with enum-driven variants. On iOS 26+, button chrome uses `glassProminent`; on earlier OS versions it falls back to a solid background automatically.
```swift
import SwapFoundationKit

SFKButton(
    kind: .primary,
    title: "Add Transaction",
    systemImage: "wand.and.stars",
    tint: .blue
) {
    // action
}

SFKButton(
    kind: .secondary,
    title: "Cancel"
) { }

SFKButton(
    kind: .inline,
    title: "Edit",
    systemImage: "pencil"
) { }

SFKButton(
    kind: .pill,
    title: "Approve",
    systemImage: "checkmark",
    tint: .green
) { }

SFKButton(
    kind: .toolbar,
    title: "Save",
    systemImage: "checkmark"
) { }

SFKButton(
    kind: .close,
    title: ""
) { }

// Loading state for primary actions
SFKButton(
    kind: .primary,
    title: "Saving...",
    tint: .green,
    isLoading: true
) { }
```

The convenience wrappers `SFKPrimaryButton`, `SFKSecondaryButton`, `SFKInlineButton`, `SFKPillButton`, and `SFKToolbarButton` still exist, but `SFKButton(kind: ...)` is the simplest API and the recommended one.

You can also override the shared button tokens from the host app:
```swift
SFKButtonVisualTokens.current.primaryCornerRadius = 18
SFKButtonVisualTokens.current.secondaryCornerRadius = 18
SFKButtonVisualTokens.current.inlineCornerRadius = 12
SFKButtonVisualTokens.current.primaryForegroundColor = Color(
    uiColor: UIColor(red: 2, green: 2, blue: 2, alpha: 1)
)
SFKButtonVisualTokens.current.tintedForegroundColor = .primary
SFKButtonVisualTokens.current.toolbarForegroundColor = .primary
```

#### Glass Button Modifiers
Apply glassmorphism effects to any view.
```swift
Button("Glass") { }
    .glassButton(cornerRadius: 16, tint: .blue)

Button("Capsule") { }
    .glassCapsuleButton(tint: .mint)

Button(action: {}) {
    Image(systemName: "plus")
        .font(.title2)
}
.glassCircleButton(tint: .blue)
```

**Migration Steps:**
1. Find your custom button components (MTPrimaryButton, MTToolbarButton, etc.)
2. Prefer replacing them with `SFKButton(kind: ...)`
3. Use `SFKButtonVisualTokens.current` from the host app for corner-radius and foreground overrides
4. Remove custom button implementations

---

### 20. AlertPresenter / AlertController

SwapFoundationKit provides comprehensive alert presentation helpers for both UIKit and SwiftUI.

#### AlertController (SwiftUI-native)

A `@MainActor` ObservableObject for declarative alert management in SwiftUI.

```swift
import SwapFoundationKit

// Create controller
@StateObject private var alertController = AlertController()

// Show simple alert
alertController.showAlert(
    title: "Success",
    message: "Operation completed",
    actionTitle: "OK"
)

// Show confirmation dialog
alertController.showConfirmation(
    title: "Delete Item?",
    message: "This action cannot be undone.",
    confirmTitle: "Delete",
    confirmStyle: .destructive,
    onConfirm: { /* handle confirm */ },
    onCancel: { /* handle cancel */ }
)

// Show text input
alertController.showTextInput(
    title: "Enter Name",
    message: "Please enter your name",
    placeholder: "Name",
    keyboardType: .default,
    onSubmit: { text in /* handle input */ }
)

// Attach to view
var body: some View {
    Button("Show Alert") {
        alertController.showAlert(title: "Hello", message: "World")
    }
    .alert(alertController, textFieldValues: $textValues)
}
```

#### AlertPresenter (UIKit-based, works from SwiftUI)

Static methods for presenting alerts using UIKit.

```swift
import SwapFoundationKit

// Simple alert
AlertPresenter.showAlert(
    title: "Hello",
    message: "World"
)

// Confirmation dialog
AlertPresenter.showConfirmation(
    title: "Continue?",
    message: "Are you sure?",
    confirmTitle: "Yes",
    onConfirm: { /* handle */ }
)

// Alert with multiple actions
AlertPresenter.showAlert(
    title: "Choose",
    message: "Select an option",
    actions: [
        ("Option 1", .default) { },
        ("Option 2", .default) { },
        ("Cancel", .cancel) { }
    ]
)

// Text input alert
AlertPresenter.showTextInput(
    title: "Enter Email",
    message: "Please enter your email",
    placeholder: "email@example.com",
    keyboardType: .email,
    onSubmit: { text in /* handle */ }
)
```

#### Types

- **`AlertAction`** - Represents an alert action with title, style, and handler
- **`AlertActionStyle`** - `.default`, `.cancel`, `.destructive`
- **`AlertTextField`** - Text field configuration with placeholder and keyboard type
- **`KeyboardType`** - Platform-agnostic keyboard type (`.default`, `.email`, `.number`, `.phone`, `.url`)
- **`AlertConfiguration`** - Complete alert configuration
- **`AlertController`** - SwiftUI-native alert manager

---

### 21. UIKit Extensions

**If your app has custom UIKit extensions, check if SwapFoundationKit provides equivalent functionality.**

#### UIColor Extensions
```swift
import SwapFoundationKit

// Hex colors
let color = UIColor(hex: "#FF0000")
print(color.hexString())         // "#FF0000"

// Color components
print(color.redComponent)        // Red component
print(color.greenComponent)      // Green component
print(color.blueComponent)      // Blue component
print(color.alphaComponent)      // Alpha component

// Color manipulation
let lighter = color.lighter(by: 0.2)
let darker = color.darker(by: 0.2)
let random = UIColor.random
```

#### UIView Extensions
```swift
import SwapFoundationKit

// Add multiple subviews
view.addSubviews(view1, view2, view3)

// Remove all subviews
view.removeAllSubviews()

// Find subviews
let buttons = view.allSubViewsOf(type: UIButton.self)

// Layout constraints
view.anchor(top: parentView.topAnchor, leading: parentView.leadingAnchor, 
            bottom: parentView.bottomAnchor, trailing: parentView.trailingAnchor)
```

#### UIImage Extensions
```swift
import SwapFoundationKit

// Resize image
if let resized = image.resized(targetSize: CGSize(width: 100, height: 100)) {
    imageView.image = resized
}
```

**Migration Steps:**
1. Review your custom UIKit extensions
2. Compare with SwapFoundationKit's extensions
3. Replace where functionality overlaps
4. Remove redundant custom extensions

### 22. SFKItemPickerView (Generic Item Picker)

A generic picker view for selecting items from a list, with single-select and multi-select modes, haptics, and flexible icon rendering.

#### Protocols

**`SFKPickableItem`** — protocol for items displayed in the picker:
```swift
public protocol SFKPickableItem: Identifiable, Hashable {
    var pickableItemId: String { get }
    var pickableItemIconKind: SFKPickableItemIconKind { get }
    var pickableItemTitle: String { get }
    var pickableItemSubtitle: String? { get }
}
```

**`SFKPickableItemIconKind`** — icon display modes:
```swift
public enum SFKPickableItemIconKind {
    case iconImage(uiImage: UIImage)
    case systemIcon(symbolName: String)
    case text(text: String)
    case none
}
```

**`SFKItemPickerSelectionMode`**:
```swift
public enum SFKItemPickerSelectionMode: Sendable {
    case single
    case multi
}
```

#### Usage

```swift
import SwapFoundationKit

// Single-select picker
.sheet {
    SFKItemPickerView(
        pageTitle: "Select Currency",
        items: Currency.allCases,
        selectedItems: [selectedCurrency],
        selectionType: .single,
        onSelect: { currency in
            selectedCurrency = currency
        },
        onDismiss: { /* dismiss */ }
    )
}

// Multi-select picker
.sheet {
    SFKItemPickerView(
        pageTitle: "Select Currencies",
        items: Currency.allCases,
        selectedItems: selectedCurrencies,
        selectionType: .multi,
        onSelect: { currency in
            toggleSelection(currency)
        },
        onDismiss: { /* dismiss */ }
    )
}
```

#### Conforming to SFKPickableItem

Always use a dedicated extension:

```swift
extension MyType: SFKPickableItem {
    public var pickableItemId: String { id }

    public var pickableItemIconKind: SFKPickableItemIconKind {
        .systemIcon(symbolName: "star.fill")
    }

    public var pickableItemTitle: String { name }

    public var pickableItemSubtitle: String? { nil }
}
```

`Currency` already conforms to `SFKPickableItem` via an extension at the bottom of `Currency.swift`.

---

### 23. Settings Screen UI

SwapFoundationKit provides a comprehensive settings screen module for building iOS settings screens with minimal boilerplate. It includes a `SettingsItem` protocol, reusable row components for every use case, and a full settings screen builder.

---

## Row Components Overview

| Row Type | Component | Use Case |
|----------|-----------|----------|
| Tappable | `SFKSettingsRow` | Navigation, actions |
| Label | `SFKSettingsLabel` | Display-only |
| Toggle | `SFKSettingsToggle` | Boolean on/off |
| Date Picker | `SFKSettingsDatePickerRow` | Date/time selection |
| Inline Date | `SFKSettingsInlineDatePicker` | Inline date picker |
| Stepper | `SFKSettingsStepperRow` | Numeric +/- |
| Slider | `SFKSettingsSliderRow` | Continuous values |
| Color Picker | `SFKSettingsColorPickerRow` | Color selection |
| Link | `SFKSettingsLinkRow` | Open URL |
| Destructive | `SFKSettingsDestructiveRow` | Delete/reset |
| Confirmation | `SFKSettingsConfirmationRow` | Confirm before action |

---

## SettingsItem Protocol

Define custom settings items by conforming to `SettingsItem`:

```swift
enum MyAppSettingsItem: String, SettingsItem {
    case notifications
    case privacy
    case about

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .notifications: return "bell.circle.fill"
        case .privacy: return "lock.circle.fill"
        case .about: return "info.circle.fill"
        }
    }

    var title: String {
        switch self {
        case .notifications: return "Notifications"
        case .privacy: return "Privacy"
        case .about: return "About"
        }
    }

    var subtitle: String {
        switch self {
        case .notifications: return "Manage notification preferences"
        case .privacy: return "Privacy settings and data"
        case .about: return "App info and credits"
        }
    }

    var tint: Color {
        switch self {
        case .notifications: return .blue
        case .privacy: return .green
        case .about: return .secondary
        }
    }
}
```

---

## Row Component Previews

### SFKSettingsRow (Tappable)

Basic tappable row with chevron:
```swift
SFKSettingsRow(
    item: MySettingsItem.notifications,
    action: { /* handle tap */ }
)
```

With custom trailing content:
```swift
SFKSettingsRow(
    item: versionItem,
    showChevron: false,
    action: {},
    trailing: {
        Text("1.0.0 (100)")
            .font(.subheadline)
            .foregroundStyle(.secondary)
    }
)
```

### SFKSettingsLabel (Display-only)

```swift
SFKSettingsLabel(
    title: "App Version",
    subtitle: "Current installed version",
    icon: "info.circle.fill",
    tint: .secondary
)
```

### SFKSettingsToggle (Boolean)

```swift
@AppStorage("notifications") private var notificationsEnabled = true

SFKSettingsToggle(
    title: "Push Notifications",
    subtitle: "Receive push notifications",
    icon: "bell.badge",
    tint: .blue,
    isOn: $notificationsEnabled
)
```

### SFKSettingsToggleRow (SettingsItem-based)

```swift
enum MyToggleItem: SettingsItem {
    case enabled
    var id: String { "enabled" }
    var icon: String { "power" }
    var title: String { "Enabled" }
    var subtitle: String { "Turn on/off feature" }
    var tint: Color { .green }
}

SFKSettingsToggleRow(item: MyToggleItem(), isOn: $isEnabled)
```

### SFKSettingsDatePickerRow (Sheet-based)

```swift
@State private var reminderDate = Date()

SFKSettingsDatePickerRow(
    title: "Reminder Date",
    subtitle: "When to send the reminder",
    icon: "calendar",
    tint: .orange,
    selection: $reminderDate,
    displayedComponents: [.date]  // or [.hourAndMinute] for time only
)
```

### SFKSettingsTimePickerRow

```swift
@State private var alarmTime = Date()

SFKSettingsTimePickerRow(
    title: "Alarm Time",
    subtitle: "When to trigger the alarm",
    icon: "clock.fill",
    tint: .red,
    selection: $alarmTime
)
```

### SFKSettingsInlineDatePicker

```swift
@State private var startDate = Date()

SFKSettingsInlineDatePicker(
    title: "Start Date",
    icon: "calendar.badge.plus",
    tint: .blue,
    selection: $startDate,
    displayedComponents: [.date]
)
```

### SFKSettingsStepperRow (Numeric)

```swift
@State private var alertCount = 3

SFKSettingsStepperRow(
    title: "Number of Alerts",
    subtitle: "How many times to remind",
    icon: "bell.badge",
    tint: .red,
    value: $alertCount,
    range: 1...10,
    step: 1,
    displayValue: { "\($0) times" }
)
```

### SFKSettingsSliderRow (Continuous)

```swift
@State private var opacity: Double = 0.5

SFKSettingsSliderRow(
    title: "Image Opacity",
    subtitle: "Adjust transparency",
    icon: "circle.lefthalf.filled",
    tint: .blue,
    value: $opacity,
    range: 0...1,
    step: 0.01,
    displayValue: { "\(Int($0 * 100))%" }
)
```

### SFKSettingsColorPickerRow (Sheet-based)

```swift
@State private var themeColor = Color.blue

SFKSettingsColorPickerRow(
    title: "Theme Color",
    subtitle: "Choose your preferred color",
    icon: "paintpalette",
    tint: .purple,
    selection: $themeColor
)
```

### SFKSettingsInlineColorPicker

```swift
@State private var accentColor = Color.purple

SFKSettingsInlineColorPicker(
    title: "Accent Color",
    icon: "paintbrush.fill",
    tint: .purple,
    selection: $accentColor
)
```

### SFKSettingsLinkRow (External URL)

```swift
SFKSettingsLinkRow(
    title: "Privacy Policy",
    subtitle: "Read our privacy policy",
    icon: "hand.raised.fill",
    tint: .blue,
    url: URL(string: "https://example.com/privacy")!
)
```

### SFKSettingsDestructiveRow (Dangerous Action)

```swift
SFKSettingsDestructiveRow(
    title: "Delete Account",
    subtitle: "Permanently delete your account and all data",
    icon: "trash.fill",
    action: {
        // Handle deletion
    }
)
```

### SFKSettingsConfirmationRow (Confirm Dialog)

```swift
SFKSettingsConfirmationRow(
    title: "Reset All Data",
    subtitle: "Clear all app data and settings",
    icon: "exclamationmark.triangle.fill",
    tint: .orange,
    confirmationTitle: "Reset Data?",
    confirmationMessage: "This action cannot be undone. All your data will be permanently deleted.",
    confirmTitle: "Reset",
    confirmStyle: .destructive
) {
    // Reset data
}
```

---

## Complete Sample Settings Screen

This example demonstrates a settings screen with **all row types**:

```swift
import SwiftUI
import SwapFoundationKit

struct MyAppSettingsView: View {
    // Toggle state
    @AppStorage("notifications") private var notificationsEnabled = true
    @AppStorage("darkMode") private var darkModeEnabled = false

    // Date/Time state
    @State private var reminderDate = Date()
    @State private var alarmTime = Date()

    // Numeric state
    @State private var alertCount = 3
    @State private var opacity: Double = 0.75

    // Color state
    @State private var themeColor = Color.blue

    // Picker state
    @State private var selectedLanguage = "en"

    var body: some View {
        NavigationStack {
            Form {
                // MARK: - Custom Header Section
                Section {
                    // Header content like a pro banner
                    VStack(alignment: .leading, spacing: 8) {
                        Text("MyApp Settings")
                            .font(.title2.bold())
                        Text("Customize your experience")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 8)
                }

                // MARK: - Toggle Section
                Section {
                    SFKSettingsToggle(
                        title: "Push Notifications",
                        subtitle: "Receive notifications for updates",
                        icon: "bell.badge.fill",
                        tint: .blue,
                        isOn: $notificationsEnabled
                    )

                    SFKSettingsToggle(
                        title: "Dark Mode",
                        subtitle: "Use dark appearance",
                        icon: "moon.fill",
                        tint: .purple,
                        isOn: $darkModeEnabled
                    )
                } header: {
                    Text("Preferences")
                }

                // MARK: - Date/Time Pickers
                Section {
                    SFKSettingsDatePickerRow(
                        title: "Reminder Date",
                        subtitle: "When to send the reminder",
                        icon: "calendar",
                        tint: .orange,
                        selection: $reminderDate,
                        displayedComponents: [.date]
                    )

                    SFKSettingsTimePickerRow(
                        title: "Alarm Time",
                        subtitle: "When to trigger the alarm",
                        icon: "clock.fill",
                        tint: .red,
                        selection: $alarmTime
                    )

                    SFKSettingsInlineDatePicker(
                        title: "Start Date",
                        icon: "calendar.badge.plus",
                        tint: .green,
                        selection: $reminderDate,
                        displayedComponents: [.date]
                    )
                } header: {
                    Text("Date & Time")
                }

                // MARK: - Numeric Controls
                Section {
                    SFKSettingsStepperRow(
                        title: "Alert Count",
                        subtitle: "Number of reminders",
                        icon: "bell.badge",
                        tint: .red,
                        value: $alertCount,
                        range: 1...10,
                        step: 1,
                        displayValue: { "\($0) times" }
                    )

                    SFKSettingsSliderRow(
                        title: "Opacity",
                        subtitle: "Adjust transparency",
                        icon: "circle.lefthalf.filled",
                        tint: .blue,
                        value: $opacity,
                        range: 0...1,
                        step: 0.01,
                        displayValue: { "\(Int($0 * 100))%" }
                    )
                } header: {
                    Text("Adjustments")
                }

                // MARK: - Color Picker
                Section {
                    SFKSettingsColorPickerRow(
                        title: "Theme Color",
                        subtitle: "Choose app color",
                        icon: "paintpalette.fill",
                        tint: .purple,
                        selection: $themeColor
                    )

                    SFKSettingsInlineColorPicker(
                        title: "Accent Color",
                        icon: "paintbrush.fill",
                        tint: themeColor,
                        selection: $themeColor
                    )
                } header: {
                    Text("Appearance")
                }

                // MARK: - Standard Information Items
                Section {
                    ForEach(SFKInformationSectionItem.allCases, id: \.id) { item in
                        SFKSettingsRow(item: item) {
                            handleInfoItemTap(item)
                        }
                    }
                } header: {
                    Text("Information")
                } footer: {
                    Text("Thank you for using MyApp!")
                }

                // MARK: - Developer Section
                Section {
                    ForEach(SFKDeveloperSectionItem.allCases, id: \.id) { item in
                        SFKSettingsRow(item: item) {
                            handleDeveloperItemTap(item)
                        }
                    }
                } header: {
                    Text("Developer")
                }

                // MARK: - Link Row
                Section {
                    SFKSettingsLinkRow(
                        title: "Documentation",
                        subtitle: "Read the full documentation",
                        icon: "book.fill",
                        tint: .green,
                        url: URL(string: "https://example.com/docs")!
                    )
                }

                // MARK: - Destructive Actions
                Section {
                    SFKSettingsConfirmationRow(
                        title: "Reset All Settings",
                        subtitle: "Return all settings to default values",
                        icon: "arrow.counterclockwise",
                        tint: .orange,
                        confirmationTitle: "Reset Settings?",
                        confirmationMessage: "This will reset all your preferences to their default values.",
                        confirmTitle: "Reset",
                        confirmStyle: .destructive
                    ) {
                        resetSettings()
                    }

                    SFKSettingsDestructiveRow(
                        title: "Delete Account",
                        subtitle: "Permanently delete your account and all data",
                        icon: "trash.fill",
                        action: {
                            deleteAccount()
                        }
                    )
                } header: {
                    Text("Danger Zone")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func handleInfoItemTap(_ item: SFKInformationSectionItem) {
        // Handle information items
    }

    private func handleDeveloperItemTap(_ item: SFKDeveloperSectionItem) {
        // Handle developer items
    }

    private func resetSettings() {
        // Reset all settings
    }

    private func deleteAccount() {
        // Delete account
    }
}
```

---

## Full Settings Screen with SFKSettingsScreen

Alternatively, use `SFKSettingsScreen` for a structured approach:

```swift
import SwiftUI
import SwapFoundationKit

struct MySettingsView: View {
    @State private var notificationsEnabled = true
    @State private var reminderDate = Date()

    private let actionHandler = SFKSettingsActionHandler(appID: "123456789")

    var body: some View {
        SFKSettingsScreen(
            header: {
                // Custom header like a pro banner
                VStack(alignment: .leading, spacing: 8) {
                    Text("MyApp Pro")
                        .font(.title2.bold())
                    Text("Upgrade for premium features")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding()
            },
            sections: [
                // Preferences with toggle
                SFKSettingsSectionConfiguration(
                    title: "Preferences",
                    items: []
                ),

                // Information section
                SFKSettingsSectionConfiguration(
                    title: "Information",
                    items: SFKInformationSectionItem.allCases,
                    footer: "Version 1.0.0 (100)"
                ),

                // Developer section
                SFKSettingsSectionConfiguration(
                    title: "Developer",
                    items: SFKDeveloperSectionItem.allCases
                )
            ],
            onItemTap: { item in
                handleItemTap(item)
            }
        )
    }

    private func handleItemTap(_ item: any SettingsItem) {
        if let infoItem = item as? SFKInformationSectionItem {
            switch infoItem {
            case .rateOnTheAppStore:
                actionHandler.rateOnTheAppStore()
            case .privacyPolicy:
                actionHandler.openURLString("https://example.com/privacy")
            case .termsAndConditions:
                actionHandler.openURLString("https://example.com/terms")
            default:
                break
            }
        }
    }
}
```

---

## Standard Section Items

### SFKInformationSectionItem

| Case | Icon | Title | Tint |
|------|------|-------|------|
| `.version` | `info.circle.fill` | Version | `.secondary` |
| `.reportABug` | `ant.circle.fill` | Report a Bug | `.orange` |
| `.rateOnTheAppStore` | `star.circle.fill` | Rate on the App Store | `.yellow` |
| `.referToFriends` | `person.2.circle` | Refer to Friends | `.pink` |
| `.privacyPolicy` | `globe` | Privacy Policy | `.blue` |
| `.termsAndConditions` | `globe` | Terms and Conditions | `.blue` |

### SFKDeveloperSectionItem

| Case | Icon | Title | Tint |
|------|------|-------|------|
| `.website` | `globe` | Website | `.blue` |
| `.twitter` | `heart.circle` | Twitter (X) | `.purple` |
| `.anotherApp` | `heart.circle.fill` | View Another App | `.pink` |

---

## Action Handlers

### SFKSettingsActionHandler

```swift
let handler = SFKSettingsActionHandler(appID: "123456789")

handler.rateOnTheAppStore()

handler.shareApp(
    shareText: "Check out this great app!",
    appURL: URL(string: "https://apps.apple.com/app/id123456789")!
)

handler.openURL(URL(string: "https://example.com")!)
```

### SFKInformationSectionHandler

```swift
let handler = SFKSettingsActionHandler(appID: "123456789")

let infoHandler = SFKInformationSectionHandler(
    handler: handler,
    privacyPolicyURL: URL(string: "https://myapp.com/privacy"),
    termsURL: URL(string: "https://myapp.com/terms")
)

// In your tap handler:
if infoHandler.handle(item) {
    // Item was handled (rate app, open URL, etc.)
    // Return early
}
```

### SFKDeveloperSectionHandler

```swift
let handler = SFKSettingsActionHandler(appID: "123456789")

let devHandler = SFKDeveloperSectionHandler(
    handler: handler,
    websiteURL: URL(string: "https://myapp.com"),
    twitterURL: URL(string: "https://twitter.com/myapp")
)

// In your tap handler:
if devHandler.handle(item) {
    // Item was handled
}
```

---

## 🚀 Quick Start

### Initial Setup

```swift
import SwapFoundationKit

@main
struct MyApp: App {
    init() {
        // Configure SwapFoundationKit
        let config = SwapFoundationKitConfiguration(
            appMetadata: AppMetaData(
                appGroupIdentifier: "group.com.yourapp.widget",
                appName: "MyApp",
                appVersion: "1.0.0"
            ),
            enableWatchConnectivity: true,
            watchSyncOptions: WatchSyncOptions(
                preferredTransport: .applicationContext,
                fallbackOrder: [.userInfo, .messageData, .file]
            ),
            enableAnalytics: true,
            enableItemSync: true,
            enableNetworking: true,
            networkTimeout: 30.0
        )
        
        Task {
            try? await SwapFoundationKit.shared.start(with: config)
            
            // Start exchange rate manager
            await ExchangeRateManager.shared.start()
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

---

## 📚 Complete API Reference

### Core Services
- **`SwapFoundationKit`** - Main framework entry point
- **`SwapFoundationKitConfiguration`** - Configuration struct
- **`HTTPClient`** - Modern HTTP client with async/await
- **`NetworkService`** - Network operations and reachability
- **`SecurityService`** - Encryption, keychain, secure storage
- **`BackupService`** - Data backup and restore

### UI Components
- **`SFKButton`** - Unified enum-driven button API for primary, secondary, inline, pill, toolbar, and close variants
- **`SFKButtonVisualTokens`** - Host-app override point for shared button corner radii and foreground colors
- **`SFKPrimaryButton`** - Compatibility wrapper for primary actions
- **`SFKSecondaryButton`** - Compatibility wrapper for secondary actions
- **`SFKInlineButton`** - Compatibility wrapper for inline actions
- **`SFKPillButton`** - Compatibility wrapper for pill/capsule actions
- **`SFKClosePillButton`** - Compatibility wrapper for close/dismiss pill actions
- **`SFKToolbarButton`** - Compatibility wrapper for toolbar actions and custom labels

### Glass Button Modifiers
- **`.glassButton()`** - Rounded rectangle glass effect
- **`.glassCapsuleButton()`** - Capsule/pill glass effect
- **`.glassCircleButton()`** - Circular glass effect

### Utilities
- **`HapticsHelper`** - Haptic feedback manager
- **`Logger`** - Configurable logging with analytics integration
- **`Debouncer`** - Action debouncing utility
- **`ImageProcessor`** - Image manipulation and caching
- **`ExchangeRateManager`** - Currency exchange rates
- **`Currency`** - Currency enum with symbols
- **`AnalyticsManager`** - Protocol-based analytics system
- **`AppLinkOpener`** - URL and app link opening

### Alert Presentation
- **`AlertController`** - SwiftUI-native ObservableObject for declarative alert management
- **`AlertPresenter`** - Static methods for UIKit-based alert presentation
- **`AlertAction`** - Represents an action in an alert
- **`AlertActionStyle`** - Action style enum (`.default`, `.cancel`, `.destructive`)
- **`AlertTextField`** - Text field configuration for alerts
- **`KeyboardType`** - Platform-agnostic keyboard type enum

### Settings UI
- **`SettingsItem`** - Protocol defining a settings row contract
- **`SFKSettingsRow`** - Tappable row with icon, title, subtitle, chevron, and custom trailing
- **`SFKSettingsLabel`** - Display-only label row variant
- **`SFKSettingsToggle`** - Toggle row with icon, title, subtitle (explicit properties)
- **`SFKSettingsToggleRow`** - Toggle row with icon, title, subtitle (SettingsItem-based)
- **`SFKSettingsDatePickerRow`** - Date/time picker presented in a sheet
- **`SFKSettingsTimePickerRow`** - Time picker presented in a sheet
- **`SFKSettingsInlineDatePicker`** - Date/time picker inline within form
- **`SFKSettingsStepperRow`** - Numeric stepper row with +/- controls
- **`SFKSettingsSliderRow`** - Slider row for continuous values
- **`SFKSettingsColorPickerRow`** - Color picker presented in a sheet
- **`SFKSettingsInlineColorPicker`** - Color picker inline within form
- **`SFKSettingsLinkRow`** - Opens external URL
- **`SFKSettingsDestructiveRow`** - Destructive action row (red styling)
- **`SFKSettingsConfirmationRow`** - Row with confirmation dialog before action
- **`SFKSettingsScreen`** - Full settings screen with sections, headers, and footers
- **`SFKSettingsSectionConfiguration`** - Section configuration with title, items, and optional footer
- **`SFKInformationSectionItem`** - Standard info section items (version, report bug, rate app, share, privacy, terms)
- **`SFKDeveloperSectionItem`** - Developer section items (website, twitter, another app)
- **`SFKSettingsActionHandler`** - Helper for rate app, share, open URLs
- **`SFKInformationSectionHandler`** - Handler for SFKInformationSectionItem taps
- **`SFKDeveloperSectionHandler`** - Handler for SFKDeveloperSectionItem taps

### Item Picker
- **`SFKPickableItem`** - Protocol for items displayed in the picker
- **`SFKPickableItemIconKind`** - Icon display modes (`.iconImage`, `.systemIcon`, `.text`, `.none`)
- **`SFKItemPickerSelectionMode`** - Selection mode enum (`.single`, `.multi`)
- **`SFKItemPickerView`** - Generic picker view with NavigationStack and close button
- **`SFKItemPickerRow`** - Individual row with icon, title, subtitle, checkmark, and haptics

### Extensions
- **`Date`** - Comprehensive date formatting and manipulation
- **`String`** - String validation, manipulation, and conversion
- **`Double`/`Float`** - Number formatting utilities
- **`Data`** - Crypto hashing (MD5, SHA1, SHA256)
- **`Bundle`** - Info.plist access utilities
- **`Collection`** - Safe subscript and utilities
- **`UIColor`** - Hex colors, color manipulation
- **`UIView`** - Layout and hierarchy utilities
- **`UIImage`** - Image resizing utilities

### Property Wrappers
- **`@UserDefault`** - Type-safe UserDefaults with SwiftUI support

### Modules
- **`ItemSync`** - Data synchronization between app, widgets, and Watch
- **`WatchSyncService`** - Type-safe watch transport abstraction with envelope-based payloads
- **`WatchSyncEnvelope`** - Canonical watch payload format (identifier + payload + version)
- **`WatchSyncOptions`** - Transport preference/fallback configuration

---

## 🏗️ Architecture

SwapFoundationKit is built with these principles:

- **Protocol-Oriented Design** - Easy to implement, test, and extend
- **Modern Swift Features** - Leverages async/await, actors, and Swift concurrency
- **Type Safety** - Compile-time safety with generics and protocols
- **Modular Structure** - Import only what you need
- **Comprehensive Testing** - Well-tested components with mock support

---

## 🔧 Configuration

### App Groups (for ItemSync)

To use ItemSync with widgets, add App Groups capability to your app:

1. Select your target in Xcode
2. Go to **Signing & Capabilities**
3. Click **+ Capability**
4. Add **App Groups**
5. Create a group identifier (e.g., `group.com.yourapp.widget`)

### Firebase Analytics

1. Add Firebase to your project
2. Import `FirebaseAnalytics`
3. Create a logger conforming to `AnalyticsLogger` protocol
4. Add it to `AnalyticsManager.shared`

---

## 🧪 Testing

The package includes test coverage for core utilities. This library targets **iOS** and depends on UIKit-based packages, so **`swift test` on macOS often fails** (UIKit is not available for the default macOS triple).

Run tests from the package root with Xcode’s iOS Simulator destination, for example:

```bash
cd /path/to/SwapFoundationKit
xcodebuild test -scheme SwapFoundationKit -destination 'platform=iOS Simulator,name=iPhone 17'
```

If you open `Package.swift` in Xcode, you can also run the **SwapFoundationKit** test action from the UI.

### Mock Objects

Many components include mock implementations for testing:

```swift
// Mock analytics logger for testing
class MockAnalyticsLogger: AnalyticsLogger {
    private(set) var loggedEvents: [(event: AnalyticsEvent, parameters: [String: String]?)] = []
    
    func logEvent(event: AnalyticsEvent, additionalParameters: [String: String]?) {
        loggedEvents.append((event: event, parameters: additionalParameters))
    }
}
```

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- **ECB** for providing exchange rate data
- **Apple** for the excellent Swift language and frameworks
- **Community** for feedback and contributions

---

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/SwapnanilDhol/SwapFoundationKit/issues)
- **Discussions**: [GitHub Discussions](https://github.com/SwapnanilDhol/SwapFoundationKit/discussions)
- **Email**: swapnanildhol@gmail.com

---

**Made with ❤️ by [Swapnanil Dhol](https://github.com/SwapnanilDhol)**
