# UI

Reusable SwiftUI and UIKit components for buttons, settings, onboarding, pickers, glass effects, aura backgrounds, barcode scanning, pro banners, and app appearance.

## Theme

`SFKTheme` is the shared semantic token surface for SFK controls. The system
theme follows platform colors, Dynamic Type, and accessibility motion settings;
hosts can override it once at the root of a view hierarchy:

```swift
ContentView()
    .sfkTheme(.system.accent(.indigo))
```

Its nested `colors`, `typography`, `spacing`, `radii`, `motion`, and `feedback`
values are public for focused brand overrides. Controls use semantic modifiers
for one-off changes rather than oversized initializers. `colors.onAccent` and
`colors.onDestructive` control foreground contrast for semantic filled actions.

The separate `SwapFoundationKitFeedback` product provides the reusable in-app
feedback flow while keeping RevenueCat and product analytics in host apps.

## Public API

### Buttons
| Type | Kind | Description |
|------|------|-------------|
| `SFKButton` | View | Configurable button with loading states, haptics, semantic styles, and platform control sizing |
| `SFKButtonStyle` | enum | `primary`, `secondary`, `toolbar`, or `destructive` |
| `SFKCloseButton` | View | Standardized icon-only toolbar navigation or labeled close/dismiss button (`toolbar` or `glass` chrome) |
| `SFKCloseButtonChrome` | enum | `toolbar` (system nav-bar treatment), `glass` (icon circle or labeled capsule over content) |
| `SFKTheme.Feedback.Style` | enum | Shared none/light/medium/heavy feedback policy for buttons and chips |

### Text Fields
| Type | Kind | Description |
|------|------|-------------|
| `SFKTextField` | View | Consistent single-line, multiline, or secure input with semantic keyboard configuration, focus binding, accessories, supporting copy, and validation |
| `SFKTextFieldStatus` | enum | Normal, error, and success presentation states |
| `SFKTextFieldInputOptions` | struct | Standard, email, or password keyboard/content-type and multiline behavior presets |
| `SFKTextFieldAppearance` | struct | Shared colors and layout tokens for host-app theming |

The compact field initializer accepts a title, binding, and optional prompt/icon;
use `.sfkInput(.email)`, `.sfkFocused(_:)`, `.sfkStatus(_:)`,
`.sfkTrailingAction(...)`, or `.sfkAppearance(...)` for focused variations.

### Chips
| Type | Kind | Description |
|------|------|-------------|
| `SFKChip` | View | Capsule-shaped action chip with primary and secondary hierarchy |
| `SFKChipStyle` | enum | `primary` or `secondary` action-chip emphasis |
| `SFKSelectableChip` | View | State-driven selectable chip with glass effect, theme feedback, and stroke |
| `SFKChipFlowLayout` | Layout | Wrapping flex-flow layout for chip clouds (iOS 16+) |

### Settings
| Type | Kind | Description |
|------|------|-------------|
| `SFKSettingsScreen` | View | Typed `Form` shell with navigation title and shared theme tint |
| `SFKSettingsSection` | View | Result-builder section with optional title and footer |
| `SFKSettingsRow` | View | Tappable row with icon, title, subtitle, and optional value/chevron modifiers |
| `SFKSettingsToggle` | View | Binding-backed native switch row |
| `SFKSettingsPicker<Value>` | View | Generic binding-backed native menu picker |
| `SFKSettingsBindingRow<Value>` | View | Typed value row that delegates editing to a host action |

### Onboarding
| Type | Kind | Description |
|------|------|-------------|
| `SFKSegmentedProgress` | View | Capsule-style step progress indicator with a configurable expanded current segment |
| `SFKTypography` | (modifiers) | `.sfkFlowTitleStyle()`, `.sfkFlowSubtitleStyle()`, etc. |
| `SFKCard` | View | Card container with icon, background, padding |

