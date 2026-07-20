# UI

Reusable SwiftUI and UIKit components for buttons, settings, onboarding, pickers, glass effects, aura backgrounds, barcode scanning, pro banners, and app appearance.

## Public API

### Buttons
| Type | Kind | Description |
|------|------|-------------|
| `SFKButton` | View | Configurable init-based button with loading states, haptics, and glass chrome |
| `SFKCloseButton` | View | Standardized icon-only or labeled close/dismiss button (`toolbar` or `glass` chrome) |
| `SFKCloseButtonChrome` | enum | `toolbar` (system nav-bar treatment), `glass` (icon circle or labeled capsule over content) |
| `SFKButtonChrome` | enum | glassProminent, glass, glassEffect, plain |
| `SFKButtonHapticStyle` | enum | light, medium, heavy tap feedback |

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
| `SFKSettingsPickerRow` / `SFKSettingsPickerSheetRow` | View | Option pickers (action sheet / sheet) |
| `SFKSettingsStepperRow` / `SFKSettingsSliderRow` | View | Numeric input rows |
| `SFKSettingsColorPickerRow` / `SFKSettingsInlineColorPicker` | View | Color picker rows |
| `SFKSettingsLinkRow` / `SFKSettingsDestructiveRow` / `SFKSettingsConfirmationRow` | View | Link, destructive, and confirmation rows |
| `SFKInformationSectionItem` | enum | Predefined info items (version, rate, privacy, etc.) |
| `SFKDeveloperSectionItem` | enum | Predefined developer items (website, twitter, another app) |
| `SFKSettingsActionHandler` | class | Common actions: rate, share, open URL, request review |

### Onboarding
| Type | Kind | Description |
|------|------|-------------|
| `SFKChipFlowLayout` | Layout | Wrapping flex-flow layout for chip clouds (iOS 16+) |
| `SFKSelectableChip` | View | Selectable chip with glass effect, haptics, stroke |
| `SFKChipItem` | protocol | Chip data: label, optional icon |
| `SFKSegmentedProgress` | View | Capsule-style step progress indicator |
| `SFKSecondaryButton` | View | Subtle text-only skip/dismiss button |
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
| `.sfkGlass(emphasis:color:style:isInteractive:shape:)` | Unified Liquid Glass effect with a pre-iOS-26 fallback. Use `emphasis` for button styles and `shape:` for `.glassEffect` on a custom shape. |
| `SFKGlassEmphasis` | `.prominent` (filled glass, primary actions) or `.regular` (translucent glass, secondary actions) |
| `SFKGlassStyle` | `.regular` / `.clear` / `.identity` — the system `Glass` preset when `shape:` is non-nil |
| `SFKGlassShape` | `.roundedRectangle(cornerRadius:style:)` / `.capsule` / `.circle` |

### Other
| Type | Kind | Description |
|------|------|-------------|
| `BarcodeScannerScreen` | View | Full live camera barcode scanner |
| `BarcodeScannerConfiguration` | struct | Scanner configuration |
| `BarcodeScannerResult` | struct | Scan result payload |
| `SFKProBannerView` | View | Pro upgrade banner |
| `AlertController` | class | SwiftUI-native alert management |
| `AlertPresenter` | struct | UIKit alert/confirmation/text-input presenter |
| `PhotoPicker` | class | PHPickerViewController wrapper |
| `SFKAppearanceManager` | enum | Global rounded UIKit typography configuration |
| `SFKRoundedHostingController` | class | UIHostingController with `.fontDesign(.rounded)` |

## Quick Examples

```swift
// Button
SFKButton("Continue", leadingIconName: "arrow.right") {
    nextStep()
}

// Regular glass and plain chrome default to semantic primary text for contrast.
SFKButton("Filters", chrome: .glass) {
    showFilters()
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
    ForEach(items) { SFKSelectableChip(item: $0) }
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
    .glassProminentCompat(color: .blue)

// Alerts
AlertController().showAlert(title: "Done", message: "Saved successfully")
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

- `Buttons/` — SFKButton, SFKCloseButton, SFKButtonConfigurator, SFKButtonPreviewGallery
- `ColorPicker/` — SFKColorPickerSheet, SFKColorPickerDelegate
- `Settings/` — 14+ row type files, theme, action handler, screen
- `Onboarding/` — Chip, layout, progress, typography, card, secondary button
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
