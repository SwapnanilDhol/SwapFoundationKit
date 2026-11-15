# SwapFoundationKitGoogleMobileAds

Opt-in advertising product backed by Google Mobile Ads 13.6.0. Add the
`SwapFoundationKitGoogleMobileAds` product and `import SwapFoundationKitGoogleMobileAds`;
the default `SwapFoundationKit` product does not link the Google SDK. See the
[Google Mobile Ads guide](../../Docs/guides/google-mobile-ads.md) for setup.

## Public API

| Type | Kind | Description |
|------|------|-------------|
| `AdsManager` | class | Starts the provider, preloads placements, presents interstitial and rewarded ads, vends banner controllers |
| `AdaptiveBannerAdView` | struct | SwiftUI adaptive banner |
| `AdsConfiguration` | struct | Provider, ad units, preload set, eligibility, presenting view controller, event handler |
| `AdUnitConfiguration` | struct | Banner, interstitial, and rewarded ad unit IDs |
| `AdPlacement` | enum | `.banner`, `.interstitial`, `.rewarded` |
| `AdLifecycleEvent` | enum | `.loaded`, `.failed`, `.impression`, `.click`, `.dismissed` |
| `AdPresentationResult` | enum | `.shown`, `.skippedIneligible`, `.unavailable`, `.failed` |
| `AdsProviderConfiguration` | enum | Currently `.google(GoogleAdsConfiguration)` |

```swift
let configuration = AdsConfiguration(
    provider: .google(GoogleAdsConfiguration()),
    adUnits: AdUnitConfiguration(
        banner: "ca-app-pub-xxx/yyy",
        interstitial: "ca-app-pub-xxx/zzz"
    ),
    isEligibleToShowAds: { !entitlements.isPro },          // host-owned entitlement check
    presentingViewController: { UIApplication.topViewController() },
    eventHandler: { event in analytics.record(adEvent: event) } // host-owned analytics
)
await AdsManager.startIfNeeded(configuration: configuration)
```

Simulator builds use a stand-in provider: presentation returns `.unavailable` and
banners are empty, so test real ads on a device.

## Source Files

- `AdsManager.swift` — `AdsManager` and `AdaptiveBannerAdView`
- `AdsProvider.swift` — provider protocol and factory
- `GoogleAdsProvider.swift` — Google Mobile Ads implementation (device builds)
- `Configuration/AdsConfiguration.swift` — configuration types
