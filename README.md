# SwapFoundationKit

A comprehensive Swift package providing essential utilities, extensions, and services for iOS, macOS, and watchOS development. Built with modern Swift features and designed for developer productivity.

## 🚀 Features

- **🌐 Networking Module** - Modern HTTP client with async/await, JSON encoding/decoding, and comprehensive error handling
- **📊 Analytics System** - Protocol-based analytics with Firebase, Mixpanel, and custom provider support
- **🔄 ItemSync** - Data synchronization between main app, widgets, and Apple Watch
- **💾 Generic Backup Service** - Flexible backup and restore functionality
- **🌍 Currency & Exchange Rates** - Real-time currency conversion with ECB data
- **🖼️ Image Processing** - Image manipulation, caching, and file operations
- **📱 UIKit Extensions** - Helpful extensions for common UI operations
- **📅 Date Utilities** - Comprehensive date formatting and manipulation
- **🔧 Logger** - Configurable logging with analytics integration
- **⚙️ UserDefaults** - Type-safe UserDefaults with SwiftUI support
- **📋 Bundle Info** - Easy access to app metadata and configuration

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

## 🎯 Quick Start

### Analytics System

```swift
import SwapFoundationKit

// Define your analytics events
enum AppAnalyticsEvent: AnalyticsEvent {
    case userSignedIn(userId: String)
    case purchase(amount: Double, currency: String)

    var rawValue: String {
        switch self {
        case .userSignedIn: return "user_signed_in"
        case .purchase: return "purchase"
        }
    }

    var parameters: [String: String]? {
        switch self {
        case .userSignedIn(let userId):
            return ["user_id": userId]
        case .purchase(let amount, let currency):
            return ["amount": String(amount), "currency": currency]
        }
    }
}

// Create Firebase logger
class FirebaseAnalyticsLogger: AnalyticsLogger {
    func logEvent(event: AnalyticsEvent, parameters: [String: String]?) {
        var firebaseParams: [String: Any] = [:]
        if let parameters = parameters {
            for (key, value) in parameters {
                firebaseParams[key] = value
            }
        }
        Analytics.logEvent(event.rawValue, parameters: firebaseParams)
    }
}

// Setup and use
let analyticsManager = AnalyticsManager.shared
analyticsManager.addLogger(FirebaseAnalyticsLogger())

let event = AppAnalyticsEvent.userSignedIn(userId: "user123")
analyticsManager.logEvent(event: event, parameters: event.parameters)
```

### ItemSync for Data Sharing

```swift
import SwapFoundationKit.ItemSync

// Define your data model
struct UserProfile: SyncableData {
    let id: String
    let name: String
    static let syncIdentifier = "user_profile"
}

// Create sync service
// 🆕 NEW: Using centralized configuration (recommended)
// After calling SwapFoundationKit.shared.start(with: config)
let syncService = ItemSyncServiceFactory.create() // Automatic configuration!

// Legacy: Manual configuration (still supported)
let syncService = ItemSyncServiceFactory.create(
    appGroupIdentifier: "group.com.yourapp.widget"
)

// Save data (automatically syncs to widgets/extensions)
try await syncService.save(userProfile)

// Read data from anywhere in your app ecosystem
let profile = try await syncService.read(UserProfile.self)
```

### Currency Conversion

```swift
import SwapFoundationKit

// Start the exchange rate manager
await ExchangeRateManager.shared.start()

// Convert currencies
let usdAmount = ExchangeRateManager.shared.convert(
    value: 100.0,
    fromCurrency: .EUR,
    toCurrency: .USD
)

print("€100 = $\(usdAmount)")
```

### Networking Module

