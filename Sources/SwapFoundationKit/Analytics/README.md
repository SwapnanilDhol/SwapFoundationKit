# Analytics System

The SwapFoundationKit provides a flexible, protocol-based analytics system that allows you to easily integrate with various analytics providers like Firebase Analytics, Mixpanel, Amplitude, and more.

## Features

- ✅ **Protocol-based design** - Easy to implement and test
- ✅ **Multiple logger support** - Send events to multiple analytics services simultaneously
- ✅ **Type-safe events** - Define your analytics events as enums or structs
- ✅ **Default implementation** - Quick setup with `DefaultAnalyticsEvent`
- ✅ **Extensible** - Add custom analytics providers easily

## Quick Start

### 1. Define Your Analytics Events

```swift
import SwapFoundationKit

// Option 1: Using enums (recommended for type safety)
enum AppAnalyticsEvent: AnalyticsEvent {
    case userSignedIn(userId: String)
    case userSignedOut
    case purchase(amount: Double, currency: String)
    case viewScreen(screenName: String)
    
    var rawValue: String {
        switch self {
        case .userSignedIn: return "user_signed_in"
        case .userSignedOut: return "user_signed_out"
        case .purchase: return "purchase"
        case .viewScreen: return "view_screen"
        }
    }
    
    var parameters: [String: String]? {
        switch self {
        case .userSignedIn(let userId):
            return ["user_id": userId]
        case .userSignedOut:
            return nil
        case .purchase(let amount, let currency):
            return [
                "amount": String(amount),
                "currency": currency
            ]
        case .viewScreen(let screenName):
            return ["screen_name": screenName]
        }
    }
}

// Option 2: Using DefaultAnalyticsEvent (quick setup)
let quickEvent = DefaultAnalyticsEvent(
    name: "button_tapped",
    parameters: ["button_id": "login_button"]
)
```

### 2. Create Analytics Loggers

```swift
import SwapFoundationKit
import FirebaseAnalytics

// Firebase Analytics Logger
class FirebaseAnalyticsLogger: AnalyticsLogger {
    func logEvent(event: AnalyticsEvent, parameters: [String: String]?) {
        // Convert parameters to Firebase format
        var firebaseParams: [String: Any] = [:]
        if let parameters = parameters {
            for (key, value) in parameters {
                firebaseParams[key] = value
            }
        }
        
        // Log to Firebase
        Analytics.logEvent(event.rawValue, parameters: firebaseParams)
    }
}

// Console Logger (for debugging)
class ConsoleAnalyticsLogger: AnalyticsLogger {
    func logEvent(event: AnalyticsEvent, parameters: [String: String]?) {
        var logMessage = "📊 Analytics: \(event.rawValue)"
        if let parameters = parameters {
            logMessage += " | Parameters: \(parameters)"
        }
        print(logMessage)
    }
}

// Mixpanel Logger Example
class MixpanelAnalyticsLogger: AnalyticsLogger {
    private let mixpanel: Mixpanel
    
    init(mixpanel: Mixpanel) {
        self.mixpanel = mixpanel
    }
    
    func logEvent(event: AnalyticsEvent, parameters: [String: String]?) {
        var eventParams: [String: Any] = [:]
        if let parameters = parameters {
            for (key, value) in parameters {
                eventParams[key] = value
            }
        }
        
        mixpanel.track(event.rawValue, properties: eventParams)
    }
}
```

### 3. Setup Analytics Manager