### Pickers
| Type | Kind | Description |
|------|------|-------------|
| `SFKColorPickerSheet` | View | Binding-backed hosted color picker with presets, custom color, preview, and explicit apply |
| `SFKColorPickerSheet.Configuration` | struct | Focused title, prompt, preset, opacity, and apply-button options |
| `PhotoPicker` | class | UIKit PHPicker wrapper delivering a selected image through a closure |
| `SFKPhotoPicker` | View | SwiftUI PHPicker wrapper writing a selected image to a binding and optional closure |
| `SFKItemPickerView<Item>` | View | Typed searchable picker with optional multi-selection, toolbar, empty, context, and swipe actions |
| `SFKItemPickerConfiguration<Item>` | struct | Typed labels/actions and focused picker presentation options |
| `SFKPickableItem` | protocol | Item model: id, icon, title, subtitle, optional badge, optional icon tint |
| `SFKPickableItemIconKind` | enum | Icon source: image, SF Symbol, text, none |
| `SFKItemPickerToolbarAction` | struct | Navigation bar action rendered by the picker |
| `SFKItemPickerItemAction` | struct | Row-level context-menu or swipe action |

### Effects
| Type | Kind | Description |
|------|------|-------------|
| `TopAuraBackground` | View | Layered radial + linear gradient background with explicit visual tuning |
| `SFKAuraLayer` | View | Accessibility-gated aura glow (respects reduce motion) |
| `SFKAuraGlowBackground` | View | Full-screen atmospheric glow wrapping content; omitted color follows `SFKTheme.colors.accent` |

### Glass
| Type | Description |
|------|-------------|
| `.sfkGlass(material:tint:isInteractive:shape:)` | Liquid Glass for a custom control or surface with a pre-iOS-26 fallback. Buttons should use `SFKButtonStyle`. |
| `SFKGlassMaterial` | `.regular` for standard legibility or `.clear` over rich media |
| `SFKGlassShape` | `.roundedRectangle(cornerRadius:style:)` / `.capsule` / `.circle` |

### Other
| Type | Kind | Description |
|------|------|-------------|
| `BarcodeScannerScreen` | View | Full live camera barcode scanner |
| `BarcodeScannerConfiguration` | struct | Scanner configuration |
| `BarcodeScannerResult` | struct | Scan result payload |
| `SFKProBannerView` | View | Pro upgrade banner |
| `AlertPresenter` | enum | Main-actor UIKit alert, confirmation, action-sheet, and text-input presenter |
| `AlertAction` / `AlertActionStyle` | model | Typed action title, handler, and semantic role |
| `PhotoPicker` | class | PHPickerViewController wrapper |
| `SFKAppearanceManager` | enum | Global rounded UIKit typography configuration |
| `SFKRoundedHostingController` | class | UIHostingController with `.fontDesign(.rounded)` |

## Quick Examples