```swift
import SwapFoundationKit

// 🆕 NEW: Enable networking in configuration
let config = SwapFoundationKitConfiguration(
    appMetadata: AppMetaData(appGroupIdentifier: "group.com.example.app"),
    enableNetworking: true,  // Enable networking features
    networkTimeout: 30.0     // 30 second timeout
)

try await SwapFoundationKit.shared.start(with: config)

// Get HTTP client
guard let client = SwapFoundationKit.shared.networkClient else {
    print("Networking not enabled")
    return
}

// Define a network request
struct GetUsersRequest: NetworkRequest {
    var baseURL: String { "api.example.com" }
    var path: String { "/users" }
    var method: HTTPMethod { .get }
    var parameters: [String: String]? { ["limit": "10"] }
}

// Execute request with automatic JSON decoding
let users: [User] = try await client.executeAndDecode(GetUsersRequest())

// Or use convenience methods
let response = try await client.get(
    baseURL: "api.example.com",
    path: "/users",
    parameters: ["limit": "10"]
)
```

### Date Utilities

```swift
import SwapFoundationKit

let date = Date()

// Format dates easily
print(date.iso8601String)        // "2024-01-15T10:30:00Z"
print(date.shortDate)            // "1/15/24"
print(date.mediumDate)           // "Jan 15, 2024"
print(date.timeOnly)             // "10:30 AM"
print(date.yyyyMMdd)             // "2024-01-15"
print(date.relativeTime)         // "2 hours ago"
```

### Image Processing

```swift
import SwapFoundationKit

let imageProcessor = ImageProcessor.shared

// Resize and round corners
if let resizedImage = imageProcessor.resize(originalImage, to: CGSize(width: 300, height: 300)),
   let roundedImage = imageProcessor.roundCorners(resizedImage, radius: 20) {
    imageView.image = roundedImage
}

// Cache processed image
imageProcessor.cacheImage(roundedImage, forKey: "profile_processed")

// Save to documents directory
try imageProcessor.saveImage(roundedImage, filename: "profile.jpg", quality: 0.9)
```

### Logger

```swift
import SwapFoundationKit

// Configure logger
Logger.minimumLevel = .info

// Log messages
Logger.info("User signed in successfully")
Logger.debug("Processing request...")
Logger.warning("API rate limit approaching")
Logger.error("Failed to load user data")

// Logger automatically sends error events to analytics when configured
```

## 📚 Documentation

### [Networking Module](Sources/SwapFoundationKit/Core/README.md)

Modern HTTP client with async/await, JSON encoding/decoding, and comprehensive error handling.

### [Analytics System](Sources/SwapFoundationKit/Analytics/README.md)

Complete guide to implementing analytics with Firebase, Mixpanel, and custom providers.

### [ItemSync](Sources/SwapFoundationKit/ItemSync/README.md)

Data synchronization between main app, widgets, and Apple Watch.

### [Currency System](Sources/SwapFoundationKit/Currency/)

Real-time exchange rates and currency conversion utilities.

### [Image Processor](Sources/SwapFoundationKit/ImageProcessor/)

Image manipulation, caching, and file operations.

### [UIKit Extensions](Sources/SwapFoundationKit/UIKit+/)

Helpful extensions for common UI operations and safe area handling.

## 🏗️ Architecture

SwapFoundationKit is built with these principles:

- **Protocol-Oriented Design** - Easy to implement, test, and extend
- **Modern Swift Features** - Leverages async/await, actors, and Swift concurrency
- **Type Safety** - Compile-time safety with generics and protocols
- **Modular Structure** - Import only what you need
- **Comprehensive Testing** - Well-tested components with mock support

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
3. Use the `FirebaseAnalyticsLogger` example from the analytics documentation

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

    func logEvent(event: AnalyticsEvent, parameters: [String: String]?) {
        loggedEvents.append((event: event, parameters: parameters))
    }
}
```

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **ECB** for providing exchange rate data
- **Apple** for the excellent Swift language and frameworks
- **Community** for feedback and contributions

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/SwapnanilDhol/SwapFoundationKit/issues)
- **Discussions**: [GitHub Discussions](https://github.com/SwapnanilDhol/SwapFoundationKit/discussions)
- **Email**: swapnanildhol@gmail.com

---

**Made with ❤️ by [Swapnanil Dhol](https://github.com/SwapnanilDhol)**
