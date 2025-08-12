# Services

The Services folder contains business logic services that provide specific functionality for common app requirements.

## 📊 Analytics Protocol

Protocol-based analytics system for flexible event tracking.

### Features

- **🎯 Protocol-Based** - Easy to implement and test
- **🔄 Multiple Loggers** - Send events to multiple analytics services
- **📱 Type-Safe Events** - Define events as enums or structs
- **⚡ Default Implementation** - Quick setup with `DefaultAnalyticsEvent`

### Quick Start

```swift
import SwapFoundationKit

// Define analytics events
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

## 🔧 Logger

Configurable logging system with analytics integration.

### Features

- **📝 Multiple Levels** - Debug, info, warning, error logging
- **📊 Analytics Integration** - Automatic error tracking
- **⚙️ Configurable** - Set minimum log level
- **🔄 Async Operations** - Non-blocking analytics calls

### Quick Start

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

## ⚙️ User Defaults

Type-safe UserDefaults with SwiftUI support.

### Features

- **🔒 Type Safety** - Compile-time type checking
- **📱 SwiftUI Support** - `@Published` integration
- **🔄 Observable** - Automatic UI updates
- **💾 Persistence** - Automatic data persistence

### Quick Start

```swift
import SwapFoundationKit
import SwiftUI

class UserSettings: ObservableObject {
    @UserDefault("username", defaultValue: "")
    var username: String
    
    @UserDefault("isPremium", defaultValue: false)
    var isPremium: Bool
    
    @UserDefault("lastLoginDate", defaultValue: Date())
    var lastLoginDate: Date
}

// Usage in SwiftUI
struct SettingsView: View {
    @StateObject private var settings = UserSettings()
    
    var body: some View {
        Form {
            TextField("Username", text: $settings.username)
            Toggle("Premium User", isOn: $settings.isPremium)
            Text("Last Login: \(settings.lastLoginDate.shortDate)")
        }
    }
}
```

## 🔗 App Link Opener

Service for opening external links and deep links.

### Features

- **🌐 URL Handling** - Safe URL opening with validation
- **🔗 Deep Links** - App-specific URL handling
- **🛡️ Security** - URL validation and sanitization
- **📱 Fallback** - Graceful fallback to web browser

### Quick Start

```swift
import SwapFoundationKit

let linkOpener = AppLinkOpener()

// Open web URL
linkOpener.openURL("https://example.com")

// Open deep link
linkOpener.openDeepLink("myapp://profile/123")

// Open with fallback
linkOpener.openURLWithFallback("https://example.com") { success in
    if !success {
        // Handle fallback (e.g., show in-app web view)
    }
}
```

## 📱 Haptics Helper

Haptic feedback utilities for better user experience.

### Features

- **📳 Haptic Types** - Impact, notification, and selection haptics
- **⚡ Performance** - Optimized haptic generation
- **🔄 Feedback Patterns** - Success, warning, error patterns
- **📱 Device Support** - Automatic device capability detection

### Quick Start

```swift
import SwapFoundationKit

let haptics = HapticsHelper()

// Basic haptics
haptics.impact(.light)
haptics.impact(.medium)
haptics.impact(.heavy)

// Notification haptics
haptics.notification(.success)
haptics.notification(.warning)
haptics.notification(.error)

// Selection haptics
haptics.selection()

// Custom patterns
haptics.playPattern([.light, .medium, .heavy])
```

## 📋 Item Detail Source

Service for managing item detail data sources.

### Features

- **📊 Data Management** - Structured data source handling
- **🔄 Updates** - Automatic data refresh and updates
- **📱 UI Integration** - SwiftUI and UIKit support
- **💾 Caching** - Efficient data caching and retrieval

### Quick Start

```swift
import SwapFoundationKit

class ProductDetailSource: ItemDetailSource {
    func fetchDetails(for itemId: String) async throws -> ProductDetails {
        // Fetch product details from API
        let details = try await apiService.fetchProduct(id: itemId)
        return details
    }
    
    func updateDetails(_ details: ProductDetails) async throws {
        // Update product details
        try await apiService.updateProduct(details)
    }
}

// Usage
let detailSource = ProductDetailSource()
let productDetails = try await detailSource.fetchDetails(for: "product123")
```

## 🎯 Service Architecture

### Design Principles

- **Single Responsibility** - Each service has a focused purpose
- **Protocol-Oriented** - Services use protocols for flexibility
- **Dependency Injection** - Easy to test and configure
- **Async/Await** - Modern Swift concurrency support

### Service Lifecycle

1. **Initialization** - Service setup and configuration
2. **Operation** - Core functionality execution
3. **Cleanup** - Resource management and cleanup

### Testing Services

```swift
// Mock service for testing
class MockAnalyticsLogger: AnalyticsLogger {
    private(set) var loggedEvents: [(event: AnalyticsEvent, parameters: [String: String]?)] = []
    
    func logEvent(event: AnalyticsEvent, parameters: [String: String]?) {
        loggedEvents.append((event: event, parameters: parameters))
    }
}

// In tests
let mockLogger = MockAnalyticsLogger()
analyticsManager.addLogger(mockLogger)

// Verify events were logged
XCTAssertEqual(mockLogger.loggedEvents.count, 1)
```

These services provide a solid foundation for common app functionality while maintaining flexibility and testability.
