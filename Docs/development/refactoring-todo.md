# Refactoring TODO

Open follow-ups after the 4.0.0 cleanup. Git history holds the completed items.

## Behaviour bugs (need a fix and a test; deliberately left out of 4.0.0)

| Area | Location | Problem |
|------|----------|---------|
| AES encryption | `Sources/SwapFoundationKit/Core/SecurityService.swift` (`AESEncryption`) | Ignores `dataOutMoved`, so ciphertext and plaintext keep trailing zero bytes; uses a nil IV; lets `withUnsafeBytes` base addresses escape. Round-trips likely fail for inputs that are not a multiple of 16 bytes. No tests. Fixing it changes the wire format of anything already encrypted. |
| Credit card validation | `Sources/SwapFoundationKit/Extensions/String+.swift` (`isValidCreditCard`) | `isNumbers` accepts any Unicode decimal digit, so `Int(String($0))!` can crash on, for example, Arabic-Indic digits. |
| Toast overlap | `Sources/SwapFoundationKitToast/ToastManager.swift` (`show`) | Passes `config.autoHide` as `allowToastOverlap`. |
| Authenticated requests | `Sources/SwapFoundationKitAuthentication/Authentication/URLRequestSnapshot.swift` | Not verified: no `explicitURL` and `parameters` is nil, so the query string may be dropped when the URL is rebuilt. |
| Exchange rate cache | `Sources/SwapFoundationKitCurrency/Currency/ExchangeRateManager.swift` | Not verified: parser callbacks start unawaited tasks, so the cache may be saved before all rates are merged. |
| Header merge | `Sources/SwapFoundationKitAuthentication/Authentication/AuthenticatedHTTPClient.swift` (`merge`) | Not verified: merges header names case-sensitively, unlike `sfkMergedHTTPHeaders`. |
| App Store URL | `Sources/SwapFoundationKit/Protocols/AppMetaData.swift` | Not verified: builds the URL from the bundle ID where the numeric App Store ID belongs. |

## Public API leftovers (need a breaking or additive release)

| Item | Notes |
|------|-------|
| `SFKButtonStyle.toolbar` | Deprecated alias for `.borderless`; no callers remain in this repo. |
| `DeviceInfo` | Public enum whose members are all internal, so hosts cannot use it. Either make the members public or remove the type. |
| Redundant `@available(iOS 16, *)` and similar on public types | The package minimum is iOS 17. |
| `UIColor.rgbComponents()` | Marked as legacy; `RGBAColorComponents` replaces it. |
| `String.localizedResource` | Still carries `@available(macOS 13.0, *)` from macOS support. |

## Internal cleanup

| Item | Notes |
|------|-------|
| `HTTPClient` vs `NetworkService` | `NetworkService` is a `@MainActor` facade over `HTTPClient`; document when to pick each. |
| Origin parsing | `NetworkService`'s `HTTPOrigin`, `AuthenticatedOrigin`, `AuthenticatedHTTPClient.isApproved` and the two redirect delegates each parse origins separately. |
| Ads provider | `GoogleAdsProvider`'s interstitial and rewarded load/present pairs are near-identical; that file only compiles for device builds. |
| File naming | `UserDefault.swift` vs `UserDefaults+.swift`; extension files mix `X+.swift`, `X+Extensions.swift` and `X+Topic.swift`. |
| `ItemDetailSource.swift` / `DefaultItemDetailSource.swift` | Tiny protocol and its only implementation could share a file. |
| Large files | `Networking.swift`, `AuthenticatedSessionService.swift`, `SFKTextField.swift` exceed ~600 lines. |

## Tooling and CI

| Item | Notes |
|------|-------|
| CI coverage | `.github/workflows/ci.yml` builds only the host app, which links 2 of 11 products, and runs no tests. |
| Toolchain-dependent tests | `SFKButtonColorResolverTests` expects `Color.red`/`.yellow` to resolve to pure RGB; the iOS 27 SDK returns `#FF4245`/`#FFCC00`. |

## File Organization

### Settings Module
`Sources/SwapFoundationKit/UI/Settings/` is intentionally fragmented: each row type is a separate file.

### UIKit vs SwiftUI Extensions
`UIKitExtensions/` holds the UIKit helpers; `SwiftUIExtensions/` holds glass and scroll-edge helpers only. This asymmetry is intentional.
