# Compatibility

Forward-compatible wrappers for iOS 26+ APIs with no-op fallbacks on older OS versions.

## Public API

| Type | Kind | Description |
|------|------|-------------|
| `SFKTabBarMinimizeBehavior` | ViewModifier | `tabBarMinimizeBehavior(.onScrollDown)` on iOS 26+, no-op otherwise |
| `SFKNavigationSubtitle` | ViewModifier | `navigationSubtitle(_:)` on iOS 26+, no-op otherwise |

```swift
// SwiftUI
TabView {
    ContentView()
}
.compatibleTabBarMinimizeBehavior()

NavigationStack {
    ListView()
        .navigationTitle("Items")
        .compatibleNavigationSubtitle("42 items")
}
```

## Source Files

- `CompatibleTabBarMinimizeBehavior.swift` — SwiftUI wrapper
- `UIKit/UIKitTabBarMinimizeBehavior.swift` — UIKit wrapper
- `CompatibleNavigationSubtitle.swift` — Navigation subtitle wrapper
