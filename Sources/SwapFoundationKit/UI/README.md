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
`colors.onDestructive` are the fallbacks for loading spinners on filled
actions. Filled `primary` and `destructive` labels use the platform button
style's contrasting color so a `.sfkTint(.primary)` fill stays readable in
dark mode. `.sfkTint` on a `borderless` button sets the title color directly.
`colors.background` is the general full-screen fill. For grouped `List` and
`Form` containers, use the paired `colors.groupedBackground` and
`colors.groupedRowSurface` tokens. `colors.surface` is the general card, field,
and button fill. The grouped defaults follow `systemGroupedBackground` and
`secondarySystemGroupedBackground`, keeping grouped rows distinct from the
container background in light mode.

The separate `SwapFoundationKitFeedback` product provides the reusable in-app
feedback flow while keeping RevenueCat and product analytics in host apps.

## Public API

### Buttons
| Type | Kind | Description |
|------|------|-------------|
| `SFKButton` | View | Configurable button with loading states, haptics, semantic styles, and platform control sizing |
| `SFKButtonStyle` | enum | `primary`, `secondary`, `borderless`, or `destructive` |
| `SFKButtonAlignment` | enum | Semantic `leading`, `center`, or `trailing` content alignment |
| `SFKCompactButton` | View | Lightweight icon-only, text-only, or icon/text action for toolbars and standalone overlay chrome |
| `SFKCompactButtonChrome` | enum | `toolbar` (system toolbar owns sizing), `glass` (self-contained 35-point minimum circle or growing capsule) |
| `SFKCompactButtonType` | enum | Semantic compact-button types, currently `.close` (X symbol and Close accessibility label) |
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
| `SFKAppearanceManager` | enum | Global rounded UIKit typography, plus `applyRoundedFonts(to:)` to re-patch a live `UINavigationBar` / `UINavigationItem` after SwiftUI replaces its appearances |
| `SFKRoundedHostingController` | class | `UIHostingController` with `.fontDesign(.rounded)` that re-applies rounded navigation fonts across the appear/layout lifecycle |

## Quick Examples

```swift
// Theme-aware semantic action
SFKButton("Continue", role: .primary) {
    nextStep()
}
.sfkIcon("arrow.right")
.sfkLoading(isSaving)
.sfkAlignment(.leading)

// Secondary action
SFKButton("Filters", role: .secondary) {
    showFilters()
}

// Borderless text or icon action
SFKButton("Not now", role: .borderless) {
    skip()
}
.sfkFullWidth(false)

// Compact inline action
SFKButton("Edit", role: .secondary) {
    editItem()
}
.sfkFullWidth(false)

// Trailing content — an optional icon moves after the text
SFKButton("Continue", role: .primary) {
    nextStep()
}
.sfkIcon("arrow.right")
.sfkAlignment(.trailing)

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
// The semantic type supplies the X symbol and Close accessibility label.
SFKCompactButton(type: .close) {
    dismiss()
}

// Generic icon-only controls require an explicit symbol and accessible name.
SFKCompactButton(
    systemImage: "chevron.left",
    accessibilityLabel: "Back",
    chrome: .toolbar
) {
    navigateBack()
}

// Standalone controls default to self-contained glass chrome.
SFKCompactButton(systemImage: "ellipsis", accessibilityLabel: "More") {
    showMoreActions()
}

// Over full-bleed content (previews, camera chrome), the surface is at least 35x35.
SFKCompactButton(systemImage: "camera", accessibilityLabel: "Camera") {
    dismiss()
}

// Text-only and icon/text labels grow into capsules with Dynamic Type.
SFKCompactButton("Edit", chrome: .glass) {
    editItem()
}
SFKCompactButton("Edit", systemImage: "pencil", chrome: .glass) {
    editItem()
}

// Close can use the same standalone glass chrome as other compact buttons.
SFKCompactButton(type: .close, chrome: .glass) {
    dismiss()
}

// Over a colored swatch — match icon to surface contrast.
SFKCompactButton(
    systemImage: "xmark",
    accessibilityLabel: "Close",
    foreground: swatch.contrastingColor
) {
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

// Rounded typography: configure once at launch, then host SwiftUI screens in
// SFKRoundedHostingController so the fonts survive SwiftUI's toolbar synthesis.
SFKAppearanceManager.configure()
let controller = SFKRoundedHostingController(rootView: SettingsView())

// App Store review prompt. `reason` identifies the trigger and is logged.
UIApplication.shared.requestReview(reason: "transactionSaved")
```

> Presentation guidance: present `SFKColorPickerSheet` with a medium detent by
> default (`.presentationDetents([.medium])`). Choose a larger or full-height
> detent only when the content or accessibility requirements genuinely need it.

### UIKit Extensions
| File | Description |
|------|-------------|
| `UIColor+.swift` | Hex init/output, RGB/HSBA components, luminance, contrast, gradients |
| `UIImage+.swift` | Aspect-fit resizing |
| `UIView+Layout.swift` | DSL: `anchor()`, `fillSuperview()`, `centerInSuperview()` |
| `UIView+Hierarchy.swift` | `addSubviews()`, `allSubViewsOf()`, `removeAllSubviews()` |
| `UIViewController+.swift` | Child VC management, top-most/root traversal |
| `UIApplication+.swift` | `topViewController()`, `foregroundKeyWindow`, `foregroundActiveScene`, `endEditing()`, `requestReview(reason:)` |
| `UIApplication+SafeArea.swift` | Safe area inset shortcuts |
| `CGTypes+Extensions.swift` | CGPoint/CGSize/CGRect/CGVector/UIEdgeInsets math |

## Source Files

- `Buttons/` — SFKButton, SFKCompactButton, and semantic styles
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
- `UIApplication+.swift` — Top view controller, scene/window lookup, review prompt