```swift
import SwapFoundationKit

class AppAnalytics {
    static let shared = AppAnalytics()
    private let analyticsManager = AnalyticsManager.shared
    
    private init() {
        setupAnalytics()
    }
    
    private func setupAnalytics() {
        // Add Firebase logger
        let firebaseLogger = FirebaseAnalyticsLogger()
        analyticsManager.addLogger(firebaseLogger)
        
        // Add console logger for debugging
        let consoleLogger = ConsoleAnalyticsLogger()
        analyticsManager.addLogger(consoleLogger)
        
        // Add Mixpanel logger (if using Mixpanel)
        // let mixpanelLogger = MixpanelAnalyticsLogger(mixpanel: Mixpanel.sharedInstance)
        // analyticsManager.addLogger(mixpanelLogger)
    }
    
    // Convenience methods for common events
    func trackUserSignIn(userId: String) {
        let event = AppAnalyticsEvent.userSignedIn(userId: userId)
        analyticsManager.logEvent(event: event, parameters: event.parameters)
    }
    
    func trackUserSignOut() {
        let event = AppAnalyticsEvent.userSignedOut
        analyticsManager.logEvent(event: event, parameters: event.parameters)
    }
    
    func trackPurchase(amount: Double, currency: String) {
        let event = AppAnalyticsEvent.purchase(amount: amount, currency: currency)
        analyticsManager.logEvent(event: event, parameters: event.parameters)
    }
    
    func trackScreenView(screenName: String) {
        let event = AppAnalyticsEvent.viewScreen(screenName: screenName)
        analyticsManager.logEvent(event: event, parameters: event.parameters)
    }
}
```

### 4. Use in Your App

```swift
import SwapFoundationKit

class LoginViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Track screen view
        AppAnalytics.shared.trackScreenView(screenName: "login")
    }
    
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        // Your login logic here
        let userId = "user123"
        
        // Track the login event
        AppAnalytics.shared.trackUserSignIn(userId: userId)
        
        // Navigate to main app
        navigateToMainApp()
    }
}

class PurchaseViewController: UIViewController {
    
    @IBAction func purchaseButtonTapped(_ sender: UIButton) {
        let amount = 9.99
        let currency = "USD"
        
        // Track purchase event
        AppAnalytics.shared.trackPurchase(amount: amount, currency: currency)
        
        // Process purchase
        processPurchase()
    }
}
```

## Advanced Usage

### Custom Event with Complex Parameters

```swift
enum ComplexAnalyticsEvent: AnalyticsEvent {
    case userAction(
        action: String,
        context: String,
        metadata: [String: String]
    )
    
    var rawValue: String {
        switch self {
        case .userAction: return "user_action"
        }
    }
    
    var parameters: [String: String]? {
        switch self {
        case .userAction(let action, let context, let metadata):
            var params: [String: String] = [
                "action": action,
                "context": context
            ]
            
            // Add metadata parameters
            for (key, value) in metadata {
                params["meta_\(key)"] = value
            }
            
            return params
        }
    }
}

// Usage
let metadata = [
    "device_type": "iPhone",
    "app_version": "1.0.0",
    "user_segment": "premium"
]

let event = ComplexAnalyticsEvent.userAction(
    action: "swipe_gesture",
    context: "photo_gallery",
    metadata: metadata
)

AnalyticsManager.shared.logEvent(event: event, parameters: event.parameters)
```

### Conditional Logging

```swift
class ConditionalAnalyticsLogger: AnalyticsLogger {
    private let shouldLog: Bool
    
    init(shouldLog: Bool) {
        self.shouldLog = shouldLog
    }
    
    func logEvent(event: AnalyticsEvent, parameters: [String: String]?) {
        guard shouldLog else { return }
        
        // Only log when enabled
        print("📊 Analytics: \(event.rawValue)")
    }
}

// Use in development vs production
#if DEBUG
let devLogger = ConditionalAnalyticsLogger(shouldLog: true)
#else
let devLogger = ConditionalAnalyticsLogger(shouldLog: false)
#endif

analyticsManager.addLogger(devLogger)
```

### Batch Event Logging

```swift
class BatchAnalyticsLogger: AnalyticsLogger {
    private var eventQueue: [(AnalyticsEvent, [String: String]?)] = []
    private let maxBatchSize = 10
    
    func logEvent(event: AnalyticsEvent, parameters: [String: String]?) {
        eventQueue.append((event, parameters))
        
        if eventQueue.count >= maxBatchSize {
            flushEvents()
        }
    }
    
    private func flushEvents() {
        // Send batched events to your analytics service
        let events = eventQueue
        eventQueue.removeAll()
        
        // Example: Send to your analytics API
        sendBatchToAPI(events)
    }
    
    private func sendBatchToAPI(_ events: [(AnalyticsEvent, [String: String]?)]) {
        // Implementation depends on your analytics service
        print("📦 Sending batch of \(events.count) events")
    }
}
```

