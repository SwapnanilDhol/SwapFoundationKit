# Settings UI

Guide for building host-app settings screens with SwapFoundationKit's settings components and the new theme system.

## What SFK provides

The settings module is split into:

- `SFKSettingsScreen` for a shared `Form`-based shell with sections, headers, and footers
- `SFKSettingsTheme` for injected colors, typography, and sizing
- `SFKSettingsRow` and `SFKSettingsLabel` for static/tappable rows
- `SFKSettingsToggle`, `SFKSettingsToggleRow`, `SFKSettingsDatePickerRow`, `SFKSettingsTimePickerRow`, `SFKSettingsInlineDatePicker`, `SFKSettingsPickerRow`, `SFKSettingsPickerSheetRow`, `SFKSettingsStepperRow`, `SFKSettingsSliderRow`, `SFKSettingsColorPickerRow`, and `SFKSettingsInlineColorPicker` for interactive controls
- `SFKInformationSectionItem` and `SFKDeveloperSectionItem` for common reusable items
- `SFKSettingsActionHandler`, `SFKInformationSectionHandler`, and `SFKDeveloperSectionHandler` for standard URL/share/review actions

## Recommended host-app structure

Use `SFKSettingsScreen` when your screen is mostly made of tappable `SettingsItem` rows and a few custom control sections.

```swift
import SwiftUI
import SwapFoundationKit

private enum AppSettingsItem: String, CaseIterable, SettingsItem {
    case notifications
    case changelog

    var id: String { rawValue }
    var icon: String {
        switch self {
        case .notifications: return "bell.badge.fill"
        case .changelog: return "sparkles"
        }
    }
    var title: String {
        switch self {
        case .notifications: return "Notifications"
        case .changelog: return "Release Notes"
        }
    }
    var subtitle: String {
        switch self {
        case .notifications: return "Manage notification preferences."
        case .changelog: return "See what changed in the latest update."
        }
    }
    var tint: Color {
        switch self {
        case .notifications: return .blue
        case .changelog: return .orange
        }
    }
}

struct SettingsView: View {
    @State private var notificationsEnabled = true

    private let theme = SFKSettingsTheme(
        colors: .init(
            accent: .mint,
            itemTintBehavior: .useAccent,
            toggleOnTint: .mint,
            sliderTint: .mint
        )
    )

    var body: some View {
        SFKSettingsScreen(
            customSections: [
                SFKSettingsCustomSection(title: "Quick Controls") {
                    SFKSettingsToggle(
                        title: "Push Notifications",
                        subtitle: "Enable app alerts.",
                        icon: "bell.badge.fill",
                        isOn: $notificationsEnabled
                    )
                }
            ],
            sections: [
                SFKSettingsSectionConfiguration(
                    title: "App Information",
                    items: AppSettingsItem.allCases + SFKInformationSectionItem.allCases
                )
            ],
            theme: theme,
            onItemTap: handleTap(_:)
        )
    }

    private func handleTap(_ item: any SettingsItem) {
        // Route app-specific and SFK-provided items here.
    }
}
```

## How section composition works

`SFKSettingsScreen` supports two kinds of sections:

- `sections`: arrays of `SettingsItem` values rendered as `SFKSettingsRow`
- `customSections`: arbitrary SwiftUI content for controls like toggles, sliders, color pickers, or mixed layouts

This is the current public composition model. If your screen mixes static rows and interactive controls, it is normal to use both.

## Theme injection

`SFKSettingsTheme` is the screen-level configuration point for settings UI.

It contains:

- `colors`
- `typography`
- `metrics`

You can inject it in two ways:

1. Pass it to `SFKSettingsScreen(theme: ...)`
2. Apply `.sfkSettingsTheme(theme)` to any custom settings container if you are composing rows manually

```swift
let theme = SFKSettingsTheme(
    colors: .init(
        accent: .teal,
        itemTintBehavior: .useAccent,
        toggleOnTint: .teal,
        sliderTint: .teal
    ),
    typography: .init(
        titleFont: .body.weight(.bold),
        subtitleFont: .callout
    ),
    metrics: .init(
        iconTileSize: 36,
        rowVerticalPadding: 8
    )
)
```

## How color precedence works

Colors are resolved in this order:

1. Explicit row tint when a row initializer receives `tint:`
2. Theme role color such as `toggleOnTint` or `sliderTint`
3. Theme `accent`

For `SettingsItem`-driven rows, `SFKSettingsTheme.Colors.ItemTintBehavior` controls whether the screen preserves each item's own `tint` or replaces them with the shared theme accent.

```swift
colors: .init(
    accent: .mint,
    itemTintBehavior: .useAccent
)
```

Use `.useAccent` when you want a uniform settings screen.

Use `.preserveItemTint` when you want rows like privacy, developer, or destructive actions to keep distinct colors.

## What the theme can customize

### Colors

- `accent`
- `itemTintBehavior`
- `toggleOnTint`
- `sliderTint`
- `titleColor`
- `subtitleColor`
- `valueColor`
- `accessoryColor`
- `destructiveTint`
- `iconBackgroundOpacity`
- `swatchBorderColor`

### Typography

- `iconFont`
- `titleFont`
- `subtitleFont`
- `valueFont`
- `accessoryFont`

### Metrics

- `iconTileSize`
- `iconCornerRadius`
- `rowSpacing`
- `labelSpacing`
- `trailingSpacing`
- `rowVerticalPadding`
- `colorSwatchSize`

## Common patterns

### Add trailing values

Use `rowTrailingBuilder` when you want `SFKSettingsScreen` rows to show dynamic values such as version, last sync, or selected units.

```swift
rowTrailingBuilder: { item in
    if let item = item as? SFKInformationSectionItem, item == .version {
        return AnyView(
            Text("2.2.0 (1)")
        )
    }
    return nil
}
```

### Hide chevrons selectively

Use `rowChevronBuilder` when some rows are informational and should not look navigable.

```swift
rowChevronBuilder: { item in
    if let item = item as? SFKInformationSectionItem, item == .version {
        return false
    }
    return true
}
```

### Use the built-in information/developer items

Use `SFKInformationSectionItem.allCases` and `SFKDeveloperSectionItem.allCases` when you want shared app-info and developer sections without redefining those rows in every host app.

## Integration audit

Use the checklist in [Settings Integration Checklist](../reference/settings-integration-checklist.md) after wiring a host app.

## Preview entry points

The fastest files to inspect in Xcode previews are:

- `Sources/SwapFoundationKit/UI/Settings/SFKSettingsScreen.swift`
- `Sources/SwapFoundationKit/UI/Settings/SFKSettingsPickerRow.swift`
- `Sources/SwapFoundationKit/UI/Settings/SFKSettingsDatePickerRow.swift`
- `Sources/SwapFoundationKit/UI/Settings/SFKSettingsColorPickerRow.swift`
