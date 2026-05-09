# SwapFoundationKit

A comprehensive Swift package providing essential utilities, extensions, UI components, and services for iOS development. Built with modern Swift features and designed for developer productivity and cross-app consistency.

## Quick Navigation

| Section | Description |
|---------|-------------|
| [Requirements](#requirements) | Platform and tooling requirements |
| [Installation](#installation) | SPM setup instructions |
| [Quick Start](#quick-start) | Framework initialization |
| [Host App Audit](#host-app-audit) | How to audit your app for redundant implementations |
| [Capabilities Checklist](#capabilities-checklist) | Every capability as a migration checklist item |
| [API Reference](#api-reference) | Complete API summary |
| [Architecture](#architecture) | Design principles |
| [Testing](#testing) | How to run tests |
| [Support](#support) | Issues, discussions, contact |

---

## Requirements

- **iOS**: 17.0+
- **Swift**: 5.9+
- **Xcode**: 15.0+
- **Dependencies**: Google Mobile Ads (13.1.0), Toast-Swift (2.1.3), UpdateAvailableKit (2.0.0+)

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
]
```

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
            watchSyncOptions: WatchSyncOptions(
                preferredTransport: .applicationContext,
                fallbackOrder: [.userInfo, .messageData, .file]
            ),
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

## Host App Audit

If you want an LLM or code-review agent to audit a host app for overlap with SwapFoundationKit, use `Docs/host-app-audit-catalog.yaml` as the source of truth. The catalog lists every public capability and marks each as `exact`, `heuristic`, or `manual` to keep audits useful instead of noisy.

### Audit Workflow

1. **Start with `exact` tier only** — least noisy, highest confidence.
2. **Review `replace` findings** and migrate one capability at a time.
3. **Run app tests** after each migration.
4. **Expand to `heuristic` tier** after obvious overlaps are removed.
5. **Use `manual` tier last** for generic extensions where naming overlap alone is not enough.

### Agent Prompt

```text
Use /path/to/SwapFoundationKit/Docs/host-app-audit-catalog.yaml as the source of truth.

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

See `Docs/AGENTS.md` for the full LLM agent workflow documentation.

---

## Capabilities Checklist

**Migration principle**: If your app already has an implementation for any capability below, replace it with SwapFoundationKit's implementation. This modularizes your codebase and ensures consistency across your app ecosystem.

Each item below is a self-contained migration unit. Work through them in order, starting with `exact` tier items.

---

### 1. Haptics Manager

**Tier**: `exact` · **Confidence**: high

Replace custom haptics/feedback classes with `HapticsHelper`.

**Source**: `Sources/SwapFoundationKit/Services/HapticsHelper.swift`

**Search your app for**: `Haptic`, `Feedback`, `UIImpactFeedbackGenerator`, `UINotificationFeedbackGenerator`, `UISelectionFeedbackGenerator`

**Suspicious file patterns**: `*Haptic*`, `*Feedback*`

**API**:

```swift
import SwapFoundationKit

let haptics = HapticsHelper()

haptics.lightImpact()
haptics.mediumImpact()
haptics.heavyImpact()
haptics.successNotification()
haptics.warningNotification()
haptics.errorNotification()
haptics.customImpact(intensity: 0.8)
```

**Migration steps**:
1. Search for custom haptics/feedback classes.
2. Replace all instances with `HapticsHelper()`.
3. Update method calls to match the API above.
4. Remove your custom implementation.

**Keep custom when**: The host app intentionally abstracts non-Apple feedback backends or cross-platform behavior.

---

### 2. Logger / Logging System

**Tier**: `exact` · **Confidence**: high

Replace custom logger classes with `Logger`.

**Source**: `Sources/SwapFoundationKit/Services/Logger.swift`

**Search your app for**: `Logger`, `LogManager`, `LogService`, `os_log`, `OSLog`, `printLog`

**Suspicious file patterns**: `*Logger*`, `*Log*`

**API**:

```swift
import SwapFoundationKit

Logger.info("User signed in successfully")
Logger.debug("Processing request...")
Logger.warning("API rate limit approaching")
Logger.error("Failed to load user data")

// Configure global logging level
Logger.minimumLevel = .info

// Enable automatic analytics integration for errors
await Logger.setSendAnalyticsOnError(true)
```

**Migration steps**:
1. Find all references to your custom logger.
2. Replace with `Logger.info()`, `Logger.debug()`, `Logger.warning()`, `Logger.error()`.
3. Remove your custom logger implementation.
4. The SDK's logger automatically integrates with analytics when configured.

**Keep custom when**: The host app needs a structured logging backend or remote log sink that SFK does not provide.

---

### 3. Analytics Manager / Event Tracking

**Tier**: `exact` · **Confidence**: high

Replace custom analytics managers with `AnalyticsManager` and its protocol-based fan-out system.

**Source**: `Sources/SwapFoundationKit/Services/AnalyticsProtocol.swift`

**Search your app for**: `AnalyticsManager`, `AnalyticsService`, `Telemetry`, `trackEvent`, `logEvent`, `Mixpanel`, `FirebaseAnalytics`

**Suspicious file patterns**: `*Analytics*`, `*Telemetry*`, `*Tracking*`

**API**:

```swift
import SwapFoundationKit

// Define your analytics events
enum AppEvent: AnalyticsEvent {
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

// Create a logger (e.g., Firebase)
class FirebaseAnalyticsLogger: AnalyticsLogger {
    func logEvent(event: AnalyticsEvent, additionalParameters: [String: String]?) {
        var params: [String: Any] = [:]
        if let p = additionalParameters {
            for (key, value) in p { params[key] = value }
        }
        // Analytics.logEvent(event.rawValue, parameters: params)
    }
}

// Setup
let analyticsManager = AnalyticsManager.shared
analyticsManager.addLogger(FirebaseAnalyticsLogger())
analyticsManager.setGlobalParameters([
    "app_version": "1.0.0",
    "platform": "ios"
])

// Use throughout your app
AnalyticsManager.shared.logEvent(event: AppEvent.userSignedIn(userId: "user123"))
AnalyticsManager.shared.logEvent(event: .viewScreen(screenName: "home"), parameters: ["source": "push"])
```

**Parameter merge precedence** in `logEvent(event:parameters:)`:
1. `event.parameters` (lowest)
2. Global parameters (`setGlobalParameters`)
3. Call-site `parameters` argument (highest)

Use `clearGlobalParameters()` when you need to stop injecting shared metadata (e.g., after logout).

**Migration steps**:
1. Find your custom analytics manager/tracker.
2. Create event enums conforming to `AnalyticsEvent`.
3. Create logger classes conforming to `AnalyticsLogger`.
4. Replace all analytics calls with `AnalyticsManager.shared.logEvent()`.
5. Remove your custom analytics implementation.

**Keep custom when**: The host app uses a higher-level domain analytics facade; SFK should sit underneath it as the provider fan-out layer.

---

### 4. UserDefaults Wrapper / Type-Safe UserDefaults

**Tier**: `exact` · **Confidence**: high

Replace UserDefaults wrappers with `@UserDefault` property wrapper.

**Sources**: `Sources/SwapFoundationKit/Services/UserDefault.swift`, `Sources/SwapFoundationKit/Services/UserDefaults+.swift`

**Search your app for**: `UserDefaultsManager`, `PreferencesStore`, `@AppStorage`, `DefaultsKey`, `PropertyListEncoder`

**Suspicious file patterns**: `*UserDefault*`, `*UserDefaults*`, `*Preference*`, `*SettingsStore*`

**API**:

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

**Migration steps**:
1. Identify your UserDefaults wrapper/helper classes.
2. Create a key enum conforming to `UserDefaultKeyProtocol`.
3. Replace property declarations with `@UserDefault` wrapper.
4. Remove your custom UserDefaults implementation.

**Keep custom when**: The host app needs migration, encryption, or cross-process semantics that go beyond type-safe defaults access.

---

### 5. Network Client / HTTP Client / API Service

**Tier**: `exact` · **Confidence**: high

Replace custom network clients with `HTTPClient` (modern async/await) or `NetworkService` (reachability + basic HTTP).

**Sources**: `Sources/SwapFoundationKit/Core/Networking.swift`, `Sources/SwapFoundationKit/Core/NetworkService.swift`

**Search your app for**: `APIClient`, `NetworkManager`, `NetworkService`, `URLSession`, `Endpoint`, `HTTPClient`, `Alamofire`

**Suspicious file patterns**: `*APIClient*`, `*Network*`, `*Endpoint*`, `*HTTP*`

#### Option A: HTTPClient (Modern async/await)

```swift
import SwapFoundationKit

// Initialize in your app configuration
let config = SwapFoundationKitConfiguration(
    appMetadata: AppMetaData(appGroupIdentifier: "group.com.example.app"),
    enableNetworking: true,
    networkTimeout: 30.0,
    networkLogLevel: .debug
)

try await SwapFoundationKit.shared.start(with: config)

// Get the HTTP client
guard let client = SwapFoundationKit.shared.networkClient else { return }

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

// Network logs use SFK's built-in Logger
// `.debug` dumps request/response headers and bodies with sensitive headers redacted
```

#### Option B: NetworkService (Reachability + Basic HTTP)

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

**Migration steps**:
1. Identify your custom network/API client classes.
2. Replace with `HTTPClient` for modern async/await or `NetworkService` for reachability.
3. Update all network calls to use the new API.
4. Remove your custom network implementation.

**Keep custom when**: The host app has auth-refresh, request-signing, or middleware requirements that should remain in an app-level facade above SFK.

---

### 6. Security Service / Encryption / Keychain Manager

**Tier**: `exact` · **Confidence**: high

Replace custom security/encryption/keychain classes with `SecurityService`.

**Sources**: `Sources/SwapFoundationKit/Core/SecurityService.swift`, `Sources/SwapFoundationKit/Extensions/Data+Crypto.swift`

**Search your app for**: `Keychain`, `SecureStore`, `EncryptionService`, `CryptoKit`, `SHA256`, `AES`

**Suspicious file patterns**: `*Security*`, `*Keychain*`, `*Crypto*`, `*Encrypt*`

**API**:

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

**Migration steps**:
1. Find your custom security/encryption/keychain classes.
2. Replace with `SecurityService()`.
3. Update all security operations to use the new API.
4. Remove your custom security implementation.

**Keep custom when**: The host app must satisfy platform, compliance, or shared-secret rules that require its own security boundary.

---

### 7. Backup Service / Data Export

**Tier**: `exact` · **Confidence**: medium

Replace custom backup/export services with `BackupService`.

**Source**: `Sources/SwapFoundationKit/Core/BackupService.swift`

**Search your app for**: `BackupManager`, `ExportService`, `ImportService`, `restoreBackup`, `exportData`

**Suspicious file patterns**: `*Backup*`, `*Export*`, `*Import*`

**API**:

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

// Restore the newest on-device backup
let restoredData = try backupService.restoreBackup(UserData.self, fileType: .data)

// List backup files (newest first)
let backupFiles = backupService.listBackupFiles(for: .data)
```

**On-disk layout**: Each `FileType` writes under `Documents/<rawValue>/` (e.g., `Documents/data/`) as timestamped `*.backup` files containing one JSON-encoded payload. `restoreBackup` reads the newest file in that folder. Filenames use second-level timestamps, so two backups within the same clock second share one filename and the second write replaces the first.

**Unit tests**: `BackupService` supports an optional documents root override:

```swift
let tempRoot = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString)
let backupService = BackupService(documentsDirectoryOverride: tempRoot)
```

**Migration steps**:
1. Find your custom backup/export classes.
2. Replace with `BackupService()`.
3. Update backup/restore calls.
4. Remove your custom backup implementation.

**Keep custom when**: The host app owns a domain-specific export format or cloud backup flow.

---

### 8. Currency Converter / Exchange Rate Manager

**Tier**: `exact` · **Confidence**: medium

Replace custom currency/exchange rate classes with `ExchangeRateManager` and `Currency`.

**Sources**: `Sources/SwapFoundationKit/Currency/Currency.swift`, `Sources/SwapFoundationKit/Currency/ExchangeRateManager.swift`

**Search your app for**: `CurrencyConverter`, `ExchangeRate`, `Forex`, `currencySymbol`, `NumberFormatter.currency`

**Suspicious file patterns**: `*Currency*`, `*ExchangeRate*`, `*Forex*`

**API**:

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
print(currency.symbol)          // 🇺🇸
print(currency.currencySymbol)  // $
print(currency.description)     // "US Dollar"
```

**Migration steps**:
1. Find your custom currency/exchange rate classes.
2. Replace with `ExchangeRateManager.shared` and `Currency` enum.
3. Update all currency operations.
4. Remove your custom currency implementation.

**Keep custom when**: The host app depends on a paid provider, custom cache policy, or accounting-specific rounding rules.

---

### 9. Image Processor / Image Utilities

**Tier**: `exact` · **Confidence**: medium

Replace custom image processing/caching classes with `ImageProcessor`.

**Source**: `Sources/SwapFoundationKit/ImageProcessor/ImageProcessor.swift`

**Search your app for**: `ImageProcessor`, `ImageCache`, `resizeImage`, `blurImage`, `roundCorners`, `grayscale`

**Suspicious file patterns**: `*ImageProcessor*`, `*ImageCache*`, `*ImageUtils*`

**API**:

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

**Migration steps**:
1. Find your custom image processing/caching classes.
2. Replace with `ImageProcessor.shared`.
3. Update all image operations.
4. For remote URL caching, use `cacheImage(from:targetSize:)` and `cachedImage(from:targetSize:)`.
5. For widget/extension sharing, configure with `configure(shouldCacheToSharedStorage:appGroupIdentifier:)`.
6. Remove your custom image implementation.

**Keep custom when**: The host app relies on a third-party image pipeline with networking, decoding, and animated image support.

---

### 10. Debouncer / Throttler

**Tier**: `exact` · **Confidence**: medium

Replace custom debouncer/throttler classes with `Debouncer`.

**Sources**: `Sources/SwapFoundationKit/Utilities/Debouncer.swift`, `Sources/SwapFoundationKit/Utilities/Throttler.swift`

**Search your app for**: `Debouncer`, `debounce`, `DispatchWorkItem`, `searchDelay`

**Suspicious file patterns**: `*Debouncer*`, `*Search*`, `*Throttle*`

**API**:

```swift
import SwapFoundationKit

let debouncer = Debouncer(delay: 0.5)

// Debounce search input
debouncer.call {
    performSearch(query: searchText)
}
```

**Migration steps**:
1. Find your custom debouncer/throttler classes.
2. Replace with `Debouncer(delay:)`.
3. Update all debounced operations.
4. Remove your custom debouncer implementation.

**Keep custom when**: The host app specifically needs throttling semantics; SFK's `Throttler` is currently internal and should not be used as a public replacement target.

---

### 11. Date Utilities / Date Formatters

**Tier**: `manual` · **Confidence**: low

Replace custom date utilities with `Date` extensions.

**Source**: `Sources/SwapFoundationKit/Extensions/Date+Extensions.swift`

**Search your app for**: `extension Date`, date formatter helpers, relative time formatters

**Suspicious file patterns**: `*Date+*`

**API**:

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

// Creation
let specificDate = Date.from(year: 2024, month: 1, day: 15)
```

**Additional APIs**: `startOfMonth`, `endOfMonth`, `startOfYear`, `isWeekend`, `daysInMonth`, `workingDays(until:)`, `quarter`, `isInCurrentYear`

**Migration steps**:
1. Find your custom date utility/formatter classes.
2. Replace with `Date` extension methods.
3. Update all date operations.
4. Remove your custom date implementation.

**Keep custom when**: The host app's extensions are domain-specific, naming-specific, or intentionally narrower than the generic SFK helpers.

---

### 12. String Utilities / String Extensions

**Tier**: `manual` · **Confidence**: low

Replace custom string utilities with `String` extensions.

**Source**: `Sources/SwapFoundationKit/Extensions/String+.swift`

**Search your app for**: `extension String`, string validation, sanitization helpers

**Suspicious file patterns**: `*String+*`

**API**:

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
print(string.isValidURL)         // false
print(string.isValidPhoneNumber) // false
print(string.isValidCreditCard)  // false
print(string.isValidDecimal)     // false

// Manipulation
print(string.trimmed)            // "Hello World"
print(string.capitalizedFirst)   // "  hello World  "
print(string.removingWhitespaces) // "HelloWorld"
print(string.withoutWhitespace)   // "HelloWorld"
print(string.truncated(to: 5))    // "Hell..."
print(string.htmlStripped)        // Strip HTML tags
print(string.levenshteinDistance(to: "other")) // Int

// Conversion
print(string.toInt)               // nil
print(string.toDouble)            // nil
print(string.boolValue)           // nil
print(string.intValue)            // nil
print(string.url)                 // URL?
print(string.data)                // Data?

// Security
print(string.sanitized)           // Safe for display
print(string.fileNameSafe)        // Safe for file names
print(string.md5)                 // MD5 hash
print(string.sha1)                // SHA1 hash
print(string.sha256)              // SHA256 hash
print(string.base64Encoded)       // Base64 string
print(string.base64Decoded)       // Decoded string

// Regex
print(string.matches(regex: "\\d+")) // Bool
print(string.matches(of: "\\d+"))    // [Match]

// Localization
print(string.localized)            // Localized string
print(string.localizedFormat("arg1", "arg2"))
```

**Migration steps**:
1. Find your custom string utility classes.
2. Replace with `String` extension properties/methods.
3. Update all string operations.
4. Remove your custom string implementation.

**Keep custom when**: The host app's extensions are domain-specific or naming-specific.

---

### 13. Number Formatting / Number Utilities

**Tier**: `manual` · **Confidence**: low

Replace custom number formatting with `Double`/`Float` extensions.

**Source**: `Sources/SwapFoundationKit/Extensions/Number+.swift`

**Search your app for**: `extension Double`, `extension Float`, number formatter helpers

**Suspicious file patterns**: `*Number+*`

**API**:

```swift
import SwapFoundationKit

let number: Double = 1234.56

// Clean formatting
print(number.clean)               // "1,234.56"
print(number.wordRepresentation)  // "one thousand two hundred thirty-four point five six"

let floatNumber: Float = 100.0
print(floatNumber.clean)          // "100"
```

**Migration steps**:
1. Find your custom number formatting classes.
2. Replace with `Double`/`Float` extension properties.
3. Update all number formatting.
4. Remove your custom number implementation.

---

### 14. Data Crypto / Hashing Utilities

**Tier**: `manual` · **Confidence**: low

Replace custom crypto/hashing utilities with `Data` extensions.

**Sources**: `Sources/SwapFoundationKit/Extensions/Data+Crypto.swift`

**Search your app for**: `extension Data`, MD5/SHA hashing on Data

**Suspicious file patterns**: `*Crypto*`, `*Hash*`

**API**:

```swift
import SwapFoundationKit

let data = "Hello World".data(using: .utf8)!

// Hashing
print(data.md5)     // MD5 hash string
print(data.sha1)    // SHA1 hash string
print(data.sha256)  // SHA256 hash string
```

**Migration steps**:
1. Find your custom crypto/hashing classes.
2. Replace with `Data` extension properties.
3. Update all hashing operations.
4. Remove your custom crypto implementation.

---

### 15. Bundle / Info.plist Access

**Tier**: `manual` · **Confidence**: low

Replace custom Info.plist access utilities with `Bundle` extensions.

**Source**: `Sources/SwapFoundationKit/Extensions/Bundle+InfoPlist.swift`

**Search your app for**: `extension Bundle`, Info.plist key accessors

**Suspicious file patterns**: `*Bundle+*`

**API**:

```swift
import SwapFoundationKit

let bundle = Bundle.main

// Access Info.plist values
print(bundle.appName)                      // App name
print(bundle.displayName)                  // Display name
print(bundle.bundleIdentifier)             // Bundle ID
print(bundle.releaseVersionNumber)         // Version
print(bundle.buildVersionNumber)           // Build number
print(bundle.urlSchemes)                   // URL schemes array

// Generic access
let customValue: String = bundle.infoPlistValue(
    forKey: "CustomKey",
    default: "default"
)
```

**Migration steps**:
1. Find your custom Info.plist access classes.
2. Replace with `Bundle` extension properties.
3. Update all Info.plist access.
4. Remove your custom bundle implementation.

---

### 16. Collection Utilities

**Tier**: `manual` · **Confidence**: low

Replace custom collection utilities with `Collection` extensions.

**Source**: `Sources/SwapFoundationKit/Extensions/Collection+.swift`

**Search your app for**: `extension Collection`, `extension Array`, safe subscript helpers

**Suspicious file patterns**: `*Collection+*`

**API**:

```swift
import SwapFoundationKit

let array = [1, 2, 3, 4, 5]

// Safe subscript
print(array[safe: 10])    // nil (instead of crash)
print(array.isNotEmpty)   // true

// Chunking
let chunks = array.chunked(into: 2) // [[1, 2], [3, 4], [5]]
```

**Migration steps**:
1. Find your custom collection utility classes.
2. Replace with `Collection` extension properties.
3. Update all collection operations.
4. Remove your custom collection implementation.

---

### 17. URL Extensions

**Tier**: `manual` · **Confidence**: low

Replace custom URL utilities with `URL` extensions.

**Source**: `Sources/SwapFoundationKit/Extensions/URL+Extensions.swift`

**Search your app for**: `extension URL`, query parameter helpers

**Suspicious file patterns**: `*URL+*`

**API**:

```swift
import SwapFoundationKit

let url = URL(string: "https://example.com/path?foo=bar&baz=qux")!

// Query parameters
print(url.queryParameters) // ["foo": "bar", "baz": "qux"]

// Append query item
let newURL = url.appendingQueryItem(name: "new", value: "value")

// Remove query parameters
let cleanURL = url.removingQueryParameters()

// Validate URL string
print(URL.isValid("https://example.com")) // true
```

**Migration steps**:
1. Find your custom URL utility classes.
2. Replace with `URL` extension properties/methods.
3. Update all URL operations.
4. Remove your custom URL implementation.

---

### 18. FileManager Extensions

**Tier**: `manual` · **Confidence**: low

Replace custom file manager utilities with `FileManager` extensions.

**Source**: `Sources/SwapFoundationKit/Extensions/FileManager+Extensions.swift`

**Search your app for**: `extension FileManager`, directory path helpers, file size calculators

**Suspicious file patterns**: `*FileManager+*`

**API**:

```swift
import SwapFoundationKit

let fm = FileManager.default

// Directory paths
print(fm.documentsDirectory)  // URL
print(fm.cachesDirectory)     // URL
print(fm.temporaryDirectory)  // URL

// File size
print(fm.fileSize(at: url))           // Int64
print(fm.fileSizeFormatted(at: url))  // "2.5 MB"
print(fm.directorySize(at: url))      // Int64

// Directory management
try fm.createDirectoryIfNeeded(at: url)
try fm.removeItemSafely(at: url)
```

**Migration steps**:
1. Find your custom FileManager utility classes.
2. Replace with `FileManager` extension properties/methods.
3. Update all file operations.
4. Remove your custom FileManager implementation.

---

### 19. Result Extensions

**Tier**: `manual` · **Confidence**: low

Replace custom Result utilities with `Result` extensions.

**Source**: `Sources/SwapFoundationKit/Extensions/Result+Extensions.swift`

**API**:

```swift
import SwapFoundationKit

let result: Result<String, Error> = .success("Hello")

print(result.isSuccess)   // true
print(result.isFailure)   // false
print(result.getOrElse("default"))  // "Hello"
print(result.getOrNil)    // "Hello"?
```

---

### 20. JSON Codable Helpers

**Tier**: `manual` · **Confidence**: low

Replace custom JSON encoding/decoding helpers with `JSONCodable`.

**Source**: `Sources/SwapFoundationKit/Extensions/JSON+Codable.swift`

**API**:

```swift
import SwapFoundationKit

// Encode
let data = try JSONCodable.encode(myObject, prettyPrinted: true)
let jsonString = try JSONCodable.encodeToString(myObject)

// Decode
let decoded: MyType = try JSONCodable.decode(MyType.self, from: data)

// From file
let fromFile: MyType = try JSONCodable.jsonFromFile("data.json", in: .mainBundle)
```

---

### 21. ItemSync + WatchSync / Data Synchronization

**Tier**: `exact` · **Confidence**: high

Replace custom data synchronization between app, widgets, and Watch with `ItemSync` + `WatchSync`.

**Sources**:
- `Sources/SwapFoundationKit/ItemSync/` (core + implementations)
- `Sources/SwapFoundationKit/WatchSync/` (transport abstraction)

**Search your app for**: `WidgetCenter.shared.reloadAllTimelines`, `WatchConnectivity`, `WCSession`, `App Group`, `SharedContainer`, `SyncService`

**Suspicious file patterns**: `*Sync*`, `*Widget*`, `*Watch*`, `*SharedStorage*`

**API**:

```swift
import SwapFoundationKit.ItemSync

// Define your data model
struct UserProfile: SyncableData {
    let id: String
    let name: String
    static let syncIdentifier = "user_profile"
}

// Create sync service (after SwapFoundationKit.shared.start())
let syncService = ItemSyncServiceFactory.create(appGroupIdentifier: "group.com.yourapp.widget")

// Save data (automatically syncs to widgets/extensions)
try await syncService.save(userProfile)

// Read data from anywhere in your app ecosystem
let profile = try await syncService.read(UserProfile.self)
```

**Watch transport** can be configured with `WatchSyncOptions`:

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

**WatchSync core types**:
- `WatchSyncService` — type-safe watch transport protocol
- `WatchSyncTransport` — `.applicationContext`, `.userInfo`, `.messageData`, `.file`
- `WatchSyncEnvelope` — canonical wire format (`identifier`, `payload`, `version`, `timestamp`)
- `WatchSyncOptions` — `preferredTransport`, `fallbackOrder`
- `WatchSyncEvent` — watch sync events
- `WatchSyncError` — error cases

**Migration steps**:
1. Find your custom sync/sharing classes.
2. Replace with `ItemSyncServiceFactory.create()` or `createWithWatch(..., options:)`.
3. Make your models conform to `SyncableData`.
4. Update all sync operations.
5. Remove your custom sync implementation.

**Keep custom when**: The host app has domain orchestration around sync; migrate the persistence and transport pieces first, then keep a thin app-specific wrapper.

---

### 22. App Link Opener / URL Utilities

**Tier**: `exact` · **Confidence**: medium

Replace custom URL opener/link utilities with `AppLinkOpener`.

**Sources**: `Sources/SwapFoundationKit/Services/AppLinkOpener.swift`, `Sources/SwapFoundationKit/Protocols/AppMetaData.swift`

**Search your app for**: `UIApplication.shared.open`, `openURL`, `AppStore URL`, `review URL`, `openSettingsURLString`, `MFMailCompose`

**Suspicious file patterns**: `*Link*`, `*Router*`, `*DeepLink*`, `*AppStore*`

**API**:

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

**AppMetaData** provides additional helpers:

```swift
let metadata: AppMetaData = ...
metadata.openAppReviewPage()
metadata.openWebsite("https://example.com")
```

**Migration steps**:
1. Find your custom URL/link opener classes.
2. Replace with `AppLinkOpener` static methods.
3. Update all URL opening operations.
4. Remove your custom URL opener implementation.

**Keep custom when**: The host app's router owns navigation policy and only delegates external URL handling to SFK.

---

### 23. Deeplink Handler

**Tier**: `heuristic` · **Confidence**: medium

Replace custom deeplink handling with `DeeplinkHandler`.

**Sources**:
- `Sources/SwapFoundationKit/Services/DeeplinkHandler/DeeplinkHandler.swift`
- `Sources/SwapFoundationKit/Services/DeeplinkHandler/DeeplinkEvent.swift`
- `Sources/SwapFoundationKit/Services/DeeplinkHandler/DeeplinkRoute.swift`

**API**:

```swift
import SwapFoundationKit

// Define routes
enum AppRoute: DeeplinkRoute {
    case settings
    case profile(userId: String)

    var path: String {
        switch self {
        case .settings: return "/settings"
        case .profile: return "/profile"
        }
    }

    var queryItems: [URLQueryItem] {
        switch self {
        case .profile(let userId):
            return [URLQueryItem(name: "id", value: userId)]
        default: return []
        }
    }

    static func parse(from url: URL) -> Self? {
        // Parse URL and return matching route
        return nil
    }
}

// Handle deeplinks
let handler = DefaultDeeplinkHandler(supportedRoutes: [AppRoute.self])

// Combine publisher for reactive handling
handler.deeplinkPublisher
    .sink { event in
        switch event.route {
        case .settings: // navigate to settings
        case .profile(let userId): // navigate to profile
        }
    }
    .store(in: &cancellables)
```

**DeeplinkEvent** provides: `url`, `source` (cold launch, resume, universal link, Handoff), `route`.

---

### 24. Toast Notifications

**Tier**: `exact` · **Confidence**: high

Replace custom toast/notification banner classes with `ToastManager`.

**Source**: `Sources/SwapFoundationKit/Services/ToastManager.swift`

**Search your app for**: `ToastManager`, `ToastType`, `Toast`, `import Toast`, `toast.show`, `ToastConfiguration`, `NotificationBanner`

**Suspicious file patterns**: `*Toast*`, `*NotificationBanner*`

**API**:

```swift
import SwapFoundationKit

// Define your toast kind
enum AppToast: SFKToastKind {
    case saved
    case deleted
    case error(String)

    var title: String {
        switch self {
        case .saved: return "Saved"
        case .deleted: return "Deleted"
        case .error(let msg): return "Error"
        }
    }

    var subtitle: String? {
        switch self {
        case .error(let msg): return msg
        default: return nil
        }
    }

    var style: SFKToastStyle {
        switch self {
        case .saved, .deleted: return .success
        case .error: return .error
        }
    }

    var image: UIImage? { nil }
}

// Show toast
ToastManager.shared.show(kind: AppToast.saved, config: SFKToastConfiguration(displayTime: 2.0))
```

**Migration steps**:
1. Find your custom toast/notification banner classes.
2. Create toast kinds conforming to `SFKToastKind`.
3. Replace all toast calls with `ToastManager.shared.show(kind:config:)`.
4. Remove your custom toast implementation.

**Keep custom when**: The host app uses a design-system-specific toast UI that intentionally diverges from SFK's presentation.

---

### 25. File Export / Import

**Tier**: `exact` · **Confidence**: high

Replace custom file export/import classes with `FileExportService` and `FileImportService`.

**Sources**: `Sources/SwapFoundationKit/Services/FileExportService.swift`, `Sources/SwapFoundationKit/Services/FileImportService.swift`

**Search your app for**: `UIDocumentPickerViewController`, `UIActivityViewController`, `UTType.types`, `documentPicker`, `exportSubscriptions`, `importSubscriptions`

**Suspicious file patterns**: `*FileExport*`, `*FileImport*`, `*ImportExport*`, `*DocumentPicker*`

**API**:

```swift
import SwapFoundationKit
import UniformTypeIdentifiers

// Export data
FileExportService.shared.export(
    data: jsonData,
    filename: "export.json",
    utType: UTType.json,
    from: viewController
)

// Export encodable object directly
FileExportService.shared.export(
    myObject,
    filename: "data.json",
    encoder: JSONEncoder(),
    from: viewController
)

// Import file
FileImportService.shared.importFile(
    contentTypes: [UTType.json],
    from: viewController,
    delegate: self
)

// Register custom file type
let customType = FileImportService.shared.registerCustomType(
    fileExtension: "myapp",
    conformingTo: UTType.data
)
```

**FileImportDelegate**:

```swift
extension MyViewController: FileImportDelegate {
    func fileImportDidPick(data: Data, url: URL) {
        // Handle imported file
    }

    func fileImportDidCancel() {
        // Handle cancellation
    }
}
```

**Migration steps**:
1. Find your custom file export/import classes.
2. Replace with `FileExportService.shared` and `FileImportService.shared`.
3. Update all export/import operations.
4. Remove your custom implementation.

**Keep custom when**: The host app owns domain-specific file format handling or cloud import flows that go beyond generic document pick + share sheet.

---

### 26. Device Info

**Tier**: `heuristic` · **Confidence**: medium

Replace custom device info utilities with `DeviceInfo`.

**Source**: `Sources/SwapFoundationKit/Services/DeviceInfo.swift`

**API**:

```swift
import SwapFoundationKit

print(DeviceInfo.deviceModel)           // "iPhone 14 Pro"
print(DeviceInfo.deviceModelIdentifier) // "iPhone15,2"
print(DeviceInfo.isSimulator)           // true/false
print(DeviceInfo.hasNotch)              // true/false
print(DeviceInfo.appVersion)            // "1.0.0"
print(DeviceInfo.appBuildNumber)        // "123"
print(DeviceInfo.isIPad)                // true/false
print(DeviceInfo.screenSize)            // CGSize
```

---

### 27. Pasteboard Service

**Tier**: `heuristic` · **Confidence**: medium

Replace custom pasteboard/clipboard utilities with `PasteboardService`.

**Source**: `Sources/SwapFoundationKit/Services/PasteboardService.swift`

**Protocol**: `PasteboardCopyRepresentable` — for types that can be copied to pasteboard.

---

### 28. Location Search Service

**Tier**: `heuristic` · **Confidence**: medium

Replace custom location search utilities with `LocationSearchService`.

**Source**: `Sources/SwapFoundationKit/Services/LocationSearchService.swift`

MapKit-based location search service.

---

### 29. Update Availability Service

**Tier**: `heuristic` · **Confidence**: medium

Check for app updates with `SFKUpdateAvailabilityService`.

**Source**: `Sources/SwapFoundationKit/Services/UpdateAvailability/SFKUpdateAvailabilityService.swift`

Integrates with `UpdateAvailableKit` for version checking.

---

### 30. App Store Search

**Tier**: `heuristic` · **Confidence**: medium

Search the App Store with `AppStoreSearchResult`.

**Source**: `Sources/SwapFoundationKit/Services/AppStoreSearch/AppStoreSearchResult.swift`

---

### 31. Photo Picker

**Tier**: `heuristic` · **Confidence**: medium

Replace custom photo picker implementations with `PhotoPicker`.

**Source**: `Sources/SwapFoundationKit/UI/PhotoPicker.swift`

---

### 32. Barcode Scanner

**Tier**: `heuristic` · **Confidence**: medium

Replace custom barcode scanner implementations with `BarcodeScannerView`.

**Sources**: `Sources/SwapFoundationKit/UI/BarcodeScanner/`

**Components**: `BarcodeScannerView`, `BarcodeScannerScreen`, `BarcodeScannerConfiguration`.

---

### 33. Pro Banner

**Tier**: `heuristic` · **Confidence**: medium

Display pro/upgrade banners with `ProBannerView`.

**Source**: `Sources/SwapFoundationKit/UI/ProBanner/ProBannerView.swift`

---

### 34. Aura Glow Background

**Tier**: `heuristic` · **Confidence**: medium

Add atmospheric glow backgrounds with `SFKAuraGlowBackground`.

**Source**: `Sources/SwapFoundationKit/UI/Effects/SFKAuraGlowBackground.swift`

---

### 35. SFKButton / Button Components

**Tier**: `heuristic` · **Confidence**: medium

Replace custom button components with `SFKButton` and `SFKButtonConfigurator`.

**Sources**: `Sources/SwapFoundationKit/UI/Buttons/SFKButton.swift`, `Sources/SwapFoundationKit/UI/Buttons/SFKButtonConfigurator.swift`

**Search your app for**: `PrimaryButton`, `SecondaryButton`, `PillButton`, `ToolbarButton`

**Suspicious file patterns**: `*Button*`

**API**:

```swift
import SwapFoundationKit

// Direct creation
SFKButton(
    "Add Transaction",
    leadingIconName: "wand.and.stars",
    subtitle: "Recommended",
    color: .blue
) {
    // action
}

// Using configurator
var close = SFKButtonConfigurator.close
close.title = "Close"

SFKButton(configuration: close) {
    // dismiss
}

// Loading state
SFKButton(
    "Saving",
    leadingIconName: "arrow.triangle.2.circlepath",
    isLoading: true,
    color: .green
) {
    // taps are ignored while loading
}
```

Sizing is driven by the button's padding values rather than a fixed minimum height. When `isLoading` is `true`, the button disables interaction, swaps its label for a spinner, and shrinks out of full-width mode.

**Configurator presets**: `.primary`, `.close`

**Chrome styles**: `.glassProminent`, `.glass`, `.glassEffect(style:shape:isInteractive:)`, `.plain`

**Haptic styles**: `.light`, `.medium`, `.heavy`

**Migration steps**:
1. Find your custom button components.
2. Prefer replacing them with `SFKButton(...)` or `SFKButton(configuration: ...)`.
3. Use `SFKButtonConfigurator` presets and overrides for reusable button styles, loading states, and compact variants.
4. Remove custom button implementations.

**Keep custom when**: The host app already has a design system and should only adopt SFK components intentionally.

---

### 36. Glass Compatibility Wrappers

**Tier**: `heuristic` · **Confidence**: medium

Apply compatibility wrappers around SwiftUI's native Liquid Glass APIs.

**Source**: `Sources/SwapFoundationKit/UI/SwiftUIExtensions/GlassButtonModifier.swift`

**API**:

```swift
import SwapFoundationKit

Button("Glass") { }
    .glassCompat(color: .blue)

Button("Prominent") { }
    .glassProminentCompat(color: .mint)

Button(action: {}) {
    Image(systemName: "plus").font(.title2)
}
.glassEffectCompat(style: .regular, color: .blue, isInteractive: true, in: Circle())
```

**Modifiers**:
- `.glassCompat(color:)` — pre-iOS 26 fallback to background fill
- `.glassProminentCompat(color:)` — pre-iOS 26 fallback to background fill
- `.glassEffectCompat(style:color:isInteractive:in:)` — pre-iOS 26 fallback to shape fill

---

### 37. AlertPresenter / AlertController

**Tier**: `exact` · **Confidence**: medium

Replace custom alert presentation with `AlertController` (SwiftUI-native) or `AlertPresenter` (UIKit-based).

**Source**: `Sources/SwapFoundationKit/UI/AlertPresenter.swift`

**Search your app for**: `UIAlertController`, `AlertState`, `AlertPresenter`, `confirmationDialog`, `text field alert`

**Suspicious file patterns**: `*Alert*`, `*Dialog*`, `*Prompt*`

#### AlertController (SwiftUI-native)

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

```swift
import SwapFoundationKit

// Simple alert
AlertPresenter.showAlert(title: "Hello", message: "World")

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

**Types**: `AlertAction`, `AlertActionStyle` (`.default`, `.cancel`, `.destructive`), `AlertTextField`, `KeyboardType` (`.default`, `.email`, `.number`, `.phone`, `.url`), `AlertConfiguration`.

**Migration steps**:
1. Find your custom alert presentation code.
2. Replace with `AlertController` for SwiftUI or `AlertPresenter` for UIKit.
3. Update all alert calls.
4. Remove your custom alert implementation.

**Keep custom when**: The host app has custom design-system alert presentation that intentionally diverges from SFK's UI.

---

### 38. SFKItemPickerView (Generic Item Picker)

**Tier**: `heuristic` · **Confidence**: medium

Replace custom picker implementations with `SFKItemPickerView`.

**Sources**: `Sources/SwapFoundationKit/UI/ItemPicker/`

**API**:

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

**Protocols**:

```swift
// Conform your types to SFKPickableItem (always via extension)
extension MyType: SFKPickableItem {
    public var pickableItemId: String { id }

    public var pickableItemIconKind: SFKPickableItemIconKind {
        .systemIcon(symbolName: "star.fill")
    }

    public var pickableItemTitle: String { name }

    public var pickableItemSubtitle: String? { nil }
}
```

**Icon kinds**: `.iconImage(uiImage:)`, `.systemIcon(symbolName:)`, `.text(text:)`, `.none`

**Selection modes**: `.single`, `.multi`

`Currency` already conforms to `SFKPickableItem` via an extension.

---

### 39. Settings Screen UI

**Tier**: `exact` · **Confidence**: high

Replace custom settings screen implementations with the SFK settings module.

**Sources**: `Sources/SwapFoundationKit/UI/Settings/` (14 files)

**Search your app for**: `SettingsView`, `SettingsScreen`, `SettingsItem protocol`, `SettingsSection`, `SettingsRow`, `informationSectionItem`, `developerSectionItem`, `SettingsViewModel`, `settingsRow`, `DatePicker row`, `Toggle row`, `Stepper row`, `Slider row`, `ColorPicker row`, `destructive row`, `confirmation row`

**Suspicious file patterns**: `*Settings*`, `*Setting*View*`, `*Setting*Screen*`, `*Setting*Row*`, `*Setting*Item*`, `*Setting*Section*`

#### SettingsItem Protocol

```swift
import SwapFoundationKit

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

#### Row Components

| Row Type | Component | Use Case |
|----------|-----------|----------|
| Tappable | `SFKSettingsRow<Item>` | Navigation, actions |
| Label | `SFKSettingsLabel` | Display-only |
| Toggle | `SFKSettingsToggle` | Boolean on/off (explicit properties) |
| Toggle (SettingsItem) | `SFKSettingsToggleRow<Item>` | Boolean on/off (protocol-based) |
| Date Picker | `SFKSettingsDatePickerRow` | Date/time selection (sheet) |
| Time Picker | `SFKSettingsTimePickerRow` | Time selection (sheet) |
| Inline Date | `SFKSettingsInlineDatePicker` | Inline date picker |
| Stepper | `SFKSettingsStepperRow` | Numeric +/- |
| Slider | `SFKSettingsSliderRow` | Continuous values |
| Color Picker | `SFKSettingsColorPickerRow` | Color selection (sheet) |
| Inline Color | `SFKSettingsInlineColorPicker` | Inline color picker |
| Link | `SFKSettingsLinkRow` | Open URL |
| Destructive | `SFKSettingsDestructiveRow` | Delete/reset |
| Confirmation | `SFKSettingsConfirmationRow` | Confirm before action |
| Picker | `SFKSettingsPickerRow` | Generic picker row |

#### Full Settings Screen

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
                SFKSettingsSectionConfiguration(
                    title: "Preferences",
                    items: []
                ),
                SFKSettingsSectionConfiguration(
                    title: "Information",
                    items: SFKInformationSectionItem.allCases,
                    footer: "Version 1.0.0 (100)"
                ),
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
            case .rateOnTheAppStore: actionHandler.rateOnTheAppStore()
            case .privacyPolicy: actionHandler.openURLString("https://example.com/privacy")
            case .termsAndConditions: actionHandler.openURLString("https://example.com/terms")
            default: break
            }
        }
    }
}
```

#### Standard Section Items

**SFKInformationSectionItem**: `.version`, `.reportABug`, `.rateOnTheAppStore`, `.referToFriends`, `.privacyPolicy`, `.termsAndConditions`

**SFKDeveloperSectionItem**: `.website`, `.twitter`, `.anotherApp`

#### Action Handlers

```swift
let handler = SFKSettingsActionHandler(appID: "123456789")

handler.rateOnTheAppStore()
handler.shareApp(shareText: "Check out this great app!", appURL: url)
handler.openURL(url)
handler.openURLString("https://example.com")

// Pre-built handlers
let infoHandler = SFKInformationSectionHandler(
    handler: handler,
    privacyPolicyURL: URL(string: "https://myapp.com/privacy"),
    termsURL: URL(string: "https://myapp.com/terms")
)

if infoHandler.handle(item) { /* item was handled */ }
```

#### Update Banner Integration

`SFKSettingsScreen` supports update-banner placement directly:

```swift
@State private var updateVersion: String? = "2.3.0"

SFKSettingsScreen(
    header: header,
    sections: sections,
    updateBannerVersion: $updateVersion,
    updateBannerTheme: .default,
    updateBannerAppStoreID: "123456789",
    onUpdateBannerTap: {
        analytics.track("update_banner_tapped")
    },
    onItemTap: handleTap(_:)
)
```

**Behavior**:
- Banner shown when `updateBannerVersion.wrappedValue` is non-`nil`.
- Tapping opens the App Store page.
- After tap, `updateBannerVersion.wrappedValue` is set to `nil`.
- `onUpdateBannerTap` runs after the binding is cleared, so apps can log analytics or clear mirrored state.

**Migration steps**:
1. Find your custom settings screen/row implementations.
2. Replace with SFK settings components.
3. Make your settings items conform to `SettingsItem`.
4. Use `SFKSettingsScreen` for the full screen or individual row components in your own Form.
5. Remove your custom settings implementation.

**Keep custom when**: The host app needs a pro banner, subscription-specific logic, or app-coordinator navigation that should remain in the app layer.

---

### 40. Onboarding UI Components

**Tier**: `heuristic` · **Confidence**: medium

Replace local onboarding components with the SFK onboarding module.

**Sources**: `Sources/SwapFoundationKit/UI/Onboarding/` (6 files)

Full documentation: `Docs/onboarding-components.md`

#### Component Summary

| Component | Purpose |
|-----------|---------|
| `SFKChipFlowLayout` | Flex-wrap `Layout` for chips/tags |
| `SFKSegmentedProgress` | Story-style segmented progress bar |
| `SFKSelectableChip` | Selectable capsule button with icon support |
| `SFKChipItem` | Protocol for model types used with chips |
| `SFKSecondaryButton` | Text-only button for skip/dismiss actions |
| `SFKTypography` | Six View-extension typography modifiers |
| `SFKCard` | Rounded-rectangle card container with optional icon |

#### Quick Example

```swift
import SwapFoundationKit

// Progress bar
SFKSegmentedProgress(currentStep: 2, totalSteps: 5)

// Chip flow with selectable items
SFKChipFlowLayout(spacing: 8) {
    SFKSelectableChip("Save money", isSelected: true, tintColor: .blue) { }
    SFKSelectableChip("Track spending", isSelected: false, tintColor: .blue) { }
}

// Typography
Text("Welcome")
    .sfkFlowTitleStyle()

// Card
SFKCard(icon: "star.fill", iconTint: .yellow) {
    Text("Featured content")
}

// Secondary button
SFKSecondaryButton("Skip for now") { }
```

#### SFKChipItem Protocol

```swift
enum Goal: String, CaseIterable, SFKChipItem {
    case trackSpending = "Track my spending"
    case saveMoney = "Save money"

    var chipLabel: String { rawValue }
    var chipIcon: String? { nil } // optional emoji or SF Symbol
}
```

#### Typography Modifiers

| Modifier | Font | Weight | Color | Use Case |
|----------|------|--------|-------|----------|
| `sfkFlowTitleStyle()` | `.title` | `.bold` | `.primary` | Screen headers |
| `sfkFlowQuestionStyle()` | `.title2` | `.bold` | `.primary` | Question prompts |
| `sfkFlowSubtitleStyle()` | `.body` | `.medium` | `.secondary` | Descriptive text |
| `sfkFlowCardTitleStyle()` | `.headline` | `.semibold` | `.primary` | Card titles |
| `sfkFlowCardBodyStyle()` | `.subheadline` | regular | `.secondary` | Card body text |
| `sfkFlowChipStyle()` | `.subheadline` | `.semibold` | `.primary` | Chip labels |

#### Migration from App-Local Components

| Your Local Component | SFK Replacement |
|---------------------|-----------------|
| `OnboardingChipFlowLayout` | `SFKChipFlowLayout` |
| `OnboardingProgressBar` | `SFKSegmentedProgress` |
| `GoalSelectionCard` / `SelectableChip` | `SFKSelectableChip` |
| `OnboardingSecondaryButton` | `SFKSecondaryButton` |
| `onboardingTitleStyle()` | `sfkFlowTitleStyle()` |
| `onboardingSubtitleStyle()` | `sfkFlowSubtitleStyle()` |
| `onboardingQuestionTitleStyle()` | `sfkFlowQuestionStyle()` |
| `onboardingCardTitleStyle()` | `sfkFlowCardTitleStyle()` |
| `onboardingCardBodyStyle()` | `sfkFlowCardBodyStyle()` |
| `onboardingChipTitleStyle()` | `sfkFlowChipStyle()` |
| Custom card container | `SFKCard` |

---

### 41. Update Available Banner

**Tier**: `heuristic` · **Confidence**: medium

Display non-intrusive update-available banners with `SFKUpdateAvailableBannerView`.

**Sources**: `Sources/SwapFoundationKit/UI/UpdateAvailableBanner/`

**API**:

```swift
import SwapFoundationKit

// Direct usage
SFKUpdateAvailableBannerView(
    newVersion: "2.3.0",
    appStoreID: "123456789",
    onTap: { /* analytics */ },
    onDismiss: { /* clear state */ }
)

// Reactive with UpdateBannerState
SFKUpdateAvailableBannerView(state: bannerState, appStoreID: "123456789")
```

**Types**:
- `UpdateBannerState` — `.none`, `.available(newVersion:)`
- `UpdateAvailableBannerTheme` — `backgroundColor`, `titleColor`, `subtitleColor`, `iconName`, `buttonTitle`, `buttonColor`, `buttonTitleColor`
- `UpdateAvailableManager` (from UpdateAvailableKit) — `shared`, `result`, `start()`, `configure(with:)`
- `UpdateAvailableConfiguration` — `bundleID`, `cacheDuration`

---

### 42. UIKit Extensions

**Tier**: `manual` · **Confidence**: low

Replace custom UIKit extensions with SFK's UIKit extensions.

**Sources**: `Sources/SwapFoundationKit/UI/UIKitExtensions/`

#### UIColor Extensions

**Source**: `Sources/SwapFoundationKit/UI/UIKitExtensions/UIColor+.swift`

```swift
import SwapFoundationKit

// Hex colors
let color = UIColor(hex: "#FF0000")
print(color.hexString()) // "#FF0000"

// Color components
print(color.redComponent)
print(color.greenComponent)
print(color.blueComponent)
print(color.alphaComponent)

// Color manipulation
let lighter = color.lighter(by: 0.2)
let darker = color.darker(by: 0.2)
let random = UIColor.random
```

#### UIView Extensions

**Sources**: `Sources/SwapFoundationKit/UI/UIKitExtensions/UIView+Layout.swift`, `Sources/SwapFoundationKit/UI/UIKitExtensions/UIView+Hierarchy.swift`

```swift
import SwapFoundationKit

// Add multiple subviews
view.addSubviews(view1, view2, view3)

// Remove all subviews
view.removeAllSubviews()

// Find subviews
let buttons = view.allSubViewsOf(type: UIButton.self)

// Layout constraints
view.anchor(top: parent.topAnchor, leading: parent.leadingAnchor,
            bottom: parent.bottomAnchor, trailing: parent.trailingAnchor)
```

#### UIImage Extensions

**Source**: `Sources/SwapFoundationKit/UI/UIKitExtensions/UIImage+.swift`

```swift
import SwapFoundationKit

if let resized = image.resized(targetSize: CGSize(width: 100, height: 100)) {
    imageView.image = resized
}
```

#### CGTypes Extensions

**Source**: `Sources/SwapFoundationKit/UI/UIKitExtensions/CGTypes+Extensions.swift`

```swift
import SwapFoundationKit

let distance = point1.distance(to: point2)
let ratio = size.aspectRatio
let fitted = size.fitted(into: otherSize)
let center = rect.center
```

#### Other UIKit Extensions

- `UIViewController+` — view controller utilities
- `UINavigationController+` — navigation controller utilities
- `UIApplication+SafeArea` — safe area helpers

---

### 43. Compatibility Wrappers

**Tier**: `heuristic` · **Confidence**: medium

Version-compatible wrappers for iOS version-specific APIs.

**Sources**: `Sources/SwapFoundationKit/Compatibility/`

- `CompatibleNavigationSubtitle` — navigation subtitle compatibility
- `CompatibleTabBarMinimizeBehavior` / `UIKitTabBarMinimizeBehavior` — tab bar minimize behavior

---

### 44. Configuration Service

**Tier**: `heuristic` · **Confidence**: medium

Centralized configuration service.

**Sources**: `Sources/SwapFoundationKit/SwapFoundationKit.swift`, `Sources/SwapFoundationKit/SwapFoundationKitConfiguration.swift`, `Sources/SwapFoundationKit/Core/ConfigurationService.swift`

**Search your app for**: `AppConfiguration`, `Environment`, `BuildConfig`, `InfoPlist`, `ConfigService`

**Suspicious file patterns**: `*Config*`, `*Environment*`, `*BuildSettings*`

**Migration steps**:
1. Replace custom configuration classes with `SwapFoundationKitConfiguration`.
2. Use `ConfigurationService.shared` for centralized config access.
3. Remove your custom configuration implementation.

**Keep custom when**: The host app maintains environment policy, feature flags, or secrets management above SFK.

---

### 45. Ads Manager

**Tier**: `heuristic` · **Confidence**: medium

Manage ad integration with `AdsManager`.

**Sources**: `Sources/SwapFoundationKit/Ads/`

**API**:

```swift
import SwapFoundationKit

// Configuration
let config = AdsConfiguration(
    provider: .google(GoogleAdsConfiguration(
        appId: "ca-app-pub-xxx",
        adUnits: AdUnitConfiguration(
            banner: "ca-app-pub-xxx/banner",
            interstitial: "ca-app-pub-xxx/interstitial",
            rewarded: "ca-app-pub-xxx/rewarded"
        )
    )),
    preloadOnStart: true
)

// Start
await AdsManager.shared.start(with: config)

// Eligibility check
AdsManager.shared.isEligibleToShowAds = { true }

// Event handler
AdsManager.shared.eventHandler = { event in
    // Handle ad events
}
```

**Components**: `AdsManager`, `AdsConfiguration`, `AdUnitConfiguration`, `GoogleAdsConfiguration`, `AdProvider` (`.google`), `AdsProvider` protocol, `GoogleAdsProvider`.

---

### 46. Protocols

**Tier**: `manual` · **Confidence**: low

Shared protocols for cross-cutting concerns.

**Sources**: `Sources/SwapFoundationKit/Protocols/`

- `AppMetaData` — app metadata protocol with App Store URL helpers
- `Coordinator` — navigation coordinator protocol
- `PasteboardCopyRepresentable` — protocol for types that can be copied to pasteboard
- `ValueDefaultProvider` — protocol for value default providers

---

### 47. SFKSettingsScreen (Full Screen Builder)

See [Capability 39: Settings Screen UI](#39-settings-screen-ui) for the complete settings module documentation including `SFKSettingsScreen`, row components, section items, and action handlers.

---

### 48. ItemDetailSource

**Tier**: `heuristic` · **Confidence**: medium

Protocol for fetching item detail data with default implementation.

**Sources**: `Sources/SwapFoundationKit/Services/ItemDetailSource.swift`, `Sources/SwapFoundationKit/Services/DefaultItemDetailSource.swift`

---

## Known Refactoring Opportunities

These are internal SFK improvements tracked for future work. They do not affect public API but are worth noting if you contribute to the library:

| # | Issue | Files | Recommendation |
|---|-------|-------|----------------|
| 1 | Duplicate `NetworkError` definitions | `Networking.swift`, `NetworkService.swift` | Consolidate into single enum |
| 2 | DateFormatter created 17+ times | `Date+Extensions.swift` | Use cached formatters |
| 3 | Calendar.current accessed 18+ times | `Date+Extensions.swift` | Cache as static property |
| 4 | UIColor RGBA extraction repeated 10+ times | `UIColor+.swift` | Extract helper method |
| 5 | Duplicate type conversion logic | `Bundle+InfoPlist.swift` | Extract shared method |
| 6 | UIColor+.swift (393 lines) | — | Split into 4 files |
| 7 | Date+Extensions.swift (321 lines) | — | Split into 3 files |
| 8 | String+.swift (315 lines) | — | Reorganize extension blocks |
| 9 | ConfigurationService.swift (407 lines) | — | Extract convenience methods |
| 10 | String validation naming inconsistencies | `String+.swift` | Standardize conventions |
| 11 | HTTPClient vs NetworkService overlap | — | Clarify or consolidate |
| 12 | Hardcoded URLs | `ExchangeRateManager.swift`, `AppMetaData.swift` | Extract to constants |

---

## API Reference

### Core Services
- **`SwapFoundationKit`** — Main framework entry point (singleton)
- **`SwapFoundationKitConfiguration`** — Configuration struct
- **`ConfigurationService`** — Centralized configuration service
- **`HTTPClient`** — Modern HTTP client with async/await
- **`NetworkService`** — Network operations and reachability
- **`SecurityService`** — Encryption, keychain, secure storage
- **`BackupService`** — Data backup and restore

### Services
- **`HapticsHelper`** — Haptic feedback manager
- **`Logger`** — Configurable logging with analytics integration
- **`AnalyticsManager`** — Protocol-based analytics fan-out system
- **`ToastManager`** — Toast notification system
- **`UserDefault`** — Type-safe UserDefaults property wrapper
- **`AppLinkOpener`** — URL and app link opening
- **`DeviceInfo`** — Device information utility
- **`FileExportService`** — Share sheet export
- **`FileImportService`** — Document picker import
- **`DeeplinkHandler`** — Type-safe deeplink handling with Combine
- **`PasteboardService`** — Clipboard operations
- **`LocationSearchService`** — MapKit location search
- **`ItemDetailSource`** — Item detail data protocol
- **`SFKUpdateAvailabilityService`** — Update availability checking

### UI Components
- **`SFKButton`** — Configurable button with line-item and configurator-based initializers
- **`SFKButtonConfigurator`** — Reusable button configuration model with `.primary` and `.close` presets
- **`SFKChipFlowLayout`** — Flex-wrap `Layout` for chip/tag clouds
- **`SFKSegmentedProgress`** — Story-style segmented progress indicator
- **`SFKSelectableChip`** — Selectable capsule button with icon and haptic support
- **`SFKChipItem`** — Protocol for model types used with `SFKSelectableChip`
- **`SFKSecondaryButton`** — Text-only button for skip/dismiss actions
- **`SFKTypography`** — View extensions: `sfkFlowTitleStyle`, `sfkFlowQuestionStyle`, `sfkFlowSubtitleStyle`, `sfkFlowCardTitleStyle`, `sfkFlowCardBodyStyle`, `sfkFlowChipStyle`
- **`SFKCard`** — Rounded-rectangle card container with optional leading icon
- **`SFKItemPickerView`** — Generic picker view with single/multi-select
- **`SFKSettingsScreen`** — Full settings screen builder
- **`SFKSettingsRow`** — Tappable settings row
- **`SFKSettingsLabel`** — Display-only settings row
- **`SFKSettingsToggle`** — Toggle settings row
- **`SFKSettingsDatePickerRow`** — Date picker settings row
- **`SFKSettingsStepperRow`** — Stepper settings row
- **`SFKSettingsColorPickerRow`** — Color picker settings row
- **`SFKSettingsLinkRow`** — URL link settings row
- **`SFKSettingsDestructiveRow`** — Destructive action settings row
- **`SFKSettingsConfirmationRow`** — Confirmation settings row
- **`SFKSettingsSliderRow`** — Slider settings row
- **`SFKSettingsInlineDatePicker`** — Inline date picker
- **`SFKSettingsInlineColorPicker`** — Inline color picker
- **`SFKSettingsTimePickerRow`** — Time picker settings row
- **`SFKSettingsPickerRow`** — Generic picker settings row
- **`AlertController`** — SwiftUI-native alert manager
- **`AlertPresenter`** — UIKit-based alert presentation
- **`SFKUpdateAvailableBannerView`** — Update available banner
- **`ProBannerView`** — Pro/upgrade banner
- **`BarcodeScannerView`** — Barcode scanning UI
- **`PhotoPicker`** — Photo picker wrapper
- **`SFKAuraGlowBackground`** — Aura glow background effect

### Glass Compatibility Wrappers
- **`.glassProminentCompat()`** — Compatibility wrapper for `.glassProminent`
- **`.glassCompat()`** — Compatibility wrapper for `.glass`
- **`.glassEffectCompat()`** — Compatibility wrapper for `glassEffect(_:in:)`

### Utilities
- **`Debouncer`** — Action debouncing utility
- **`ImageProcessor`** — Image manipulation and caching
- **`ExchangeRateManager`** — Currency exchange rates
- **`Currency`** — Currency enum with symbols

### Extensions
- **`Date`** — Comprehensive date formatting and manipulation
- **`String`** — String validation, manipulation, and conversion
- **`Double`/`Float`** — Number formatting utilities
- **`Data`** — Crypto hashing (MD5, SHA1, SHA256)
- **`Bundle`** — Info.plist access utilities
- **`Collection`** — Safe subscript and utilities
- **`URL`** — URL query helpers
- **`FileManager`** — File operations
- **`Result`** — Result helpers
- **`JSONCodable`** — JSON encode/decode helpers
- **`UIColor`** — Hex colors, color manipulation
- **`UIView`** — Layout and hierarchy utilities
- **`UIImage`** — Image resizing utilities
- **`CGTypes`** — CGPoint/CGSize/CGRect utilities

### Modules
- **`ItemSync`** — Data synchronization between app, widgets, and Watch
- **`WatchSync`** — Type-safe watch transport abstraction
- **`Ads`** — Ad management (Google Mobile Ads)

### Protocols
- **`AppMetaData`** — App metadata with App Store URL helpers
- **`Coordinator`** — Navigation coordinator
- **`SettingsItem`** — Settings row contract
- **`SFKPickableItem`** — Picker item contract
- **`SFKChipItem`** — Chip item contract
- **`AnalyticsEvent`** — Analytics event contract
- **`AnalyticsLogger`** — Analytics logger contract
- **`SyncableData`** — Syncable data contract
- **`NetworkRequest`** — Network request contract
- **`SFKToastKind`** — Toast kind contract
- **`DeeplinkRoute`** — Deeplink route contract
- **`UserDefaultKeyProtocol`** — UserDefaults key contract
- **`PasteboardCopyRepresentable`** — Pasteboard contract
- **`ValueDefaultProvider`** — Value provider contract

### Property Wrappers
- **`@UserDefault`** — Type-safe UserDefaults with SwiftUI support

---

## Architecture

SwapFoundationKit is built with these principles:

- **Protocol-Oriented Design** — Easy to implement, test, and extend
- **Modern Swift Features** — Leverages async/await, actors, and Swift concurrency
- **Type Safety** — Compile-time safety with generics and protocols
- **Modular Structure** — Organized by domain (Core, Services, UI, Extensions, Utilities)
- **Comprehensive Testing** — Well-tested components with mock support

---

## Configuration

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

## Testing

The package includes test coverage for core utilities. This library targets **iOS** and depends on UIKit-based packages, so **`swift test` on macOS often fails** (UIKit is not available for the default macOS triple).

Run tests from the package root with Xcode's iOS Simulator destination:

```bash
cd /path/to/SwapFoundationKit
xcodebuild test -scheme SwapFoundationKit -destination 'platform=iOS Simulator,name=iPhone 16'
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

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

---

## License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

---

## Acknowledgments

- **ECB** for providing exchange rate data
- **Apple** for the excellent Swift language and frameworks
- **Community** for feedback and contributions

---

## Support

- **Issues**: [GitHub Issues](https://github.com/SwapnanilDhol/SwapFoundationKit/issues)
- **Discussions**: [GitHub Discussions](https://github.com/SwapnanilDhol/SwapFoundationKit/discussions)
- **Email**: swapnanildhol@gmail.com

---

**Made with ❤️ by [Swapnanil Dhol](https://github.com/SwapnanilDhol)**