## Testing

### Mock Analytics Logger for Testing

```swift
class MockAnalyticsLogger: AnalyticsLogger {
    private(set) var loggedEvents: [(event: AnalyticsEvent, parameters: [String: String]?)] = []
    
    func logEvent(event: AnalyticsEvent, parameters: [String: String]?) {
        loggedEvents.append((event: event, parameters: parameters))
    }
    
    func clearEvents() {
        loggedEvents.removeAll()
    }
    
    func hasEvent(named eventName: String) -> Bool {
        return loggedEvents.contains { $0.event.rawValue == eventName }
    }
}

// In your tests
class AnalyticsTests: XCTestCase {
    var mockLogger: MockAnalyticsLogger!
    var analyticsManager: AnalyticsManager!
    
    override func setUp() {
        super.setUp()
        mockLogger = MockAnalyticsLogger()
        analyticsManager = AnalyticsManager.shared
        analyticsManager.addLogger(mockLogger)
    }
    
    func testUserSignInEvent() {
        // Given
        let userId = "test_user_123"
        
        // When
        let event = AppAnalyticsEvent.userSignedIn(userId: userId)
        analyticsManager.logEvent(event: event, parameters: event.parameters)
        
        // Then
        XCTAssertTrue(mockLogger.hasEvent(named: "user_signed_in"))
        XCTAssertEqual(mockLogger.loggedEvents.count, 1)
        
        let loggedEvent = mockLogger.loggedEvents.first
        XCTAssertEqual(loggedEvent?.parameters?["user_id"], userId)
    }
}
```

## Best Practices

1. **Use descriptive event names** - Make events self-documenting
2. **Consistent parameter naming** - Use snake_case for consistency
3. **Validate parameters** - Ensure all required parameters are present
4. **Test analytics** - Use mock loggers in your test suite
5. **Monitor performance** - Don't log too many events in performance-critical code
6. **Privacy compliance** - Ensure you're not logging sensitive user data

## Integration Examples

### Firebase Analytics (Complete Setup)

```swift
import FirebaseCore
import FirebaseAnalytics
import SwapFoundationKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.ApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // Configure Firebase
        FirebaseApp.configure()
        
        // Setup analytics
        AppAnalytics.shared.setupAnalytics()
        
        return true
    }
}

// Firebase-specific logger with error handling
class FirebaseAnalyticsLogger: AnalyticsLogger {
    func logEvent(event: AnalyticsEvent, parameters: [String: String]?) {
        do {
            var firebaseParams: [String: Any] = [:]
            
            if let parameters = parameters {
                for (key, value) in parameters {
                    // Firebase has a 40-character limit for parameter keys
                    let truncatedKey = String(key.prefix(40))
                    firebaseParams[truncatedKey] = value
                }
            }
            
            Analytics.logEvent(event.rawValue, parameters: firebaseParams)
            
        } catch {
            print("❌ Firebase Analytics Error: \(error)")
        }
    }
}
```

### Amplitude Analytics

```swift
import Amplitude
import SwapFoundationKit

class AmplitudeAnalyticsLogger: AnalyticsLogger {
    private let amplitude: Amplitude
    
    init(apiKey: String) {
        self.amplitude = Amplitude.instance()
        self.amplitude.initializeApiKey(apiKey)
    }
    
    func logEvent(event: AnalyticsEvent, parameters: [String: String]?) {
        var eventProperties: [String: Any] = [:]
        
        if let parameters = parameters {
            for (key, value) in parameters {
                eventProperties[key] = value
            }
        }
        
        amplitude.logEvent(event.rawValue, withEventProperties: eventProperties)
    }
}
```

This analytics system provides a clean, extensible foundation for tracking user behavior across your app while maintaining type safety and testability.
