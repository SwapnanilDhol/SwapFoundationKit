# Settings Patterns

Practical patterns for composing settings pages with the v4 typed builder and
binding APIs.

## Section architecture

Use one `SFKSettingsSection` for each logical group. Put rows and controls
directly in its result builder; there is no array of heterogeneous rows to
maintain and no type-casting tap router.

```swift
SFKSettingsSection("Privacy") {
    SFKSettingsToggle("Analytics", isOn: $analyticsEnabled)
    SFKSettingsRow("Privacy Policy", systemImage: "hand.raised") {
        openPrivacyPolicy()
    }
    Toggle("Personalized recommendations", isOn: $personalizationEnabled)
}
```

If a section has a native control and a custom row, keep them together. A
section footer is a good place for concise explanatory text.

## Values and chevrons

Use focused row modifiers for informational values and non-navigable rows:

```swift
SFKSettingsRow("Last sync", systemImage: "arrow.triangle.2.circlepath") {
    refresh()
}
.settingsRowValue(lastSync.formatted())

SFKSettingsRow("Version", systemImage: "info.circle", tint: .secondary) { }
    .settingsRowChevron(false)
    .settingsRowValue(version)
```

Avoid type-erased views, existential row arrays, or closures that dispatch on a
hidden item type. If the trailing value has specialized layout, compose a native
`LabeledContent`, `Toggle`, or custom view directly in the section.

## Host-owned navigation and actions

Rows describe an action; the host owns what that action means. This keeps URLs,
analytics, feature flags, and navigation policy out of the package:

```swift
SFKSettingsRow("Export data", systemImage: "square.and.arrow.up") {
    coordinator.presentExportSheet()
}

SFKSettingsRow("Delete account", systemImage: "trash", tint: .red) {
    showDeleteConfirmation = true
}
.confirmationDialog(
    "Delete account?",
    isPresented: $showDeleteConfirmation,
    titleVisibility: .visible
) {
    Button("Delete", role: .destructive) { deleteAccount() }
    Button("Cancel", role: .cancel) { }
}
```

For UIKit-owned flows, expose a typed coordinator method and present the host
view controller from there. `Coordinator.presentItemPicker` accepts concrete
items plus `Binding<Item?>`, `Binding<Item>`, or `Binding<Set<Item>>`.

## Debug and dangerous operations

Gate debug-only sections at compile time or with the host's explicit feature
policy. Keep destructive operations together and label them clearly:

```swift
#if DEBUG
SFKSettingsSection("Developer") {
    SFKSettingsRow("Seed sample data", systemImage: "wand.and.stars") {
        seedSampleData()
    }
    SFKSettingsRow("Reset local data", systemImage: "trash", tint: .red) {
        showResetConfirmation = true
    }
}
#endif
```

Use `AlertPresenter` when an app needs a UIKit alert or text input shared by
multiple presentation paths. SwiftUI `.alert` and `.confirmationDialog` are
appropriate for view-local state, as in the confirmation example above.

## Binding and business logic

Bindings should point at the source of truth. Keep persistence, networking,
entitlement checks, and side effects in the host model or view model, then pass
small bindings and closures into the settings view:

```swift
SFKSettingsToggle(
    "Cloud sync",
    subtitle: syncModel.statusDescription,
    systemImage: "arrow.triangle.2.circlepath",
    isOn: $syncModel.isEnabled,
    action: { syncModel.toggleSync() }
)
```

The typed picker closure receives the concrete value, so no cast or dispatch
table is needed:

```swift
SFKSettingsPicker(
    "Sort order",
    selection: $sortOrder,
    options: SortOrder.allCases,
    label: { $0.title },
    onChange: { sortOrder in preferences.update(sortOrder) }
)
```

## Accessibility and motion

- Prefer native controls for native semantics and keyboard/switch access.
- Use `.accessibilityLabel` and `.accessibilityValue` when a formatted value
  is not self-evident.
- Check large Dynamic Type sizes for truncation and row hit targets.
- Validate light/dark and increased-contrast schemes.
- Avoid adding animation to a settings value unless it communicates a state
  change; honor Reduce Motion for any host-owned animation.

## File organization

A host app can keep its settings feature small:

- `SettingsView.swift` — `SFKSettingsScreen` and section composition.
- `SettingsViewModel.swift` — persistence and business logic.
- `SettingsCoordinator.swift` — sheets, UIKit navigation, and external links.
- `SettingsTests.swift` — binding writes, action routing, and accessibility
  assertions.
