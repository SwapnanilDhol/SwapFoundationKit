# v4 control API removals

This ledger records the breaking UI cleanup in the v4 controls workstream. The
removed symbols are intentionally not typealiases or deprecated forwarding
facades: v4 callers must use the canonical semantic APIs.

## Removed symbols and replacements

| Removed | Replacement |
| --- | --- |
| `SFKButton.init(_:leadingIconName:subtitle:isLoading:fullWidth:...:)` | `SFKButton(_:role:action:)` with `.sfkIcon`, `.sfkSubtitle`, `.sfkLoading`, `.sfkFullWidth`, `.sfkTint`, and `.sfkControlSize` modifiers |
| `SFKButton+Legacy.swift` | No compatibility initializer; use the semantic button API |
| `SFKButtonConfigurator` | `SFKButton` role plus focused modifiers |
| `SFKButtonChrome` | `SFKButtonStyle` for button hierarchy, or `.sfkGlass(material:tint:isInteractive:shape:)` for custom surfaces |
| `SFKButtonHapticStyle` | `SFKTheme.Feedback.Style`, configured once with `.sfkTheme(...)` |
| `SFKChipHapticStyle` | `SFKTheme.Feedback.Style`, shared by buttons, action chips, and selectable chips |
| `SFKGlassEmphasis` and `SFKGlassStyle` | `SFKGlassMaterial` and `SFKGlassShape` on the focused `sfkGlass` modifier |
| `SFKChipItem` and `SFKSelectableChip(item:...)` | `SFKSelectableChip(_:icon:isSelected:...)` |
| `SFKSecondaryButton` | `SFKButton(_:role: .secondary, action:)` |
| `SFKTextField.init(...placeholder:...status:...keyboardType:...)` | `SFKTextField(_:text:prompt:leadingSystemImage:isSecure:)` with `.sfkInput`, `.sfkStatus`, `.sfkSupportingText`, `.sfkFocused`, `.sfkTrailingAction`, and `.sfkAppearance` |
| Generic `UINavigationController.presentView(view:)` / `pushView(view:)` extensions | Native `UIHostingController` construction at the host navigation boundary |
| `TopAuraBackground` 12-argument tuning initializer | `TopAuraBackground(baseColor:glow:layout:)`; use nested `Glow` and `Layout` configs for advanced tuning, or the compact four-argument convenience |

`SFKTextFieldAppearance` keeps its semantic color/status configuration in a
nine-argument initializer. Layout metrics are intentionally focused through
`appearance.metrics(cornerRadius:minimumHeight:horizontalPadding:contentSpacing:)`.
This keeps every public initializer at ten arguments or fewer while retaining
the appearance customization surface.

## UIKit helper audit

The generic `UINavigationController` SwiftUI presentation/push helpers were
unused outside their compatibility tests and duplicated the host's navigation
boundary, so both the source file and construction-only test were removed.
The remaining UIKit extensions are retained because they provide distinct,
used primitives: safe-area access, view hierarchy traversal, Auto Layout
constraint handles, image/color processing, layer pixel sampling, and child
view-controller containment. `SFKAppearanceManager` and
`SFKRoundedHostingController` remain canonical specialized APIs; removing them
would discard useful UIKit/SwiftUI integration rather than consolidate a
duplicate helper.

## Surface result

The owned UI scope (including UIKitExtensions and the remaining non-picker UI)
has 33 source-level public/open top-level declarations after this workstream,
down from 41 at the pre-v4 baseline. The eight removed declarations are the
compatibility controls, duplicate secondary control, legacy glass
configuration enums, and obsolete generic chip adapter listed above. Nested
theme and component configuration types remain where they describe the owning
API. The integrator's final inventory must report any additional reduction
needed for the reviewed <=21 controls target rather than treating symbol moves
as removals. This source-level estimate intentionally differs from the
symbol-graph declaration count; the integrator's generated inventory remains
authoritative.
