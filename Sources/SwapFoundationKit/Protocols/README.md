# Protocols

Foundation protocols for coordinator-based navigation, type-safe default values, app metadata, and pasteboard operations.

## Public API

| Type | Kind | Description |
|------|------|-------------|
| `Coordinator` | protocol | Navigation pattern with push, pop, present, setRoot, and typed item-picker presentation |
| `ValueDefaultProvider` | protocol | Type-safe default value with static getter/setter |
| `AppMetaData` | struct | Centralized app metadata (ID, name, URLs, links) |
| `PasteboardCopyRepresentable` | protocol | Type-safe pasteboard payload generation |

### Coordinator
```swift
final class AppCoordinator: Coordinator {
    var navigationController: UINavigationController
    func start() { /* set up tabs */ }
}

// Built-in convenience methods:
coordinator.push(viewController)
// Optional or non-optional single selection uses `Binding<Item?>` or `Binding<Item>`.
coordinator.presentItemPicker(
    title: "Select",
    items: currencies,
    selection: $selectedCurrency,
    subtitle: "Choose a currency",
    onSelect: { currency in didSelect(currency) }
)
// Multi-selection uses the `selections: Binding<Set<Item>>` overload.
coordinator.dismiss()
```

### AppMetaData
```swift
let metadata = AppMetaData(
    appGroupIdentifier: "group.com.app",
    appID: "123456789",
    appName: "MyApp",
    links: .init(supportEmail: "support@example.com")
)
AppLinkOpener.openAppReviewPage(appID: metadata.appID)
AppLinkOpener.open(url: metadata.appPrivacyPolicyUrl ?? privacyURL)
```

### ValueDefaultProvider
```swift
enum SortOrder: ValueDefaultProvider {
    static func defaultValue() -> Self { .dateDescending }
    static func setDefaultValue(_ value: Self) { /* persist */ }
}
let current = SortOrder.default
```

## Source Files

- `Coordinator.swift` — Navigation pattern
- `ValueDefaultProvider.swift` — Default value protocol
- `AppMetaData.swift` — App metadata data model
- `PasteboardCopyRepresentable.swift` — Pasteboard protocol
