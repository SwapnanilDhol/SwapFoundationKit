/****************************************************************************
 * SFKTextField.swift
 * SwapFoundationKit
 *****************************************************************************/

import SwiftUI
import UIKit

/// The semantic validation state displayed by ``SFKTextField``.
public enum SFKTextFieldStatus: Equatable, Sendable {
    case normal
    case error(String)
    case success(String?)

    var message: String? {
        switch self {
        case .normal:
            return nil
        case let .error(message):
            return message
        case let .success(message):
            return message
        }
    }
}

/// Appearance tokens shared by every ``SFKTextField`` instance.
///
/// The focused initializer derives defaults from ``SFKTheme``. Pass an
/// appearance explicitly when a field needs a local treatment; input behavior
/// and validation remain consistent across apps.
public struct SFKTextFieldAppearance {
    public var backgroundColor: Color
    public var focusedBackgroundColor: Color
    public var disabledBackgroundColor: Color
    public var borderColor: Color
    /// Border colour while the field is focused. `nil` uses the field's `tint`.
    ///
    /// Set it to `.clear` for a field that should not draw a focus ring — one embedded in a
    /// `Form` row, say, where the row already carries the surface and a ring inside it reads
    /// as a stray rectangle.
    public var focusedBorderColor: Color?
    public var labelColor: Color
    public var supportingTextColor: Color
    public var errorColor: Color
    public var successColor: Color
    public var cornerRadius: CGFloat
    public var minimumHeight: CGFloat
    public var horizontalPadding: CGFloat
    public var contentSpacing: CGFloat

    public init(
        backgroundColor: Color = Color(.secondarySystemGroupedBackground),
        focusedBackgroundColor: Color = Color(.systemBackground),
        disabledBackgroundColor: Color = Color(.tertiarySystemFill),
        borderColor: Color = Color.primary.opacity(0.12),
        focusedBorderColor: Color? = nil,
        labelColor: Color = .primary,
        supportingTextColor: Color = .secondary,
        errorColor: Color = .red,
        successColor: Color = .green,
        cornerRadius: CGFloat = 12,
        minimumHeight: CGFloat = 50,
        horizontalPadding: CGFloat = 14,
        contentSpacing: CGFloat = 10
    ) {
        self.backgroundColor = backgroundColor
        self.focusedBackgroundColor = focusedBackgroundColor
        self.disabledBackgroundColor = disabledBackgroundColor
        self.borderColor = borderColor
        self.focusedBorderColor = focusedBorderColor
        self.labelColor = labelColor
        self.supportingTextColor = supportingTextColor
        self.errorColor = errorColor
        self.successColor = successColor
        self.cornerRadius = cornerRadius
        self.minimumHeight = minimumHeight
        self.horizontalPadding = horizontalPadding
        self.contentSpacing = contentSpacing
    }

    public static let standard = SFKTextFieldAppearance()

    /// Creates the compatibility appearance projection for an ``SFKTheme``.
    ///
    /// Prefer injecting ``SFKTheme`` directly; this initializer is for hosts
    /// that still need to pass an appearance to an older field configuration.
    public init(theme: SFKTheme) {
        self.init(
            backgroundColor: theme.colors.surface,
            focusedBackgroundColor: theme.colors.background,
            disabledBackgroundColor: theme.colors.surface.opacity(0.7),
            borderColor: theme.colors.border,
            focusedBorderColor: theme.colors.accent,
            labelColor: theme.colors.text,
            supportingTextColor: theme.colors.secondaryText,
            errorColor: theme.colors.destructive,
            successColor: .green,
            cornerRadius: theme.radii.control,
            horizontalPadding: theme.spacing.control,
            contentSpacing: theme.spacing.inline
        )
    }
}

