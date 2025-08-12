# Currency System

The SwapFoundationKit provides a robust currency system with real-time exchange rates, comprehensive currency support, and easy-to-use conversion utilities. Built with modern Swift concurrency and powered by European Central Bank (ECB) data.

## 🌍 Features

- **🔄 Real-time Exchange Rates** - Live rates from ECB with automatic caching
- **💱 40+ Supported Currencies** - Major world currencies with symbols and flags
- **📱 Actor-based Architecture** - Thread-safe currency operations
- **💾 Intelligent Caching** - Offline support with fallback rates
- **🎯 Easy Conversion** - Simple API for currency conversions
- **🏳️ Localized Support** - Currency names in multiple languages
- **⚡ Performance Optimized** - Efficient XML parsing and caching

## 📋 Supported Currencies

The system supports 40+ currencies including:

| Currency | Code | Symbol | Flag | Name |
|----------|------|--------|------|------|
| Euro | EUR | € | 🇪🇺 | Euro |
| US Dollar | USD | $ | 🇺🇸 | US Dollar |
| British Pound | GBP | £ | 🇬🇧 | Pound Sterling |
| Japanese Yen | JPY | ¥ | 🇯🇵 | Japanese Yen |
| Indian Rupee | INR | ₹ | 🇮🇳 | Indian rupee |
| Australian Dollar | AUD | A$ | 🇦🇺 | Australian dollar |
| Canadian Dollar | CAD | CA$ | 🇨🇦 | Canadian dollar |
| Swiss Franc | CHF | CHF | 🇨🇭 | Swiss franc |
| Chinese Yuan | CNY | CN¥ | 🇨🇳 | Chinese yuan renminbi |
| Singapore Dollar | SGD | SGD | 🇸🇬 | Singapore dollar |

*View all supported currencies in the `Currency.swift` file*

## 🚀 Quick Start

### 1. Initialize the Exchange Rate Manager

```swift
import SwapFoundationKit

// Start the exchange rate manager (call this on app launch)
await ExchangeRateManager.shared.start()
```

### 2. Basic Currency Conversion

```swift
import SwapFoundationKit

// Convert 100 EUR to USD
let usdAmount = ExchangeRateManager.shared.convert(
    value: 100.0,
    fromCurrency: .EUR,
    toCurrency: .USD
)

print("€100 = $\(usdAmount)") // Output: €100 = $108.50
```

### 3. Convert to Base Currency (EUR)

```swift
// Convert 100 USD to EUR (base currency)
let eurAmount = ExchangeRateManager.shared.convertToBaseCurrency(
    amount: 100.0,
    from: .USD
)

print("$100 = €\(eurAmount)") // Output: $100 = €92.59
```

## 📱 Complete Usage Example

