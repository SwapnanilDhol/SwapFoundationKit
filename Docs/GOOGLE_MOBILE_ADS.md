# Google Mobile Ads (optional module)

The core **`SwapFoundationKit`** library does **not** depend on Google Mobile Ads. Ad integration lives in a separate SwiftPM product:

| Product | Purpose |
|--------|---------|
| `SwapFoundationKit` | Shared types only: `AdsConfiguration`, `AdUnitConfiguration`, `GoogleAdsConfiguration`, `AdPlacement`, etc. |
| `SwapFoundationKitGoogleMobileAds` | `AdsManager`, `AdaptiveBannerAdView`, Google SDK wiring |

## Xcode / SPM

1. Add the same `SwapFoundationKit` package URL.
2. Add library **`SwapFoundationKitGoogleMobileAds`** to targets that show ads.
3. Add Google’s **`GoogleMobileAds`** package to that target if you want an explicit pin (match the version in this repo’s `Package.swift`, currently **13.1.0**).
4. Set **`GADApplicationIdentifier`** in the app `Info.plist`.

## Migration from older SFK

**Removed (breaking):**

- `SwapFoundationKitConfiguration.adsConfiguration`
- `SwapFoundationKit.shared.adsManager`
- Automatic ad startup inside `SwapFoundationKit.start(with:)`

**Replace with:**

```swift
import SwapFoundationKit
import SwapFoundationKitGoogleMobileAds

// After SwapFoundationKit.shared.start(with: ...)
await AdsManager.startIfNeeded(configuration: adsConfiguration)
// or: await AdsManager.shared.start(with: adsConfiguration)
```

`AdsManager.startIfNeeded` matches the old behavior: no-op on **simulator** and during **SwiftUI previews**.

## Tests

- `SwapFoundationKitTests` — core only (no GoogleMobileAds binary).
- `SwapFoundationKitGoogleMobileAdsTests` — `AdsManager` and `startIfNeeded`.

Run both from the **SwapFoundationKit** scheme in Xcode, or:

```bash
xcodebuild test -scheme SwapFoundationKit -destination 'platform=iOS Simulator,name=iPhone 16'
```