/// Focused input behavior for ``SFKTextField``.
///
/// Use the presets for common fields, then change only the options that differ
/// for a particular host screen. Presentation tokens remain in ``SFKTheme``.
public struct SFKTextFieldInputOptions {
    public var keyboardType: UIKeyboardType
    public var contentType: UITextContentType?
    public var textInputAutocapitalization: TextInputAutocapitalization
    public var autocorrectionDisabled: Bool
    public var submitLabel: SubmitLabel
    public var axis: Axis
    public var lineLimit: ClosedRange<Int>?
    public var textAlignment: TextAlignment
    public var font: Font?
    public var isSecure: Bool
    public var allowsSecureTextReveal: Bool

    public init(
        keyboardType: UIKeyboardType = .default,
        contentType: UITextContentType? = nil,
        textInputAutocapitalization: TextInputAutocapitalization = .sentences,
        autocorrectionDisabled: Bool = false,
        submitLabel: SubmitLabel = .done,
        axis: Axis = .horizontal,
        lineLimit: ClosedRange<Int>? = nil,
        textAlignment: TextAlignment = .leading,
        font: Font? = nil,
        isSecure: Bool = false
    ) {
        self.keyboardType = keyboardType
        self.contentType = contentType
        self.textInputAutocapitalization = textInputAutocapitalization
        self.autocorrectionDisabled = autocorrectionDisabled
        self.submitLabel = submitLabel
        self.axis = axis
        self.lineLimit = lineLimit
        self.textAlignment = textAlignment
        self.font = font
        self.isSecure = isSecure
        self.allowsSecureTextReveal = true
    }

    public static let standard = SFKTextFieldInputOptions()

    public static let email = SFKTextFieldInputOptions(
        keyboardType: .emailAddress,
        contentType: .emailAddress,
        textInputAutocapitalization: .never,
        autocorrectionDisabled: true,
        submitLabel: .next
    )

    public static let password = SFKTextFieldInputOptions(
        contentType: .password,
        autocorrectionDisabled: true,
        isSecure: true
    )
}

