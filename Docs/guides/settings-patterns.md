# Settings Patterns

Practical patterns and architectural learnings for building settings screens with `SFKSettingsScreen`. These are app-agnostic — apply them regardless of what your app does.

## Section architecture

### Prefer `SFKSettingsSectionConfiguration` over custom sections

Any tappable row that fits the icon-title-subtitle-chevron shape should be a `SettingsItem` value placed in `sections:`, not hand-rolled in `customSections:`. This gives you consistent row rendering, theme-aware typography, and automatic chevron handling — for free.

```swift
// Good: SettingsItem in a section config
SFKSettingsSectionConfiguration(title: "Information", items: allItems)

// Avoid: ForEach + SFKSettingsRow in a custom section (unless forced)
SFKSettingsCustomSection(title: "Information") {
    ForEach(allItems, id: \.id) { item in
        SFKSettingsRow(item: item) { handleTap(item) }
    }
}
```

**When a custom section is appropriate:**
- Toggles, sliders, pickers, date pickers, or other interactive controls
- A section that mixes a toggle with tappable rows (e.g. a debug section with a "Force Pro" switch followed by debug action rows)
- Content that doesn't fit the `SettingsItem` shape at all

### One section header per logical group

Never create two sections with the same title. If two pieces of content belong to the same logical group, put them in the same section. When one half is a custom section (e.g. a toggle) and the other is `SettingsItem` rows, consolidate them into a single `SFKSettingsCustomSection` that renders both:

```swift
SFKSettingsCustomSection(title: "Debug") {
    SFKSettingsToggle(...)
    ForEach(SettingsItems.debug, id: \.id) { item in
        SFKSettingsRow(item: item) { handleDebugTap(item) }
    }
}
```

## Trailing values

### Use `SFKSettingsTrailing` enum

Never return `AnyView(Text(...).font(...).foregroundStyle(...))` from `rowTrailingBuilder`. The `SFKSettingsTrailing` enum provides type-safe trailing content that automatically uses the theme's `valueFont` and `valueColor`:

```swift
rowTrailingBuilder: { item in
    switch item {
    case let infoItem as AppInfoItem where infoItem == .version:
        return .value("2.0.0 (42)")
    case let appItem as AppSettingsItem where appItem == .userName:
        return .value(userDisplayName)
    default:
        return nil
    }
}
```

Use `.custom(AnyView(...))` only when you genuinely need layout or styling that `.value` can't express.

## Item tap routing

### Use `switch` with type-casting, never if-let chains

When routing taps from `onItemTap` on `SFKSettingsScreen`, use a single `switch` with type-casting `case` patterns:

```swift
onItemTap: { item in
    switch item {
    case let appItem as AppSettingsItem: handleAppSettings(appItem)
    case let infoItem as InfoItem: handleInfo(infoItem)
    case let devItem as DevItem: handleDev(devItem)
    default: break
    }
}
```

Never chain `if let x = item as? A { ... } else if let x = item as? B { ... }`.

The same rule applies to `rowTrailingBuilder`, `rowChevronBuilder`, and any closure that dispatches on the concrete type of an existential `SettingsItem`.

## Debug menus

### Gate debug items behind a build configuration flag

Debug items (force flags, data seeding, notification testing, dangerous operations) must never appear in production builds. Use a compile-time flag:

```swift
if Configuration.showDebugUtilities {
    // Append debug section to customSections
}
```

### Consolidate dangerous operations into the debug section

Operations like "delete all data", "reset all preferences", or "load stress test data" should live inside the debug section — never in a production-visible section with an innocent-sounding name. A separate "Danger Zone" section implies these are normal user-facing features, which they are not.

### Put all debug items in one section

A single section titled "Debug" (or similar) at the bottom of the screen is the standard pattern. Don't scatter debug items across multiple sections, and don't leave debug toggle rows orphaned in untitled sections.

## Presentation ownership

### Sheets, modals, and alerts belong to the coordinator

Do not drive presentations from `@State` in the view. The view should call a coordinator method:

```swift
// In the view: trigger via ViewModel
viewModel.coordinator.presentDebugNotifications(viewModel: viewModel)

// In the coordinator: owns the presentation
func presentDebugNotifications(viewModel: SettingsViewModel) {
    let view = DebugNotificationsSheetView(viewModel: viewModel)
    let controller = AppHostingController(rootView: view)
    controller.modalPresentationStyle = .pageSheet
    presentOnTop(controller)
}
```

### Use `AlertPresenter`, not SwiftUI `.alert`

Replace SwiftUI `.alert` / `.confirmationDialog` modifiers with `AlertPresenter` called from the coordinator (or ViewModel for notification-style alerts). The `AlertPresenter` API provides `showAlert`, `showConfirmation`, and `showTextInput`:

```swift
// In the coordinator
AlertPresenter.showTextInput(
    title: "Override ID",
    message: "Enter a debug ID.",
    placeholder: "App User ID",
    submitTitle: "Save",
    cancelTitle: "Cancel",
    onSubmit: { [weak viewModel] text in ... }
)
```

## ViewModel as the single source of business logic

The view should never:
- Access `UIPasteboard`, `UserDefaults`, `Purchases`, or `NotificationCenter` directly
- Mutate `isProEnabled` or any app-level state
- Call `haptics.successNotification()` directly

Push all of that into ViewModel methods. The view's tap handlers should be one-liners:

```swift
// Good
case .version: viewModel.copyVersionInfo()

// Bad
case .version:
    let v = "\(Bundle.main.releaseVersionNumber) (\(Bundle.main.buildVersionNumber))"
    UIPasteboard.general.string = v
    haptics.successNotification()
```

## File organization

A clean settings module typically contains:
- `Model/SFK*Item.swift` — one file per `SettingsItem` enum (icon, title, subtitle, tint, allCases)
- `Model/SettingsItems.swift` — a namespace enum collecting all item arrays
- `View/SettingsView.swift` — the view shell using `SFKSettingsScreen`
- `ViewModel/SettingsViewModel.swift` — all business logic and coordinator delegation
- `*Coordinator.swift` — all navigation, sheets, alerts, and presentation logic