```swift
import SwapFoundationKit
import SwiftUI

class CurrencyConverterViewModel: ObservableObject {
    @Published var amount: String = "100"
    @Published var fromCurrency: Currency = .EUR
    @Published var toCurrency: Currency = .USD
    @Published var convertedAmount: Double = 0.0
    @Published var isLoading = false
    
    private let exchangeManager = ExchangeRateManager.shared
    
    func convertCurrency() async {
        isLoading = true
        
        // Ensure exchange rates are loaded
        await exchangeManager.start()
        
        guard let amountValue = Double(amount) else {
            isLoading = false
            return
        }
        
        // Perform conversion
        let result = exchangeManager.convert(
            value: amountValue,
            fromCurrency: fromCurrency,
            toCurrency: toCurrency
        )
        
        await MainActor.run {
            convertedAmount = result
            isLoading = false
        }
    }
}

struct CurrencyConverterView: View {
    @StateObject private var viewModel = CurrencyConverterViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            // Amount Input
            TextField("Amount", text: $viewModel.amount)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.decimalPad)
            
            // Currency Selection
            HStack {
                Picker("From", selection: $viewModel.fromCurrency) {
                    ForEach(Currency.allCases, id: \.self) { currency in
                        HStack {
                            Text(currency.symbol)
                            Text(currency.rawValue)
                            Text(currency.currencySymbol)
                        }
                        .tag(currency)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                
                Image(systemName: "arrow.right")
                
                Picker("To", selection: $viewModel.toCurrency) {
                    ForEach(Currency.allCases, id: \.self) { currency in
                        HStack {
                            Text(currency.symbol)
                            Text(currency.rawValue)
                            Text(currency.currencySymbol)
                        }
                        .tag(currency)
                    }
                }
                .pickerStyle(MenuPickerStyle())
            }
            
            // Convert Button
            Button("Convert") {
                Task {
                    await viewModel.convertCurrency()
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.isLoading)
            
            // Result
            if viewModel.isLoading {
                ProgressView()
            } else {
                VStack {
                    Text("Result")
                        .font(.headline)
                    Text("\(viewModel.amount) \(viewModel.fromCurrency.currencySymbol)")
                        .font(.title2)
                    Text("=")
                        .font(.title3)
                    Text("\(viewModel.convertedAmount, specifier: "%.2f") \(viewModel.toCurrency.currencySymbol)")
                        .font(.title)
                        .foregroundColor(.green)
                }
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle("Currency Converter")
    }
}
```

## 🔧 Advanced Usage

### Custom Currency Display

```swift
import SwapFoundationKit

struct CurrencyDisplayView: View {
    let currency: Currency
    let amount: Double
    
    var body: some View {
        HStack {
            // Flag emoji
            Text(currency.symbol)
                .font(.title2)
            
            // Currency code
            Text(currency.rawValue)
                .font(.caption)
                .foregroundColor(.secondary)
            
            // Amount with currency symbol
            Text("\(amount, specifier: "%.2f") \(currency.currencySymbol)")
                .font(.headline)
            
            // Full currency name
            Text(currency.description)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

// Usage
CurrencyDisplayView(currency: .USD, amount: 99.99)
// Output: 🇺🇸 USD $99.99 US Dollar
```

### Batch Currency Conversion

```swift
import SwapFoundationKit

class BatchCurrencyConverter {
    private let exchangeManager = ExchangeRateManager.shared
    
    func convertBatch(
        amounts: [Double],
        fromCurrency: Currency,
        toCurrency: Currency
    ) async -> [Double] {
        // Ensure rates are loaded
        await exchangeManager.start()
        
        return amounts.map { amount in
            exchangeManager.convert(
                value: amount,
                fromCurrency: fromCurrency,
                toCurrency: toCurrency
            )
        }
    }
    
    func convertToMultipleCurrencies(
        amount: Double,
        fromCurrency: Currency,
        toCurrencies: [Currency]
    ) async -> [Currency: Double] {
        await exchangeManager.start()
        
        var results: [Currency: Double] = [:]
        for toCurrency in toCurrencies {
            let converted = exchangeManager.convert(
                value: amount,
                fromCurrency: fromCurrency,
                toCurrency: toCurrency
            )
            results[toCurrency] = converted
        }
        
        return results
    }
}

// Usage
let converter = BatchCurrencyConverter()

// Convert multiple amounts
let amounts = [10.0, 25.0, 50.0, 100.0]
let convertedAmounts = await converter.convertBatch(
    amounts: amounts,
    fromCurrency: .EUR,
    toCurrency: .USD
)

// Convert to multiple currencies
let currencies: [Currency] = [.USD, .GBP, .JPY, .INR]
let multiCurrencyResults = await converter.convertToMultipleCurrencies(
    amount: 100.0,
    fromCurrency: .EUR,
    toCurrencies: currencies
)

for (currency, amount) in multiCurrencyResults {
    print("€100 = \(currency.currencySymbol)\(amount, specifier: "%.2f")")
}
```

### Currency Rate Monitoring

