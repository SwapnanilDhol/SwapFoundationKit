# UI

Reusable SwiftUI and UIKit components for buttons, settings, onboarding, pickers, glass effects, aura backgrounds, barcode scanning, pro banners, and app appearance.

## Public API

### Buttons
| Type | Kind | Description |
|------|------|-------------|
| `SFKButton` | View | Configurable button with loading states, haptics, semantic styles, and platform control sizing |
| `SFKButtonStyle` | enum | `primary`, `secondary`, or `toolbar` |
| `SFKCloseButton` | View | Standardized icon-only or labeled close/dismiss button (`toolbar` or `glass` chrome) |
| `SFKCloseButtonChrome` | enum | `toolbar` (system nav-bar treatment), `glass` (icon circle or labeled capsule over content) |
| `SFKButtonHapticStyle` | enum | light, medium, heavy tap feedback |

### Chips
| Type | Kind | Description |
|------|------|-------------|
| `SFKChip` | View | Capsule-shaped action chip with primary and secondary hierarchy |
| `SFKChipStyle` | enum | `primary` or `secondary` action-chip emphasis |
| `SFKChipHapticStyle` | enum | Optional light, medium, or heavy action-chip feedback |
| `SFKSelectableChip` | View | State-driven selectable chip with glass effect, haptics, and stroke |
| `SFKChipFlowLayout` | Layout | Wrapping flex-flow layout for chip clouds (iOS 16+) |
| `SFKChipItem` | protocol | Selectable-chip data: label and optional icon |

### Settings
| Type | Kind | Description |
|------|------|-------------|
| `SFKSettingsScreen` | View | Full settings form with headers, custom/standard sections, aura |
| `SFKSettingsSectionConfiguration` | struct | Standard section with title, footer, items |
| `SFKSettingsCustomSection` | struct | Custom SwiftUI content section |
| `SFKSettingsTheme` | struct | Colors, Typography, Metrics — injected via environment |
| `SettingsItem` | protocol | Row item: id, icon, title, subtitle, tint |
| `SFKSettingsRow` | View | Tappable row with icon, title, subtitle, trailing view |
| `SFKSettingsLabel` | View | Display-only label row |
| `SFKSettingsToggle` / `SFKSettingsToggleRow` | View | Toggle rows (direct / item-driven) |
| `SFKSettingsDatePickerRow` / `SFKSettingsTimePickerRow` | View | Date/time pickers in sheet |
| `SFKSettingsInlineDatePicker` | View | Inline date picker |
| `SFKSettingsPickerRow` | View | Strongly typed option picker with action-sheet or searchable sheet presentation |
| `SFKSettingsStepperRow` / `SFKSettingsSliderRow` | View | Numeric input rows |
| `SFKSettingsColorPickerRow` / `SFKSettingsInlineColorPicker` | View | Color picker rows |
| `SFKSettingsLinkRow` / `SFKSettingsDestructiveRow` / `SFKSettingsConfirmationRow` | View | Link, destructive, and confirmation rows |
| `SFKInformationSectionItem` | enum | Predefined info items (version, rate, privacy, etc.) |
| `SFKDeveloperSectionItem` | enum | Predefined developer items (website, twitter, another app) |
| `SFKSettingsActionHandler` | class | Common actions: rate, share, open URL, request review |

### Onboarding
| Type | Kind | Description |
|------|------|-------------|
| `SFKSegmentedProgress` | View | Capsule-style step progress indicator |
| `SFKTypography` | (modifiers) | `.sfkFlowTitleStyle()`, `.sfkFlowSubtitleStyle()`, etc. |
| `SFKCard` | View | Card container with icon, background, padding |

### Pickers
| Type | Kind | Description |
|------|------|-------------|
| `SFKColorPickerSheet` | View | Hosted color picker sheet with presets, custom color, preview, and explicit apply |
| `SFKColorPickerDelegate` | protocol | Delegate callback for `SFKColorPickerSheet` apply actions |
| `SFKItemPickerView` | View | Full searchable item picker/list screen with sections, selection, toolbar actions, browsing mode, context actions, and swipe actions |
| `SFKItemPickerViewModel` | class | Selection, search, sectioned, and reloadable item state management |
| `SFKItemPickerSection` | struct | Optional list section with header, footer, and pickable items |
| `SFKPickableItem` | protocol | Item model: id, icon, title, subtitle, optional badge, optional icon tint |
| `SFKPickableItemIconKind` | enum | Icon source: image, SF Symbol, text, none |
| `SFKItemPickerSelectionMode` | enum | `.single` or `.multi` |
| `SFKItemPickerToolbarAction` | struct | Navigation bar action rendered by the picker |
| `SFKItemPickerItemAction` | struct | Row-level context-menu or swipe action |
| `SFKItemPickerDelegate` | protocol | Selection callbacks |

