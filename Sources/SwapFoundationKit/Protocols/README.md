# Protocols

Foundation protocols for coordinator-based navigation, type-safe default values, app metadata, and pasteboard operations.

## Public API

| Type | Kind | Description |
|------|------|-------------|
| `Coordinator` | protocol | Navigation pattern with push, pop, present, setRoot, presentItemPicker |
| `ValueDefaultProvider` | protocol | Type-safe default value with static getter/setter |
| `AppMetaData` | struct | Centralized app metadata (ID, name, URLs, links) with static URL openers |
| `PasteboardCopyRepresentable` | protocol | Type-safe pasteboard payload generation |

### Coordinator
```swift
final class AppCoordinator: Coordinator {
    var navigationController: UINavigationController
    func start() { /* set up tabs */ }
}

// Built-in convenience methods:
coordinator.push(viewController)
coordinator.presentItemPicker(title: "Select", items: currencies)
coordinator.dismiss()
```

### AppMetaData
```swift
let metadata = AppMetaData(
    appGroupIdentifier: "group.com.app",
    appID: "123456789",
    appName: "MyApp",
    appSupportEmail: "support@example.com"
)
AppMetaData.openAppReviewPage()
AppMetaData.openPrivacyPolicy(fallbackURL: privacyURL)
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
- `AppMetaData.swift` — App metadata with link openers
- `PasteboardCopyRepresentable.swift` — Pasteboard protocol
