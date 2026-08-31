# Settings Integration Checklist

Use this checklist when reviewing a host app's v4 settings screen.

## Screen shell

- `SFKSettingsScreen` is used for a primarily form-based page.
- Every logical group is an `SFKSettingsSection` with one header.
- Rows and controls are composed directly in the result builder.
- No heterogeneous row array, type-erased view, or existential dispatch table is
  used in the common path.
- The preview mirrors the host screen's real state and navigation.

## Theme and semantics

- A shared `SFKTheme` is supplied at the app or feature boundary.
- The screen's native controls inherit `theme.colors.accent`.
- Explicit `.tint(...)` overrides are limited to intentional exceptions.
- Typography uses semantic Dynamic Type styles.
- Row values and accessory labels have sufficient contrast in light/dark modes.
- Reduced-motion behavior is respected for host-owned animations.

## Composition

- Tappable content uses `SFKSettingsRow` with a concrete closure.
- Informational values use `.settingsRowValue(...)`.
- Non-navigable rows use `.settingsRowChevron(false)`.
- Custom editors use `SFKSettingsBindingRow` or a native control in the section.
- Host navigation, URLs, analytics, and policy remain host-owned.
- Destructive actions have an explicit confirmation step and destructive role.

## Controls

- Toggles use `SFKSettingsToggle` or native `Toggle` with a binding.
- Dates/times use native `DatePicker` controls unless a host-specific editor is
  required.
- Choices use `SFKSettingsPicker<Value>` or `SFKItemPickerView<Item>` with a
  concrete binding and label closure.
- Numeric values use native `Stepper` or `Slider` controls.
- Colors use native `ColorPicker` or the binding-backed
  `SFKColorPickerSheet`.
- Item-picker context/swipe actions use typed `SFKItemPickerConfiguration<Item>`
  closures; IDs are stable across reloads.

## Behavior and accessibility

- Binding writes are covered by tests, including optional, non-optional, and
  multi-selection item-picker paths.
- Row action closures are covered by tests.
- Empty and search-result states are reviewed for item pickers.
- Large Dynamic Type and accessibility sizes are checked for truncation.
- Disabled/loading states remain visible and semantically disabled.
- Increased contrast and VoiceOver labels/values are reviewed on device or
  simulator.

## Verification

- The host app compiles after the settings screen is integrated.
- The settings screen is reviewed in light/dark and large-text configurations.
- Intentional deviations from shared theme tokens are documented.