### Effects
| Type | Kind | Description |
|------|------|-------------|
| `TopAuraBackground` | View | Layered radial + linear gradient background |
| `SFKAuraLayer` | View | Accessibility-gated aura glow (respects reduce motion) |
| `SFKAuraGlowBackground` | View | Full-screen atmospheric glow wrapping content |

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
// Primary action
SFKButton("Continue", leadingIconName: "arrow.right", style: .primary) {
    nextStep()
}

// Secondary action
SFKButton("Filters", style: .secondary) {
    showFilters()
}

// System toolbar action
SFKButton(leadingIconName: "ellipsis", style: .toolbar) {
    showMoreActions()
}

// Compact inline action
SFKButton("Edit", fullWidth: false, controlSize: .small, style: .secondary) {
    editItem()
}

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
SFKSettingsScreen(
    sections: [
        SFKSettingsSectionConfiguration(title: "Preferences", items: [
            AppSettingsItem.notifications
        ])
    ]
)

// Onboarding
SFKSegmentedProgress(currentStep: 2, totalSteps: 5)
SFKChipFlowLayout(spacing: 8) {
    ForEach(items) { SFKSelectableChip(item: $0, controlSize: .small) }
}

// Item Picker
Coordinator().presentItemPicker(title: "Currency", items: Currency.sortedAllCases)

// Color Picker
SFKColorPickerSheet(
    selectedColor: .blue,
    promptTitle: "Choose an account color",
    promptMessage: "Pick a color that makes this account easy to spot.",
    delegate: colorDelegate
)

// Item list with row actions
SFKItemPickerView(
    pageTitle: "Accounts",
    viewModel: viewModel,
    selectsItems: false,
    toolbarActions: [
        SFKItemPickerToolbarAction(systemImage: "plus.circle.fill") {
            addItem()
        }
    ],
    onSelect: { item in edit(item) },
    actionsProvider: { item in [
        SFKItemPickerItemAction(title: "Delete", systemImage: "trash", role: .destructive, presentation: .swipe) {
            delete(item)
        }
    ] }
)

// Sectioned picker
let pickerViewModel = SFKItemPickerViewModel(
    sections: [
        SFKItemPickerSection(title: "System", items: systemItems),
        SFKItemPickerSection(title: "Custom", items: customItems)
    ]
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
| `UINavigationController+.swift` | `presentView()`, `pushView()` for SwiftUI in UIKit |
| `UIApplication+SafeArea.swift` | Safe area inset shortcuts |
| `CGTypes+Extensions.swift` | CGPoint/CGSize/CGRect/CGVector/UIEdgeInsets math |

## Source Files

- `Buttons/` — SFKButton, SFKCloseButton, semantic styles, and isolated legacy adapters
- `ColorPicker/` — SFKColorPickerSheet, SFKColorPickerDelegate
- `Settings/` — 14+ row type files, theme, action handler, screen
- `Chips/` — Primary and secondary action chips
- `Onboarding/` — Selectable chips, flow layout, progress, typography, and cards
- `ItemPicker/` — View, view model, delegate, row, models
- `Effects/` — Aura layer, glow background, top aura
- `SwiftUIExtensions/` — Glass button modifiers
- `UIKitExtensions/` — 8 files covering UIColor, UIImage, UIView, etc.
- `BarcodeScanner/` — BarcodeScannerScreen, view, configuration
- `ProBanner/` — SFKProBannerView
- `AlertPresenter.swift` — Alerts and confirmations
- `PhotoPicker.swift` — PHPicker wrapper
- `SFKAppearanceManager.swift` — UIKit rounded typography
- `SFKRoundedHostingController.swift` — Rounded font hosting controller
