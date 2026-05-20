# Currency

Currency model with 35+ ISO 4217 codes, flags, symbols, formatting, sorting, locale detection, and exchange rate management.

## Public API

| Type | Kind | Description |
|------|------|-------------|
| `Currency` | enum | 35 currency cases with `symbol`, `currencySymbol`, `description` |
| `CurrencyRates` | struct | Thread-safe exchange rate dictionary |
| `ExchangeRateManager` | actor | ECB daily XML fetcher with JSON cache, retry, TTL |

### Currency Properties
| Property | Description |
|----------|-------------|
| `.symbol` | Country flag emoji (e.g., "🇺🇸") |
| `.currencySymbol` | Financial symbol (e.g., "$", "€", "₹") |
| `.description` | Localized full name |
| `.sortedAllCases` | All currencies sorted alphabetically |
| `.sortedWithMajorFirst` | Local currency first, then majors (USD/EUR/GBP/JPY/AUD), then rest |
| `.local` | Detects user's locale currency, falls back to USD |

### Currency Methods
| Method | Description |
|--------|-------------|
| `.formatAmount(_:)` | e.g., `USD.formatAmount(1234.56)` → `"$1,234.56"` |
| `.formatAbbreviated(_:)` | e.g., `INR.formatAbbreviated(150000)` → `"₹1.5K"` |

### ExchangeRateManager
| Method | Description |
|--------|-------------|
| `.start()` | Load cached rates, fetch from ECB if stale |
| `.convert(value:fromCurrency:toCurrency:)` | Cross-currency conversion |
| `.convertToBaseCurrency(amount:from:)` | Convert to EUR base |
| `.fetchAndCacheExchangeRates()` | Force re-fetch |
| `.cacheValidityInterval` | TTL in seconds (default: 300) |

```swift
await ExchangeRateManager.shared.start()
let usd = ExchangeRateManager.shared.convert(value: 100, fromCurrency: .EUR, toCurrency: .USD)

// Picker integration
Currency.sortedWithMajorFirst // Ready for SFKItemPickerView

// Formatting
Currency.local.formatAmount(42.99) // Uses user's locale currency
```

## Source Files

- `Currency.swift` — Currency enum with flags, symbols, sorting, formatting
- `ExchangeRateManager.swift` — ECB exchange rate management
