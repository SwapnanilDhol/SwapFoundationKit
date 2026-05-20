# Ads

Optional advertising module (requires `SwapFoundationKitGoogleMobileAds` product). Supports Google Mobile Ads with configurable ad units, placement types, eligibility checks, and lifecycle events.

## Public API

| Type | Kind | Description |
|------|------|-------------|
| `AdsConfiguration` | struct | Provider, ad units, preload set, eligibility, presenting VC, event handler |
| `AdUnitConfiguration` | struct | Banner, interstitial, and rewarded ad unit IDs |
| `AdPlacement` | enum | `.banner`, `.interstitial`, `.rewarded` |
| `AdLifecycleEvent` | enum | `.loaded`, `.failed`, `.impression`, `.click`, `.dismissed` |
| `AdPresentationResult` | enum | `.shown`, `.skippedIneligible`, `.unavailable`, `.failed` |
| `AdsProviderConfiguration` | enum | Currently `.google(GoogleAdsConfiguration)` |

```swift
let config = AdsConfiguration(
    provider: .google(GoogleAdsConfiguration()),
    adUnits: AdUnitConfiguration(
        banner: "ca-app-pub-xxx/yyy",
        interstitial: "ca-app-pub-xxx/zzz"
    ),
    isEligibleToShowAds: { !ProManager.shared.isProEnabled },
    presentingViewController: { UIApplication.topViewController() },
    eventHandler: { event in
        AnalyticsManager.shared.logEvent(event: .adEvent(event))
    }
)
```

## Source Files

- `AdsConfiguration.swift` — Configuration types
