# v4 settings and picker removals

This handoff records the breaking cleanup owned by the settings/pickers workstream.

## Removed symbols

- `SettingsItem`, `SFKSettingsSectionConfiguration`, `SFKSettingsCustomSection`, `SFKAnySettingsItem`, and the `SFKSettingsItemAction`/`SFKSettingsTrailingBuilder`/`SFKSettingsChevronBuilder` aliases.
- `SFKInformationSectionItem`, `SFKDeveloperSectionItem`, `SFKSettingsActionHandler`, `SFKInformationSectionHandler`, and `SFKDeveloperSectionHandler` (hosts own navigation and actions).
- `SFKSettingsTrailing`, public `SFKSettingsValueText`, `SFKSettingsLabel`, `SFKSettingsToggleRow`, `SFKSettingsPickerRow`, `SFKSettingsPickerSheetRow`, `SFKSettingsPickerOption`, `SFKPickerStyle`, `SFKSettingsPickerPresentation` (now nested as `SFKSettingsPicker<Value>.Presentation`), `SFKSettingsDatePickerRow`, `SFKSettingsTimePickerRow`, `SFKSettingsInlineDatePicker`, `SFKSettingsStepperRow`, `SFKSettingsSliderRow`, `SFKSettingsColorPickerRow`, `SFKSettingsInlineColorPicker`, `SFKSettingsLinkRow`, `SFKSettingsDestructiveRow`, and `SFKSettingsConfirmationRow`.
- `SFKSettingsTheme` and the public `SFKSettingsFormRowButtonStyle`; settings now consume the shared `SFKTheme`, while row button styling is internal.
- `SFKItemPickerViewModel`, `SFKItemPickerDelegate`, `SFKItemPickerSection`, `SFKItemPickerSelectionMode`, `SFKItemPickerLegacyItem`, public `SFKItemPickerRow`, `SFKItemPickerItemActionPresentation`, and `SFKItemPickerToolbarActionPlacement` (presentations are now nested as `SFKItemPickerItemAction.Presentation` and `SFKItemPickerToolbarAction.Placement`).
- `SFKColorPickerDelegate`, top-level `SFKColorPickerConfiguration`, and the `SFKColorPickerSheet(selectedColor:...delegate:)` initializer. Advanced options now live in `SFKColorPickerSheet.Configuration`.
- `PhotoPickerDelegate` and the `PhotoPicker(configuration:delegate:)` initializer.
- All coordinator overloads accepting existential item arrays, sections, view models, delegates, or `onDismiss` view-model callbacks.

## Canonical replacements

- Compose settings with `SFKSettingsScreen(navigationTitle:content:)`, `SFKSettingsSection`, `SFKSettingsRow`, `SFKSettingsToggle`, `SFKSettingsPicker`, and `SFKSettingsBindingRow`.
- `SFKSettingsRow` now takes `(_ title: String, subtitle: String = "", systemImage: String = "arrow.forward", tint: Color? = nil, action: @escaping () -> Void)`. Use `.settingsRowChevron(_:)` and `.settingsRowValue(_:)` for focused presentation overrides.
- Use `SFKItemPickerView` with concrete `Item` and `Binding<Item?>`, `Binding<Item>`, or `Binding<Set<Item>>`. `SFKItemPickerConfiguration<Item>` retains typed labels/actions, toolbar actions, empty state, and presentation flags.
- Use `SFKColorPickerSheet(selection:configuration:onApply:)` for a binding-backed draft/apply flow.
- Use `PhotoPicker(configuration:onPick:)` or `SFKPhotoPicker(selection:configuration:onPick:)` for closure/binding image delivery.
- Use the typed `Coordinator.presentItemPicker(title:items:selection:...)` overloads for UIKit presentation.
