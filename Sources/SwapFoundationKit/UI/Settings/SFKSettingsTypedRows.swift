import SwiftUI

/// Focused presentation overrides for ``SFKSettingsPicker``.
public struct SFKSettingsPickerPresentation {
    public var subtitle: String
    public var systemImage: String
    public var tint: Color?

    public init(
        subtitle: String = "",
        systemImage: String = "list.bullet",
        tint: Color? = nil
    ) {
        self.subtitle = subtitle
        self.systemImage = systemImage
        self.tint = tint
    }
}

/// A typed picker row for the settings result-builder API.
///
/// Unlike the legacy picker row, this control keeps the selected value and
/// option labels generic. It uses a native menu, so it works in a `Form` and
/// does not need an intermediate erased picker model.
public struct SFKSettingsPicker<Value: Hashable>: View {
    @Environment(\.sfkSettingsTheme) private var theme

    private let title: String
    private let subtitle: String
    private let systemImage: String
    private let tint: Color?
    private let options: [Value]
    private let label: (Value) -> String
    private let onChange: ((Value) -> Void)?
    @Binding private var selection: Value

    public init(
        _ title: String,
        selection: Binding<Value>,
        options: [Value],
        label: @escaping (Value) -> String = { String(describing: $0) },
        onChange: ((Value) -> Void)? = nil,
        presentation: SFKSettingsPickerPresentation = .init()
    ) {
        self.title = title
        self.subtitle = presentation.subtitle
        self.systemImage = presentation.systemImage
        self.tint = presentation.tint
        self.options = options
        self.label = label
        self.onChange = onChange
        self._selection = selection
    }

    /// Convenience initializer for enum-backed settings.
    public init<Values: RandomAccessCollection>(
        _ title: String,
        selection: Binding<Value>,
        options: Values,
        label: @escaping (Value) -> String = { String(describing: $0) },
        onChange: ((Value) -> Void)? = nil,
        presentation: SFKSettingsPickerPresentation = .init()
    ) where Values.Element == Value {
        self.init(
            title,
            selection: selection,
            options: Array(options),
            label: label,
            onChange: onChange,
            presentation: presentation
        )
    }

    public var body: some View {
        Menu {
            ForEach(options, id: \.self) { option in
                Button {
                    selection = option
                    onChange?(option)
                } label: {
                    HStack {
                        Text(label(option))
                        if option == selection { Image(systemName: "checkmark") }
                    }
                }
            }
        } label: {
            _SFKSettingsRowContent(
                title: title,
                subtitle: subtitle,
                icon: systemImage,
                tint: theme.resolvedTint(tint)
            ) {
                HStack(spacing: theme.metrics.trailingSpacing) {
                    Text(label(selection))
                        .font(theme.typography.valueFont)
                        .foregroundStyle(theme.colors.valueColor)
                        .multilineTextAlignment(.trailing)
                    Image(systemName: "chevron.right")
                        .font(theme.typography.accessoryFont)
                        .foregroundStyle(theme.colors.accessoryColor)
                }
            }
            .padding(.vertical, theme.metrics.rowVerticalPadding)
            .contentShape(Rectangle())
        }
        .buttonStyle(SFKSettingsFormRowButtonStyle())
        .accessibilityValue(label(selection))
    }
}

/// A typed value row for a binding whose value is edited by an action.
///
/// Use this when a setting owns a custom editor or navigation destination. The
/// action receives the current value and can present that editor in the host.
public struct SFKSettingsBindingRow<Value>: View {
    @Environment(\.sfkSettingsTheme) private var theme

    private let title: String
    private let subtitle: String
    private let systemImage: String
    private let tint: Color?
    private let valueLabel: (Value) -> String
    private let action: (Value) -> Void
    @Binding private var value: Value

    public init(
        _ title: String,
        value: Binding<Value>,
        valueLabel: @escaping (Value) -> String,
        action: @escaping (Value) -> Void,
        presentation: SFKSettingsPickerPresentation = .init(systemImage: "slider.horizontal.3")
    ) {
        self.title = title
        self.subtitle = presentation.subtitle
        self.systemImage = presentation.systemImage
        self.tint = presentation.tint
        self._value = value
        self.valueLabel = valueLabel
        self.action = action
    }

    public var body: some View {
        Button { action(value) } label: {
            _SFKSettingsRowContent(
                title: title,
                subtitle: subtitle,
                icon: systemImage,
                tint: theme.resolvedTint(tint)
            ) {
                HStack(spacing: theme.metrics.trailingSpacing) {
                    Text(valueLabel(value))
                        .font(theme.typography.valueFont)
                        .foregroundStyle(theme.colors.valueColor)
                        .multilineTextAlignment(.trailing)
                    Image(systemName: "chevron.right")
                        .font(theme.typography.accessoryFont)
                        .foregroundStyle(theme.colors.accessoryColor)
                }
            }
            .padding(.vertical, theme.metrics.rowVerticalPadding)
            .contentShape(Rectangle())
        }
        .buttonStyle(SFKSettingsFormRowButtonStyle())
    }
}

#Preview("Typed Settings — Dynamic Type / Dark") {
    @Previewable @State var enabled = true
    @Previewable @State var priority = 2

    SFKSettingsScreen {
        SFKSettingsSection("Accessibility") {
            SFKSettingsToggle("Notifications", systemImage: "bell", isOn: $enabled)
                .disabled(true)
            SFKSettingsPicker(
                "Priority",
                selection: $priority,
                options: [1, 2, 3],
                label: { "Level \($0)" }
            )
        }
    }
    .environment(\.dynamicTypeSize, .accessibility2)
    .environment(\.colorScheme, .dark)
}