```swift
import SwapFoundationKit
import Combine

class CurrencyRateMonitor: ObservableObject {
    @Published var currentRates: [Currency: Double] = [:]
    private let exchangeManager = ExchangeRateManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        startMonitoring()
    }
    
    func startMonitoring() {
        // Monitor rates every 5 minutes
        Timer.publish(every: 300, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                Task {
                    await self?.refreshRates()
                }
            }
            .store(in: &cancellables)
    }
    
    @MainActor
    private func refreshRates() async {
        await exchangeManager.start()
        // Note: In a real implementation, you'd need to expose rates publicly
        // or create a publisher for real-time updates
    }
    
    func getRate(for currency: Currency) -> Double? {
        return currentRates[currency]
    }
    
    func getFormattedRate(for currency: Currency) -> String {
        guard let rate = getRate(for: currency) else {
            return "N/A"
        }
        
        return "\(currency.currencySymbol)\(rate, specifier: "%.4f")"
    }
}
```

## 🏗️ Architecture

### Exchange Rate Manager

The `ExchangeRateManager` is built as an actor to ensure thread-safe operations:

- **Singleton Pattern** - `ExchangeRateManager.shared` for app-wide access
- **Actor Isolation** - Thread-safe currency operations
- **Automatic Caching** - JSON-based local storage with fallback rates
- **XML Parsing** - Efficient ECB data parsing
- **Error Handling** - Graceful fallback to cached or default rates

### Currency Enum

The `Currency` enum provides:

- **Raw Values** - ISO 4217 currency codes
- **Localized Names** - Human-readable currency names
- **Symbols** - Currency symbols (€, $, £, etc.)
- **Flags** - Country flag emojis
- **Case Iterable** - Easy iteration for UI components

## 📊 Data Sources

### European Central Bank (ECB)

- **Source**: `https://www.ecb.europa.eu/stats/eurofxref/eurofxref-daily.xml`
- **Update Frequency**: Daily (business days)
- **Base Currency**: Euro (EUR)
- **Format**: XML with currency codes and rates

### Fallback Rates

Built-in fallback rates for offline scenarios:

```swift
// Access fallback rates
let fallbackRates = Currency.fallBackExchangeRates.rates

// Use specific fallback rate
let usdRate = fallbackRates[.USD] // 1.08
```

## 🔒 Caching Strategy

### Cache Location

```swift
// Cache is stored in app's Documents directory
private var cacheFileURL: URL {
    let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    return dir.appendingPathComponent("exchangeRatesCache.json")
}
```

### Cache Lifecycle

1. **App Launch** - Load cached rates if available
2. **Network Request** - Fetch fresh rates from ECB
3. **Cache Update** - Store new rates locally
4. **Fallback** - Use fallback rates if cache is empty

## 🧪 Testing

### Mock Exchange Rate Manager

```swift
class MockExchangeRateManager: ExchangeRateManager {
    var mockRates: [Currency: Double] = [:]
    
    override func start() async {
        // Use mock rates instead of fetching from network
        exchangeRates = mockRates.isEmpty ? Currency.fallBackExchangeRates.rates : mockRates
    }
    
    func setMockRates(_ rates: [Currency: Double]) {
        mockRates = rates
    }
}

// In your tests
class CurrencyTests: XCTestCase {
    var mockManager: MockExchangeRateManager!
    
    override func setUp() {
        super.setUp()
        mockManager = MockExchangeRateManager()
        
        // Set up test rates
        let testRates: [Currency: Double] = [
            .EUR: 1.0,
            .USD: 1.10,
            .GBP: 0.85
        ]
        mockManager.setMockRates(testRates)
    }
    
    func testCurrencyConversion() async {
        await mockManager.start()
        
        let result = mockManager.convert(
            value: 100.0,
            fromCurrency: .EUR,
            toCurrency: .USD
        )
        
        XCTAssertEqual(result, 110.0, accuracy: 0.01)
    }
}
```

## 🚨 Error Handling

### Network Failures

