import SwiftUI
import UIKit
import Testing
@testable import SwapFoundationKit

/// Compile fixtures for the v4 typed settings and picker paths.
/// These intentionally exercise bindings and concrete callbacks without
/// launching a simulator; they verify API construction only. Behavioral and
/// accessibility validation remains a separate host-catalog UI test gate.
@MainActor
struct V4SettingsAndPickerCompilationTests {
    @Test
    func settingsBuilderKeepsConcreteBindings() {
        let enabled = Binding.constant(true)
        let value = Binding.constant(FixtureItem.first)

        let screen = SFKSettingsScreen {
            SFKSettingsSection("Preferences", footer: "Typed rows") {
                SFKSettingsToggle("Enabled", isOn: enabled)
                SFKSettingsPicker(
                    "Item",
                    selection: value,
                    options: FixtureItem.allCases,
                    label: { $0.title }
                )
                SFKSettingsRow("Advanced", systemImage: "gear") {}
            }
        }

        _ = screen
    }

    @Test
    func pickerSupportsOptionalNonOptionalAndMultiSelection() {
        let optional = Binding<FixtureItem?>(get: { .first }, set: { _ in })
        let nonOptional = Binding(get: { FixtureItem.first }, set: { _ in })
        let multiple = Binding<Set<FixtureItem>>(get: { [.first] }, set: { _ in })

        _ = SFKItemPickerView("Optional", items: FixtureItem.allCases, selection: optional,
                             label: { $0.title }, onSelect: { _ in })
        _ = SFKItemPickerView("Non-optional", items: FixtureItem.allCases, selection: nonOptional,
                             label: { $0.title }, onSelect: { _ in })
        _ = SFKItemPickerView("Multiple", items: FixtureItem.allCases, selections: multiple,
                             label: { $0.title }, onSelect: { _ in })
    }

    @Test
    func pickerConfigurationRetainsTypedActions() {
        var configuration = SFKItemPickerConfiguration<FixtureItem>(
            pageSubtitle: "Choose one",
            label: { $0.title },
            actionsProvider: { item in
                [SFKItemPickerItemAction(title: "Inspect \(item.title)", systemImage: "info.circle", presentation: .contextMenu) {}]
            }
        )
        configuration.showsCloseButton = false
        _ = SFKItemPickerView(pageTitle: "Configured", items: FixtureItem.allCases,
                              selection: Binding.constant(FixtureItem.first),
                              configuration: configuration)
    }

    @Test
    func colorAndPhotoUseClosuresAndBindings() {
        _ = SFKColorPickerSheet(selection: Binding.constant(Color.blue), onApply: { _ in })
        _ = SFKPhotoPicker(selection: Binding.constant(nil as UIImage?), onPick: { _ in })
    }
}

private enum FixtureItem: String, CaseIterable, Identifiable, Hashable, SFKPickableItem {
    case first
    case second

    var id: Self { self }
    var pickableItemId: String { rawValue }
    var pickableItemIconKind: SFKPickableItemIconKind { .systemIcon(symbolName: "circle") }
    var pickableItemTitle: String { title }
    var title: String { rawValue.capitalized }
    var pickableItemSubtitle: String? { "Fixture" }
}
