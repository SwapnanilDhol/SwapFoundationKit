# Settings UI

Build settings pages from a typed SwiftUI result builder. The common path keeps
state and actions concrete, while native controls remain easy to compose in a
section.

## What SFK provides

- `SFKSettingsScreen` — a themed `Form` shell with a navigation title.
- `SFKSettingsSection` — a typed section with an optional header and footer.
- `SFKSettingsRow` — an action/navigation row with title, subtitle, SF Symbol,
  and optional tint.
- `SFKSettingsToggle` — a binding-backed switch row.
- `SFKSettingsPicker` — a binding-backed native menu picker with generic values.
- `SFKSettingsBindingRow` — a value row that delegates editing to a host action.
- `SFKTheme` — shared colors, typography, spacing, radii, motion, and feedback.

Color and item pickers are separate views. Use `SFKColorPickerSheet` with a
binding, and `SFKItemPickerView<Item>` with a concrete item type and typed
selection binding.

## Minimal screen

```swift
import SwiftUI
import SwapFoundationKit

struct SettingsView: View {
    @State private var notificationsEnabled = true
    @State private var unit = "metric"
    @State private var showAbout = false

    var body: some View {
        SFKSettingsScreen(navigationTitle: "Settings") {
            SFKSettingsSection("Preferences", footer: "Changes apply immediately.") {
                SFKSettingsToggle(
                    "Notifications",
                    subtitle: "Receive product and release alerts.",
                    systemImage: "bell.badge.fill",
                    isOn: $notificationsEnabled
                )
                SFKSettingsPicker(
                    "Units",
                    selection: $unit,
                    options: ["metric", "imperial"],
                    label: { $0.capitalized }
                )
                SFKSettingsRow("About", systemImage: "info.circle") {
                    showAbout = true
                }
            }
        }
    }
}
```

For a row without a disclosure indicator, use the focused modifier. A dynamic
value is also a modifier, so the common row initializer stays small:

```swift
SFKSettingsRow(
    "Version",
    subtitle: "Current installed build",
    systemImage: "info.circle.fill",
    tint: .secondary
) { }
.settingsRowChevron(false)
.settingsRowValue("2.2.0 (1)")
```

## Native controls and custom editors

Use standard SwiftUI controls directly when a setting does not need a custom
row presentation. They inherit the screen's accent tint and preserve Dynamic
Type, disabled state, and accessibility semantics.

```swift
SFKSettingsSection("Schedule") {
    DatePicker("Reminder date", selection: $reminderDate, displayedComponents: .date)
    Stepper("Attempts: \(attempts)", value: $attempts, in: 1...5)
    Slider(value: $volume, in: 0...1) { Text("Volume") }
    ColorPicker("Accent color", selection: $accentColor, supportsOpacity: true)
}
```

Use `SFKSettingsBindingRow` when the host owns a custom editor or navigation
destination:

```swift
SFKSettingsBindingRow(
    "Account",
    value: $accountName,
    valueLabel: { $0 },
    action: { name in coordinator.presentAccountEditor(currentName: name) }
)
```

## Theme customization

Configure the shared theme once at the application boundary. Settings rows
resolve their colors and typography from this environment; explicit row tints
remain focused overrides.

```swift
SettingsView()
    .sfkTheme(
        SFKTheme(
            colors: .init(accent: .mint),
            spacing: .init(control: 12, section: 24, inline: 8),
            radii: .init(control: 12, card: 20)
        )
    )
```

The screen applies `theme.colors.accent` to native controls. Use a control's
own `.tint(...)` modifier only when that one control intentionally differs.
Prefer semantic text styles (`.body`, `.subheadline`, `.footnote`, and
`.caption`) over fixed font sizes.

## Advanced typed picker

`SFKSettingsPicker<Value>` keeps the selection and callback generic. A focused
presentation value can change the icon, subtitle, or tint without introducing
an erased row model:

```swift
SFKSettingsPicker(
    "Priority",
    selection: $priority,
    options: Priority.allCases,
    label: { $0.title },
    onChange: { priority in analytics.trackPriority(priority) },
    presentation: .init(
        subtitle: "Used for sorting reminders.",
        systemImage: "flag.fill",
        tint: .orange
    )
)
```

For a full searchable picker, keep the item type concrete and choose one of
the three binding shapes:

```swift
SFKItemPickerView(
    "Categories",
    items: Category.allCases,
    selections: $selectedCategories,
    label: { $0.title },
    onSelect: { category in analytics.trackCategory(category) }
)
```

`SFKItemPickerConfiguration<Item>` retains typed labels, context/swipe actions,
toolbar actions, empty state, search, and presentation flags. Items are rendered
with their `pickableItemId`, so selection remains stable when labels or ordering
change.

## Color picker sheet

```swift
SFKColorPickerSheet(
    selection: $accentColor,
    configuration: .init(
        promptTitle: "Choose an account color",
        promptMessage: "Pick a preset or open the color wheel.",
        supportsOpacity: true
    ),
    onApply: { color in analytics.trackColorChange(color) }
)
```

The binding is updated only when the user taps Apply. Hosts that need a live
preview can use `ColorPicker` directly inside an `SFKSettingsSection`.

## Accessibility and behavior review

- Verify the screen at large and accessibility Dynamic Type sizes.
- Keep labels meaningful; use `.accessibilityValue` for formatted values.
- Ensure disabled settings are visibly and semantically disabled.
- Test light/dark schemes and increased contrast.
- Respect Reduce Motion for host-owned transitions and animated editors.
- Verify every binding writes the expected model value and every row action is
  reachable from the row's full content shape.

See [Settings Patterns](settings-patterns.md) and the
[Settings Integration Checklist](../reference/settings-integration-checklist.md)
for composition and review recipes.