/// A reusable text-input primitive with SFK styling, validation, accessibility,
/// and semantic keyboard configuration.
///
/// ## Usage
/// ```swift
/// SFKTextField(
///     "Email",
///     text: $email,
///     prompt: "you@example.com",
///     leadingSystemImage: "envelope"
/// )
/// .sfkInput(.email)
/// .sfkStatus(isEmailValid ? .normal : .error("Enter a valid email."))
/// ```
public struct SFKTextField: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.sfkTheme) private var theme
    @Binding private var text: String
    @FocusState private var isInternallyFocused: Bool
    @State private var revealsSecureText = false

    private let title: String?
    private let placeholder: String
    private let leadingSystemImage: String?
    private var trailingSystemImage: String?
    private var trailingAccessibilityLabel: String?
    private var supportingText: String?
    private var status: SFKTextFieldStatus
    private var tint: Color?
    private var isSecure: Bool
    private var allowsSecureTextReveal: Bool
    private var keyboardType: UIKeyboardType
    private var contentType: UITextContentType?
    private var textInputAutocapitalization: TextInputAutocapitalization
    private var autocorrectionDisabled: Bool
    private var submitLabel: SubmitLabel
    private var axis: Axis
    private var lineLimit: ClosedRange<Int>?
    private var textAlignment: TextAlignment
    private var font: Font?
    private var externalFocus: Binding<Bool>?
    private var accessibilityIdentifier: String?
    private var appearance: SFKTextFieldAppearance?
    private var onSubmit: () -> Void
    private var onTrailingAction: (() -> Void)?

    /// Creates a focused, theme-aware field with the common input options.
    public init(
        _ title: String? = nil,
        text: Binding<String>,
        prompt: String? = nil,
        leadingSystemImage: String? = nil,
        isSecure: Bool = false
    ) {
        self.init(
            title,
            text: text,
            placeholder: prompt ?? title ?? "",
            leadingSystemImage: leadingSystemImage,
            isSecure: isSecure
        )
    }

    @_disfavoredOverload
    @available(*, deprecated, message: "Use the focused prompt: initializer or SFKTextField modifiers.")
    public init(
        _ title: String? = nil,
        text: Binding<String>,
        placeholder: String,
        leadingSystemImage: String? = nil,
        trailingSystemImage: String? = nil,
        trailingAccessibilityLabel: String? = nil,
        supportingText: String? = nil,
        status: SFKTextFieldStatus = .normal,
        tint: Color? = nil,
        isSecure: Bool = false,
        allowsSecureTextReveal: Bool = true,
        keyboardType: UIKeyboardType = .default,
        contentType: UITextContentType? = nil,
        textInputAutocapitalization: TextInputAutocapitalization = .sentences,
        autocorrectionDisabled: Bool = false,
        submitLabel: SubmitLabel = .done,
        axis: Axis = .horizontal,
        lineLimit: ClosedRange<Int>? = nil,
        textAlignment: TextAlignment = .leading,
        font: Font? = nil,
        isFocused: Binding<Bool>? = nil,
        accessibilityIdentifier: String? = nil,
        appearance: SFKTextFieldAppearance? = nil,
        onSubmit: @escaping () -> Void = {},
        onTrailingAction: (() -> Void)? = nil
    ) {
        self.title = title
        _text = text
        self.placeholder = placeholder
        self.leadingSystemImage = leadingSystemImage
        self.trailingSystemImage = trailingSystemImage
        self.trailingAccessibilityLabel = trailingAccessibilityLabel
        self.supportingText = supportingText
        self.status = status
        self.tint = tint
        self.isSecure = isSecure
        self.allowsSecureTextReveal = allowsSecureTextReveal
        self.keyboardType = keyboardType
        self.contentType = contentType
        self.textInputAutocapitalization = textInputAutocapitalization
        self.autocorrectionDisabled = autocorrectionDisabled
        self.submitLabel = submitLabel
        self.axis = axis
        self.lineLimit = lineLimit
        self.textAlignment = textAlignment
        self.font = font
        externalFocus = isFocused
        self.accessibilityIdentifier = accessibilityIdentifier
        self.appearance = appearance
        self.onSubmit = onSubmit
        self.onTrailingAction = onTrailingAction
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.inline) {
            if let title {
                Text(title)
                    .font(theme.typography.caption.weight(.medium))
                    .foregroundStyle(resolvedAppearance.labelColor)
            }

            HStack(spacing: resolvedAppearance.contentSpacing) {
                if let leadingSystemImage {
                    Image(systemName: leadingSystemImage)
                        .font(theme.typography.body.weight(.medium))
                        .foregroundStyle(resolvedAccessoryColor)
                        .frame(width: 20)
                        .accessibilityHidden(true)
                }

                textInput

                trailingAccessory
            }
            .padding(.horizontal, resolvedAppearance.horizontalPadding)
            .frame(minHeight: resolvedAppearance.minimumHeight)
            .background(fieldBackground)
            .overlay(fieldBorder)
            .contentShape(Rectangle())
            .onTapGesture {
                isInternallyFocused = true
            }
            .animation(fieldAnimation, value: isInternallyFocused)
            .animation(fieldAnimation, value: status)

            if let message = status.message ?? supportingText {
                Label {
                    Text(message)
                } icon: {
                    if let statusIcon {
                        Image(systemName: statusIcon)
                    }
                }
                .font(theme.typography.caption)
                .foregroundStyle(statusMessageColor)
                .fixedSize(horizontal: false, vertical: true)
            }
        }
        .onAppear {
            if externalFocus?.wrappedValue == true {
                isInternallyFocused = true
            }
        }
        .onChange(of: isInternallyFocused) { _, isFocused in
            guard externalFocus?.wrappedValue != isFocused else { return }
            externalFocus?.wrappedValue = isFocused
        }
        .onChange(of: externalFocus?.wrappedValue) { _, isFocused in
            guard let isFocused, isInternallyFocused != isFocused else { return }
            isInternallyFocused = isFocused
        }
    }

    @ViewBuilder
    private var textInput: some View {
        if isSecure && !revealsSecureText {
            configuredInput(
                SecureField(
                    "",
                    text: $text,
                    prompt: Text(placeholder).foregroundStyle(theme.colors.secondaryText)
                )
            )
        } else {
            configuredInput(
                TextField(
                    "",
                    text: $text,
                    prompt: Text(placeholder).foregroundStyle(theme.colors.secondaryText),
                    axis: axis
                )
            )
        }
    }

    @ViewBuilder
    private func configuredInput<Input: View>(_ input: Input) -> some View {
        if let lineLimit {
            configuredBaseInput(input)
                .lineLimit(lineLimit)
        } else {
            configuredBaseInput(input)
        }
    }

    private func configuredBaseInput<Input: View>(_ input: Input) -> some View {
        input
            .font(font ?? theme.typography.body)
            .foregroundStyle(theme.colors.text)
            .tint(resolvedTint)
            .keyboardType(keyboardType)
            .textContentType(contentType)
            .textInputAutocapitalization(textInputAutocapitalization)
            .autocorrectionDisabled(autocorrectionDisabled)
            .submitLabel(submitLabel)
            .multilineTextAlignment(textAlignment)
            .focused($isInternallyFocused)
            .onSubmit(onSubmit)
            .accessibilityIdentifier(accessibilityIdentifier ?? "")
    }

    @ViewBuilder
    private var trailingAccessory: some View {
        if isSecure && allowsSecureTextReveal {
            Button {
                revealsSecureText.toggle()
            } label: {
                Image(systemName: revealsSecureText ? "eye.slash" : "eye")
                    .frame(width: 28, height: 28)
            }
            .buttonStyle(.plain)
            .foregroundStyle(resolvedAccessoryColor)
            .accessibilityLabel(revealsSecureText ? "Hide text" : "Show text")
        } else if let trailingSystemImage {
            Button {
                onTrailingAction?()
            } label: {
                Image(systemName: trailingSystemImage)
                    .frame(width: 28, height: 28)
            }
            .buttonStyle(.plain)
            .foregroundStyle(resolvedAccessoryColor)
            .disabled(onTrailingAction == nil)
            .accessibilityLabel(trailingAccessibilityLabel ?? "")
        }
    }

    private var fieldBackground: some View {
        RoundedRectangle(cornerRadius: resolvedAppearance.cornerRadius, style: .continuous)
            .fill(resolvedBackgroundColor)
    }

    private var fieldBorder: some View {
        RoundedRectangle(cornerRadius: resolvedAppearance.cornerRadius, style: .continuous)
            .strokeBorder(resolvedBorderColor, lineWidth: resolvedBorderWidth)
    }

    private var resolvedBackgroundColor: Color {
        guard isEnabled else { return resolvedAppearance.disabledBackgroundColor }
        return isInternallyFocused
            ? resolvedAppearance.focusedBackgroundColor
            : resolvedAppearance.backgroundColor
    }

    private var resolvedBorderColor: Color {
        switch status {
        case .normal:
            guard isInternallyFocused else { return resolvedAppearance.borderColor }
            return resolvedAppearance.focusedBorderColor ?? resolvedTint
        case .error:
            return resolvedAppearance.errorColor
        case .success:
            return resolvedAppearance.successColor
        }
    }

    private var resolvedBorderWidth: CGFloat {
        isInternallyFocused || status != .normal ? 1.5 : 1
    }

    private var resolvedAccessoryColor: Color {
        isInternallyFocused ? resolvedTint : theme.colors.secondaryText
    }

    private var statusMessageColor: Color {
        switch status {
        case .normal:
            return resolvedAppearance.supportingTextColor
        case .error:
            return resolvedAppearance.errorColor
        case .success:
            return resolvedAppearance.successColor
        }
    }

    private var statusIcon: String? {
        switch status {
        case .normal:
            return nil
        case .error:
            return "exclamationmark.circle.fill"
        case .success:
            return "checkmark.circle.fill"
        }
    }

    private var fieldAnimation: Animation? {
        reduceMotion ? nil : theme.motion.standard
    }

    private var resolvedTint: Color {
        tint ?? theme.colors.accent
    }

    /// Returns a copy with semantic validation status applied.
    public func sfkStatus(_ status: SFKTextFieldStatus) -> Self {
        var copy = self
        copy.status = status
        return copy
    }

    /// Returns a copy with supporting/help text applied.
    public func sfkSupportingText(_ text: String?) -> Self {
        var copy = self
        copy.supportingText = text
        return copy
    }

    /// Returns a copy with an explicit tint. `nil` restores the theme accent.
    public func sfkTint(_ tint: Color?) -> Self {
        var copy = self
        copy.tint = tint
        return copy
    }

    /// Returns a copy with a submit action for the focused field API.
    public func sfkOnSubmit(_ action: @escaping () -> Void) -> Self {
        var copy = self
        copy.onSubmit = action
        return copy
    }

    /// Returns a copy configured for secure or ordinary text entry.
    public func sfkSecure(_ secure: Bool = true) -> Self {
        var copy = self
        copy.isSecure = secure
        return copy
    }

    /// Returns a copy controlling whether secure text can be revealed.
    public func sfkAllowsSecureTextReveal(_ allows: Bool = true) -> Self {
        var copy = self
        copy.allowsSecureTextReveal = allows
        return copy
    }

    /// Returns a copy with keyboard, content-type, multiline, and secure-input
    /// behavior applied as one focused configuration.
    public func sfkInput(_ options: SFKTextFieldInputOptions) -> Self {
        var copy = self
        copy.keyboardType = options.keyboardType
        copy.contentType = options.contentType
        copy.textInputAutocapitalization = options.textInputAutocapitalization
        copy.autocorrectionDisabled = options.autocorrectionDisabled
        copy.submitLabel = options.submitLabel
        copy.axis = options.axis
        copy.lineLimit = options.lineLimit
        copy.textAlignment = options.textAlignment
        copy.font = options.font
        copy.isSecure = options.isSecure
        copy.allowsSecureTextReveal = options.allowsSecureTextReveal
        return copy
    }

    /// Returns a copy synchronized with the host's focus state.
    public func sfkFocused(_ focused: Binding<Bool>) -> Self {
        var copy = self
        copy.externalFocus = focused
        return copy
    }

    /// Returns a copy with a trailing accessory action.
    public func sfkTrailingAction(
        systemImage: String,
        accessibilityLabel: String? = nil,
        action: @escaping () -> Void
    ) -> Self {
        var copy = self
        copy.trailingSystemImage = systemImage
        copy.trailingAccessibilityLabel = accessibilityLabel
        copy.onTrailingAction = action
        return copy
    }

    /// Returns a copy with an explicit appearance projection.
    public func sfkAppearance(_ appearance: SFKTextFieldAppearance?) -> Self {
        var copy = self
        copy.appearance = appearance
        return copy
    }

    private var resolvedAppearance: SFKTextFieldAppearance {
        appearance ?? SFKTextFieldAppearance(theme: theme)
    }
}

#Preview("SFK Text Fields") {
    @Previewable @State var name = ""
    @Previewable @State var email = "invalid"
    @Previewable @State var password = "secret"

    ScrollView {
        VStack(spacing: 20) {
            SFKTextField(
                "Name",
                text: $name,
                placeholder: "Optional",
                leadingSystemImage: "person"
            )

            SFKTextField(
                "Email",
                text: $email,
                placeholder: "you@example.com",
                leadingSystemImage: "envelope",
                status: .error("Enter a valid email address."),
                keyboardType: .emailAddress,
                contentType: .emailAddress,
                textInputAutocapitalization: .never,
                autocorrectionDisabled: true
            )

            SFKTextField(
                "Password",
                text: $password,
                placeholder: "Required",
                leadingSystemImage: "lock",
                supportingText: "Use at least eight characters.",
                isSecure: true,
                contentType: .password
            )
        }
        .padding(20)
    }
    .background(Color(.systemGroupedBackground))
}
