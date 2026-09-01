# Migrating an iOS Project to SwapFoundationKit

This is the concise, repeatable migration reference for host applications.
Begin with [`Docs/migration/catalog.yaml`](catalog.yaml) for the authoritative
capability inventory, then read the module README for each capability you adopt.
The v4-specific settings and picker recipes are in
[`Docs/migration/v4-simplification-migration-guide.md`](v4-simplification-migration-guide.md),
[`Docs/guides/settings.md`](../guides/settings.md), and
[`Docs/guides/settings-patterns.md`](../guides/settings-patterns.md).

## Migration method

1. Inventory the host implementation with `rg` and classify each finding as
   `replace`, `wrap`, or `keep`.
2. Confirm the capability and public symbol in the migration catalog and module
   README. Do not migrate domain-specific policy merely because a similar name
   exists.
3. Introduce the SFK API behind the host's existing state and dependencies.
4. Delete the redundant implementation only after behavior and accessibility
   coverage passes.
5. Remove unused imports and update every in-repository example/test.
6. Build the host app, run focused tests, then run the package suite.

Prefer async/await, `@MainActor` for UI state, explicit dependency injection,
and semantic Dynamic Type styles. Keep authentication wire formats, persistence
keys, sync behavior, and backend contracts unchanged.

## Current high-value APIs

### UI

- `SFKTheme` supplies semantic colors, typography, spacing, radii, motion, and
  feedback through `.sfkTheme(...)`.
- `SFKButton("Continue", role: .primary) { ... }` supports focused modifiers
  such as `.sfkIcon(...)`, `.sfkLoading(...)`, `.sfkFullWidth(...)`, and
  `.sfkTint(...)`.
- `SFKCompactButton` provides lightweight icon-only, text-only, or icon/text
  controls. Standalone glass controls have a 35-point minimum surface and
  grow as labels require; use `.toolbar` when the system toolbar owns chrome.
- `SFKCompactButton(type: .close)` provides the standard X symbol and Close
  accessibility label while sharing the compact-button implementation.
- `SFKSettingsScreen { SFKSettingsSection { ... } }` is the typed settings
  composition path. Use `SFKSettingsRow`, `SFKSettingsToggle`,
  `SFKSettingsPicker`, and `SFKSettingsBindingRow`; compose native
  `DatePicker`, `Stepper`, `Slider`, `ColorPicker`, and `Toggle` directly.
- `SFKItemPickerView<Item>` uses concrete item types and
  `Binding<Item?>`, `Binding<Item>`, or `Binding<Set<Item>>`. Its typed
  configuration retains search, stable IDs, empty states, toolbar actions,
  and context/swipe actions.
- `SFKColorPickerSheet(selection:configuration:onApply:)` provides a binding-
  backed draft/apply color flow. `PhotoPicker(configuration:onPick:)` and
  `SFKPhotoPicker(selection:configuration:onPick:)` deliver images through
  closures/bindings.
- `.sfkGlass(material:tint:isInteractive:shape:)` adds a glass surface with a
  pre-iOS-26 fallback.

See [`Sources/SwapFoundationKit/UI/README.md`](../../Sources/SwapFoundationKit/UI/README.md)
for the complete UI surface.

### Services and foundation

- Use `HapticsHelper` for shared impact and notification feedback.
- Define app-specific analytics events with `AnalyticsEvent` and inject the
  provider/fan-out service.
- Use `AppLinkOpener` for external URLs and review links; keep `AppMetaData`
  as data.
- Use `BackupService` for on-device JSON backups, preserving the same Codable
  type and decoder date strategy for restore.
- Use `DataSyncService`/`ItemSyncServiceFactory` for explicit App Group sync;
  provide the suite identifier at construction.
- Use the networking, authentication, media, currency, and optional integration
  module READMEs for their typed constructors and transport contracts.

## Representative migrations

### Settings

```swift
SFKSettingsScreen(navigationTitle: "Settings") {
    SFKSettingsSection("Preferences") {
        SFKSettingsToggle(
            "Notifications",
            subtitle: "Receive release alerts.",
            systemImage: "bell.badge",
            isOn: $notificationsEnabled
        )
        SFKSettingsRow("Privacy Policy", systemImage: "hand.raised") {
            coordinator.openPrivacyPolicy()
        }
        DatePicker("Reminder date", selection: $reminderDate, displayedComponents: .date)
    }
}
```

Use `.settingsRowChevron(false).settingsRowValue(version)` for informational
rows. Keep URLs, confirmation policy, analytics, and navigation in the host.

### Item picker

```swift
SFKItemPickerView(
    "Categories",
    items: Category.allCases,
    selections: $selectedCategories,
    label: { $0.title },
    onSelect: { category in analytics.track(category) }
)
```

Conform the concrete model to `SFKPickableItem`. Use
`SFKItemPickerConfiguration<Item>` when adding typed row actions, toolbar
actions, an empty state, or custom labels. IDs should remain stable across
reloads.

### Buttons and feedback

```swift
SFKButton("Save", role: .primary) { save() }
    .sfkLoading(isSaving)
    .sfkIcon("checkmark")

SFKCompactButton(
    systemImage: "chevron.left",
    accessibilityLabel: "Back",
    chrome: .toolbar
) {
    navigateBack()
}

SFKCompactButton(type: .close, chrome: .toolbar) {
    dismiss()
}

SFKCompactButton("Edit", systemImage: "pencil") {
    editItem()
}
```

The shared `SFKTheme.Feedback` policy controls SFK button/chip feedback. Respect
the environment's disabled and Reduce Motion state in host-owned controls.

## Systematic search and replacement

Search the host for the capability's catalog terms, then inspect each match in
context. Typical replacements include:

- repeated haptic calls → `HapticsHelper`;
- custom settings rows → typed SFK rows or native controls;
- custom item selection state → typed picker bindings;
- hand-built close buttons → `SFKCompactButton(type: .close)`;
- repeated URL/review plumbing → `AppLinkOpener`;
- direct widget reloads around sync writes → one host-owned sync wrapper;
- ad hoc image transforms → the Media module's injected service.

Do not replace app-specific coordinators, entitlement rules, persistence
schemas, or authentication flows without a separate design decision.

## Validation checklist

- The package and host target import only the products they use.
- No obsolete compatibility symbol remains in source, examples, or tests.
- Bindings and action closures have focused behavioral tests.
- Settings and picker screens are reviewed at large Dynamic Type sizes, light /
  dark appearance, increased contrast, and Reduce Motion.
- Empty, loading, disabled, search, cancellation, and error states remain
  observable and accessible.
- Networking, sync, persistence, authentication, and optional integrations
  retain their existing regression coverage.
- `swift test` and the host app build pass before committing.

## Commit discipline

Keep each migration focused by capability. Describe the old implementation,
the SFK replacement, behavior coverage, and any intentional `keep` decision in
the commit or pull request. Do not push, deploy, alter credentials, or change
backend protocols as part of a package migration.
