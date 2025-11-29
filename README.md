# SwapFoundationKit

A comprehensive Swift package providing essential utilities, extensions, and services for iOS, macOS, and watchOS development. Built with modern Swift features and designed for developer productivity.

## 🎯 Migration Guide: Replacing Redundant Implementations

When integrating SwapFoundationKit into your app, you should **replace all redundant implementations** with the SDK's provided classes and utilities. This guide helps you identify what can be replaced and how to do it.

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

// Use throughout your app
let event = AppAnalyticsEvent.userSignedIn(userId: "user123")
AnalyticsManager.shared.logEvent(event: event, parameters: event.parameters)
```

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

// Restore backup
let restoredData = try backupService.restoreBackup(UserData.self, fileType: .data)

// List backup files
let backupFiles = backupService.listBackupFiles(for: .data)
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

// Cache images
imageProcessor.cacheImage(image, forKey: "profile_image")
if let cachedImage = imageProcessor.cachedImage(forKey: "profile_image") {
    imageView.image = cachedImage
}

// Save/Load images
let url = try imageProcessor.saveImage(image, filename: "profile.jpg", quality: 0.9)
let loadedImage = try imageProcessor.loadImage(filename: "profile.jpg")
```

**Migration Steps:**
1. Find your custom image processing/caching classes
2. Replace with `ImageProcessor.shared`
3. Update all image operations
4. Remove your custom image implementation

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

### 17. ItemSync / Data Synchronization

**If your app has custom data synchronization between app, widgets, and Watch, replace it with `ItemSync` from SwapFoundationKit.**

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

**Migration Steps:**
1. Find your custom sync/sharing classes
2. Replace with `ItemSyncServiceFactory.create()`
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

### 19. UIKit Extensions

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

### Utilities
- **`HapticsHelper`** - Haptic feedback manager
- **`Logger`** - Configurable logging with analytics integration
- **`Debouncer`** - Action debouncing utility
- **`ImageProcessor`** - Image manipulation and caching
- **`ExchangeRateManager`** - Currency exchange rates
- **`Currency`** - Currency enum with symbols
- **`AnalyticsManager`** - Protocol-based analytics system
- **`AppLinkOpener`** - URL and app link opening

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

The package includes comprehensive test coverage. Run tests with:

```bash
swift test
```

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