```swift
// The system gracefully handles network failures
do {
    let (data, _) = try await URLSession.shared.data(from: exchangeRateURL)
    // Process data
} catch {
    Logger.error("Failed to fetch exchange rates: \(error)")
    // System continues with cached or fallback rates
}
```

### Invalid Currencies

```swift
// Safe currency conversion with validation
func safeConvert(
    value: Double,
    fromCurrency: Currency,
    toCurrency: Currency
) -> Double? {
    guard let valueRate = exchangeRates[fromCurrency],
          let outputRate = exchangeRates[toCurrency] else {
        return nil // Return nil for invalid conversions
    }
    
    let multiplier = outputRate / valueRate
    return value * multiplier
}
```

## 📱 SwiftUI Integration

### Currency Picker

```swift
struct CurrencyPicker: View {
    @Binding var selectedCurrency: Currency
    let title: String
    
    var body: some View {
        Picker(title, selection: $selectedCurrency) {
            ForEach(Currency.allCases, id: \.self) { currency in
                HStack {
                    Text(currency.symbol)
                    Text(currency.rawValue)
                    Text(currency.currencySymbol)
                }
                .tag(currency)
            }
        }
        .pickerStyle(MenuPickerStyle())
    }
}

// Usage
@State private var selectedCurrency: Currency = .USD

CurrencyPicker(
    selectedCurrency: $selectedCurrency,
    title: "Select Currency"
)
```

### Currency Display

```swift
struct CurrencyAmountView: View {
    let amount: Double
    let currency: Currency
    
    var body: some View {
        HStack(spacing: 8) {
            Text(currency.symbol)
                .font(.title2)
            
            Text("\(amount, specifier: "%.2f")")
                .font(.title)
                .fontWeight(.semibold)
            
            Text(currency.currencySymbol)
                .font(.title3)
                .foregroundColor(.secondary)
        }
    }
}
```

## 🔧 Configuration

### Custom Cache Duration

```swift
// Modify cache behavior (requires extending ExchangeRateManager)
extension ExchangeRateManager {
    private var cacheExpirationInterval: TimeInterval {
        return 24 * 60 * 60 // 24 hours
    }
    
    private func isCacheExpired() -> Bool {
        // Implement cache expiration logic
        return false
    }
}
```

### Custom Exchange Rate Sources

```swift
// Create custom exchange rate manager
class CustomExchangeRateManager: ExchangeRateManager {
    private let customURL = URL(string: "https://your-api.com/rates")!
    
    override func cacheExchangeRates() async {
        // Implement custom rate fetching logic
        // You can override this method to use different data sources
    }
}
```

## 📈 Performance Considerations

### Memory Management

- **Efficient XML Parsing** - Stream-based parsing for large datasets
- **Minimal Memory Footprint** - Only essential data stored in memory
- **Automatic Cleanup** - Cache management with file system

### Network Optimization

- **Single Request** - One API call per app session
- **Intelligent Caching** - Avoid unnecessary network requests
- **Background Updates** - Non-blocking rate updates

## 🌐 Internationalization

### Localized Currency Names

```swift
// Currency names are localized using LocalizedStringKey
public var description: LocalizedStringKey {
    switch self {
    case .EUR: return "Euro"
    case .USD: return "US Dollar"
    // ... more currencies
    }
}
```

### Locale-Aware Formatting

```swift
import Foundation

extension Currency {
    func formatAmount(_ amount: Double, locale: Locale = .current) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = rawValue
        formatter.locale = locale
        
        return formatter.string(from: NSNumber(value: amount)) ?? "\(amount)"
    }
}

// Usage
let amount = Currency.USD.formatAmount(99.99, locale: Locale(identifier: "en_US"))
// Output: "$99.99"

let germanAmount = Currency.EUR.formatAmount(99.99, locale: Locale(identifier: "de_DE"))
// Output: "99,99 €"
```

This currency system provides a robust, performant foundation for handling international currencies in your iOS, macOS, and watchOS applications with real-time exchange rates and comprehensive currency support.
