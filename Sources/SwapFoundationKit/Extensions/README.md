# Extensions

The Extensions folder contains Swift extensions that enhance standard library types with additional functionality and convenience methods.

## 📅 Date Extensions

Comprehensive date formatting and manipulation utilities.

### Features

- **📅 Multiple Formats** - Short, medium, long, and full date styles
- **⏰ Time Formatting** - 12-hour and 24-hour time formats
- **🔄 Relative Time** - Human-readable relative time strings
- **🔧 Date Components** - Easy access to year, month, day, etc.
- **📊 Date Calculations** - Today, yesterday, this week, etc.
- **⚙️ Date Manipulation** - Add days, months, years, start/end of periods

### Quick Start

```swift
import SwapFoundationKit

let date = Date()

// Basic formatting
print(date.shortDate)        // "1/15/24"
print(date.mediumDate)       // "Jan 15, 2024"
print(date.timeOnly)         // "10:30 AM"

// Custom formats
print(date.yyyyMMdd)         // "2024-01-15"
print(date.MMMddyyyy)        // "Jan 15, 2024"

// Relative time
print(date.relativeTime)     // "2 hours ago"

// Date components
print(date.year)             // 2024
print(date.monthName)        // "January"
print(date.weekdayName)      // "Monday"

// Date calculations
print(date.isToday)          // true/false
print(date.isThisWeek)       // true/false

// Date manipulation
let tomorrow = date.adding(days: 1)
let startOfDay = date.startOfDay
```

## 🔤 String Extensions

Enhanced string manipulation and utility methods.

### Features

- **🔍 Search & Replace** - Advanced search and replacement methods
- **📝 Validation** - Email, phone, URL validation
- **🔤 Formatting** - Case conversion, trimming, padding
- **📊 Analysis** - Character counting, word counting
- **🔗 URL Handling** - URL encoding/decoding, validation

### Quick Start

```swift
import SwapFoundationKit

let text = "  Hello World  "

// Basic operations
print(text.trimmed)          // "Hello World"
print(text.uppercased)       // "  HELLO WORLD  "
print(text.wordCount)        // 2

// Validation
let email = "user@example.com"
print(email.isValidEmail)    // true

let phone = "+1-555-123-4567"
print(phone.isValidPhone)    // true
```

## 🔢 Number Extensions

Number formatting and utility methods.

### Features

- **💰 Currency Formatting** - Localized currency display
- **📊 Number Formatting** - Decimal, percentage, scientific notation
- **🔢 Range Utilities** - Clamping, wrapping, validation
- **📈 Math Utilities** - Rounding, ceiling, floor operations

### Quick Start

```swift
import SwapFoundationKit

let number = 1234.5678

// Formatting
print(number.formattedCurrency)    // "$1,234.57"
print(number.formattedPercentage)  // "123,456.78%"
print(number.rounded(to: 2))      // 1234.57

// Range operations
let clamped = number.clamped(to: 0...1000)  // 1000.0
```

## 📚 Collection Extensions

Enhanced collection functionality.

### Features

- **🔍 Safe Access** - Safe subscript access with bounds checking
- **📊 Statistics** - Min, max, average, sum operations
- **🔄 Transformation** - Chunking, grouping, filtering utilities
- **📝 Validation** - Empty checks, size validation

### Quick Start

```swift
import SwapFoundationKit

let numbers = [1, 2, 3, 4, 5]

// Safe access
print(numbers[safe: 10])     // nil (instead of crash)

// Statistics
print(numbers.average)       // 3.0
print(numbers.sum)           // 15

// Chunking
let chunks = numbers.chunked(into: 2)
// [[1, 2], [3, 4], [5]]
```

## 📋 Bundle Extensions

Easy access to app metadata and configuration.

### Features

- **📱 App Info** - Version, build number, bundle identifier
- **🏷️ Display Name** - App display name and marketing version
- **🔧 Configuration** - Environment-specific configuration
- **📄 Info.plist** - Easy access to plist values

### Quick Start

```swift
import SwapFoundationKit

// App information
print(Bundle.main.appVersion)        // "1.0.0"
print(Bundle.main.buildNumber)       // "123"
print(Bundle.main.bundleIdentifier)  // "com.example.app"
print(Bundle.main.displayName)       // "My App"

// Configuration
let apiKey = Bundle.main.string(for: "API_KEY")
let isDebug = Bundle.main.bool(for: "DEBUG_MODE")
```

## 🎯 Usage Patterns

### Chaining Extensions

```swift
// Chain multiple extensions for powerful operations
let result = "  Hello World  "
    .trimmed
    .uppercased
    .replacingOccurrences(of: "WORLD", with: "Swift")
    .appending("!")
// Result: "HELLO SWIFT!"
```

### Conditional Operations

```swift
// Use extensions with conditional logic
let text = "user@example.com"
if text.isValidEmail {
    // Process valid email
    let domain = text.emailDomain
    print("Email domain: \(domain)")
}
```

### Performance Considerations

- **Lazy Evaluation** - Extensions use lazy evaluation where appropriate
- **Memory Efficient** - Avoid unnecessary string allocations
- **Optimized Operations** - Use native Swift methods for best performance

These extensions provide a rich set of utilities that make common operations more convenient and readable while maintaining high performance.
