# SFKSettingsScreen Update Banner

`SFKSettingsScreen` can render `SFKUpdateAvailableBannerView` as a top inset banner, so apps do not need to manually wire `safeAreaInset` for update messaging.

## API

Both `SFKSettingsScreen` initializers support these optional parameters:

- `updateBannerVersion: Binding<String?>?`
- `updateBannerTheme: UpdateAvailableBannerTheme = .default`
- `updateBannerAppStoreID: String? = nil`
- `onUpdateBannerTap: (() -> Void)? = nil`

## Behavior

- The banner is shown when `updateBannerVersion.wrappedValue` is non-`nil`.
- Tapping the banner opens the App Store page via `SFKUpdateAvailableBannerView`.
- After tap, `SFKSettingsScreen` sets `updateBannerVersion.wrappedValue = nil`.
- `onUpdateBannerTap` runs after the binding is cleared, so apps can log analytics or clear mirrored state.

## Example

```swift
@State private var updateVersion: String? = "2.3.0"

SFKSettingsScreen(
    header: header,
    sections: sections,
    updateBannerVersion: $updateVersion,
    updateBannerTheme: .default,
    updateBannerAppStoreID: "123456789",
    onUpdateBannerTap: {
        analytics.track("update_banner_tapped")
    },
    onItemTap: handleTap(_:)
)
```

## Debug Forcing Pattern

If your app has a debug-only "show update banner" action, keep that state in the app/view model and map it into `updateBannerVersion`.

Recommended approach:

- Return debug forced version first.
- Fall back to actual update-check result.
- In binding setter (`nil`), clear both debug override and live update state.
