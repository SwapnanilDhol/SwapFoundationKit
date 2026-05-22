# Refactoring TODO

Internal SFK improvements tracked for future work. These do not affect public API.

## Priority: High

### 1. Split Large Extension Files

| File | Status | Notes |
|------|--------|-------|
| `UIColor+.swift` | Done | Added RGBA struct, made hex init optional, added Adjustment enum |
| `String+.swift` | Done | Consolidated duplicates, reduced from 444 to 229 lines |
| `Date+Extensions.swift` | Done | Cached formatters and calendar |

**All large extension files have been refactored.**

### 2. DateFormatter Performance

| Issue | Location | Recommendation |
|-------|----------|----------------|
| 17+ DateFormatter instances created repeatedly | `Date+Extensions.swift` | Use cached formatters as static properties |
| Calendar.current accessed 18+ times | `Date+Extensions.swift` | Cache as static property |

**Why**: Creating DateFormatter is expensive; repeated access to Calendar.current is wasteful.

---

## Priority: Medium

### 3. ConfigurationService Refactor

| File | Lines | Recommendation |
|------|-------|----------------|
| `ConfigurationService.swift` | 418 | Extract convenience methods into separate helpers |

**Why**: Large service with multiple responsibilities.

### 4. NetworkError Consolidation

| Status | Notes |
|--------|-------|
| Not an issue | `NetworkError` is defined once in `Networking.swift`. `NetworkService.swift` references it. `HTTPClientError` is a typealias, not a duplicate. |

### 5. HTTPClient vs NetworkService

| Issue | Recommendation |
|-------|----------------|
| Two overlapping networking abstractions | Clarify public API boundaries per [networking-rfc.md](../guides/networking-rfc.md) |

---

## Priority: Low

### 6. Small Protocol/Impl Consolidation

| Protocol | Implementation | Recommendation |
|----------|----------------|----------------|
| `ItemDetailSource.swift` | `DefaultItemDetailSource.swift` | Combine into single file |

**Why**: Tiny protocol with single implementation; consolidation improves discoverability.

### 7. URL Hardcoding

| Status | Notes |
|--------|-------|
| Done | `ExchangeRateManager` URL extracted to `defaultExchangeRateURL` constant with configurable `init(exchangeRateURL:)`. `AppMetaData` still has some hardcoded fallbacks. |

### 8. String Extension Naming

| Status | Notes |
|--------|-------|
| Done | Removed `isEmail` alias, removed `removingWhitespaces` duplicate. |

### 9. UserDefaults File Naming

| Files | Issue |
|-------|-------|
| `UserDefault.swift` vs `UserDefaults+.swift` | Pluralization inconsistency |

---

## Completed

| # | Issue | Resolution |
|---|-------|------------|
| 7 | URL Hardcoding in `ExchangeRateManager.swift` | Extracted to `ExchangeRateManager.defaultExchangeRateURL` constant. Added `init(exchangeRateURL:)` for custom URLs. |
| 8 | String Extension Naming | Removed `isEmail` alias (duplicate of `isValidEmail`). Removed `removingWhitespaces` (duplicate of `withoutWhitespace`). |
| 2 | DateFormatter/Date+Extensions performance | Added CachedFormatters struct with cached DateFormatter, ISO8601, and RelativeDateTimeFormatter instances. Cached Calendar.current as private var. Reduced file from 469 to 296 lines. |
| 1 | UIColor+.swift (434 lines) | Added RGBAColorComponents struct for structured component access. Made UIColor(hex:) return optional. Added Adjustment enum for type-safe color adjustments. Consolidated gradient and component methods. Reduced from 434 to 328 lines. |

### New Additions (2026-05-20)

| # | Capability | Description |
|---|-----------|-------------|
| A1 | SecurityService encryption fix | Replaced random-key-per-call `generateEncryptionKey()` with persistent Keychain-stored key via `persistentEncryptionKey()`. |
| A2 | Access control audit | Made 6 internal types public: `DeviceInfo`, `Throttler`/`AsyncThrottler`, `JSONCodable`/`JSONCodingError`, `FileManager+`, `Result+`, `CGTypes+`. |
| A3 | ExchangeRateManager enhancements | Added configurable URL init, 5-min cache TTL, exponential backoff retry (3 attempts), HTTP status validation. |
| A4 | New capabilities extracted from host apps | Added 14 new public types: `SFKAppEnvironment`, `SFKLaunchArguments`, `SFKAppearanceManager`, `SFKRoundedHostingController`, `SFKProGate`, `SFKNotificationService`, `SFKFirebaseLogger`, `SFKTelemetryLogger`, `SFKImageCompressor`, `Collection+Async`, enhanced `Currency` sorting/formatting, `Coordinator` dismiss/presentItemPicker. (`SFKPostHogLogger` later removed — host apps should implement their own PostHog `AnalyticsLogger`.) |
| A5 | Host app duplicate cleanup | Deleted 14 duplicate files across PassMaker, SubscriptionTracker, and MoneyTracker. |

---

## File Organization

### Settings Module (14 files)
`Sources/SwapFoundationKit/UI/Settings/` is intentionally fragmented for modular imports. Each row type is a separate file to avoid forcing consumers to import the entire module.

### UIKit vs SwiftUI Extensions
- `UIKitExtensions/`: 8 files — extensive UIKit helpers
- `SwiftUIExtensions/`: 1 file — glass compatibility only

This asymmetry is intentional. Glass compatibility is the only SwiftUI-specific need; everything else uses cross-framework patterns.
