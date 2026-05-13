# Settings Integration Checklist

Use this checklist to audit whether a host app has integrated `SFKSettings` clearly and consistently.

## Screen shell

- `SFKSettingsScreen` is used when the page is primarily a settings form
- `sections` are used for tappable `SettingsItem` rows
- `customSections` are only used where interactive controls or custom layouts are actually needed
- The settings preview in Xcode matches the real host-app structure rather than a custom mock layout

## Theme

- A single `SFKSettingsTheme` is defined at the screen or app layer
- The host app passes `theme:` into `SFKSettingsScreen` or applies `.sfkSettingsTheme(...)`
- The app has intentionally chosen `itemTintBehavior`
- The app has explicitly set `toggleOnTint` and `sliderTint` if the default accent should not be reused
- Title, subtitle, and value typography are configured if the app requires custom sizing or weight
- Row spacing and vertical padding are configured if the host app has a denser or more relaxed visual system

## Colors

- There is a clear decision between uniform theme accent and per-row item tinting
- Destructive actions use `destructiveTint` consistently
- Accessory icons and trailing values are legible against the host app's background
- Toggle-on colors match the intended brand color
- Slider and picker accents match the intended brand color

## Composition

- Static informational rows are represented as `SettingsItem` values where possible
- Dynamic values such as version, sync time, or selected units use `rowTrailingBuilder`
- Non-navigable rows hide the chevron using `rowChevronBuilder`
- Row tap routing is centralized instead of scattered across multiple nested views

## Controls

- Toggles use `SFKSettingsToggle` or `SFKSettingsToggleRow`
- Date and time settings use `SFKSettingsDatePickerRow`, `SFKSettingsTimePickerRow`, or `SFKSettingsInlineDatePicker`
- Choice-based settings use `SFKSettingsPickerRow` or `SFKSettingsPickerSheetRow`
- Numeric settings use `SFKSettingsStepperRow` or `SFKSettingsSliderRow`
- Color settings use `SFKSettingsColorPickerRow` or `SFKSettingsInlineColorPicker`
- Color picker rows do not introduce an unnecessary intermediate sheet

## Shared sections

- `SFKInformationSectionItem` is used for app-info rows where appropriate
- `SFKDeveloperSectionItem` is used for developer/about rows where appropriate
- `SFKInformationSectionHandler` and `SFKDeveloperSectionHandler` are used if the app wants the built-in behaviors

## Verification

- Xcode previews for the settings rows are reviewed
- The host app settings screen is reviewed in the simulator/device
- The host app compiles after integrating the settings screen
- The team has documented any intentional deviations from the shared settings theme