```swift
// Theme-aware semantic action
SFKButton("Continue", role: .primary) {
    nextStep()
}
.sfkIcon("arrow.right")
.sfkLoading(isSaving)

// Secondary action
SFKButton("Filters", role: .secondary) {
    showFilters()
}

// System toolbar action
SFKButton("", role: .toolbar) {
    showMoreActions()
}
.sfkIcon("ellipsis")
.accessibilityLabel("More")

// Compact inline action
SFKButton("Edit", role: .secondary) {
    editItem()
}
.sfkFullWidth(false)

// Semantic text input with inline validation
SFKTextField(
    "Email",
    text: $email,
    prompt: "you@example.com",
    leadingSystemImage: "envelope"
)
.sfkInput(.email)
.sfkOnSubmit(submitEmail)
.sfkStatus(isEmailValid ? .normal : .error("Enter a valid email."))

// Composer-style multiline input
SFKTextField(
    "Message",
    text: $message,
    prompt: "Describe your transaction"
)
.sfkInput(.init(axis: .vertical, lineLimit: 1...6))

// Action chips
SFKChipFlowLayout(spacing: 8) {
    SFKChip("Recommended", leadingIconName: "star.fill", controlSize: .small, style: .primary) {
        applyRecommendation()
    }
    SFKChip("Edit", leadingIconName: "pencil", controlSize: .small, style: .secondary) {
        editItem()
    }
}

// Close / dismiss
// In a toolbar, the icon-only label stays native so iOS supplies one correctly sized control.
SFKCloseButton {
    dismiss()
}

// Back navigation with the same standardized toolbar treatment
SFKCloseButton(systemImage: "chevron.left", accessibilityLabel: "Back") {
    navigateBack()
}

// Over full-bleed content (previews, camera chrome)
SFKCloseButton(chrome: .glass) {
    dismiss()
}

// Labeled glass capsule
SFKCloseButton("Close", chrome: .glass) {
    dismiss()
}

// Over a colored swatch — match icon to surface contrast
SFKCloseButton(chrome: .glass, foreground: swatch.contrastingColor) {
    dismiss()
}

// Settings
SFKSettingsScreen(navigationTitle: "Settings") {
    SFKSettingsSection("Preferences") {
        SFKSettingsToggle("Notifications", isOn: $notificationsEnabled)
        SFKSettingsRow("Privacy Policy", systemImage: "hand.raised") {
            openPrivacyPolicy()
        }
        DatePicker("Reminder date", selection: $reminderDate, displayedComponents: .date)
    }
}

// Onboarding
SFKSegmentedProgress(
    currentStep: 2,
    totalSteps: 5,
    currentSegmentWidthMultiplier: 1.75
)
SFKChipFlowLayout(spacing: 8) {
    ForEach(items) { item in
        SFKSelectableChip(item.label, icon: item.icon, isSelected: item.isSelected) { select(item) }
    }
}

// Item Picker
SFKItemPickerView(
    "Currency",
    items: Currency.sortedAllCases,
    selection: $selectedCurrency,
    label: { $0.rawValue }
)

// Color Picker
SFKColorPickerSheet(
    selection: $selectedColor,
    configuration: .init(
        promptTitle: "Choose an account color",
        promptMessage: "Pick a color that makes this account easy to spot."
    )
)

// Item list with row actions
SFKItemPickerView(
    pageTitle: "Accounts",
    items: accounts,
    selection: $selectedAccount,
    configuration: .init(
        actionsProvider: { account in
            [SFKItemPickerItemAction(title: "Delete", systemImage: "trash", role: .destructive, presentation: .swipe) {
                delete(account)
            }]
        }
    ),
    onSelect: { account in edit(account) }
)

// Glass
Text("Hello")
    .padding()
    .sfkGlass(material: .regular, tint: .blue, shape: .capsule)

// Alerts
AlertPresenter.showAlert(title: "Done", message: "Saved successfully")
```

### UIKit Extensions
| File | Description |
|------|-------------|
| `UIColor+.swift` | Hex init/output, RGB/HSBA components, luminance, contrast, gradients |
| `UIImage+.swift` | Aspect-fit resizing |
| `UIView+Layout.swift` | DSL: `anchor()`, `fillSuperview()`, `centerInSuperview()` |
| `UIView+Hierarchy.swift` | `addSubviews()`, `allSubViewsOf()`, `removeAllSubviews()` |
| `UIViewController+.swift` | Child VC management, top-most/root traversal |
| `UIApplication+SafeArea.swift` | Safe area inset shortcuts |
| `CGTypes+Extensions.swift` | CGPoint/CGSize/CGRect/CGVector/UIEdgeInsets math |

## Source Files

- `Buttons/` — SFKButton, SFKCloseButton, and semantic styles
- `TextField/` — SFKTextField, validation states, focus synchronization, and appearance tokens
- `ColorPicker/` — SFKColorPickerSheet and its binding-backed Configuration
- `Settings/` — typed screen/section/row/toggle/picker views
- `Chips/` — Primary and secondary action chips
- `Onboarding/` — Selectable chips, flow layout, progress, typography, and cards
- `ItemPicker/` — typed view/configuration and item/action models
- `Effects/` — Aura layer, glow background, top aura
- `SwiftUIExtensions/` — Glass button modifiers
- `UIKitExtensions/` — 8 files covering UIColor, UIImage, UIView, etc.
- `BarcodeScanner/` — BarcodeScannerScreen, view, configuration
- `ProBanner/` — SFKProBannerView
- `AlertPresenter.swift` — Alerts and confirmations
- `PhotoPicker.swift` — PHPicker wrapper
- `SFKAppearanceManager.swift` — UIKit rounded typography
- `SFKRoundedHostingController.swift` — Rounded font hosting controller
