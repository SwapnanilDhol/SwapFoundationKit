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
/// Start with ``standard`` and change only the tokens required by a host app's
/// theme. Input behavior and validation remain consistent across apps.
public struct SFKTextFieldAppearance {
    public var backgroundColor: Color
    public var focusedBackgroundColor: Color
    public var disabledBackgroundColor: Color
    public var borderColor: Color
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
}

/// A reusable text-input primitive with SFK styling, validation, accessibility,
/// and semantic keyboard configuration.
///
/// ## Usage
/// ```swift
/// SFKTextField(
///     "Email",
///     text: $email,
///     placeholder: "you@example.com",
///     leadingSystemImage: "envelope",
///     status: isEmailValid ? .normal : .error("Enter a valid email."),
///     keyboardType: .emailAddress,
///     contentType: .emailAddress,
///     textInputAutocapitalization: .never,
///     autocorrectionDisabled: true
/// )
/// ```
public struct SFKTextField: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.isEnabled) private var isEnabled
    @Binding private var text: String
    @FocusState private var isInternallyFocused: Bool
    @State private var revealsSecureText = false

    private let title: String?
    private let placeholder: String
    private let leadingSystemImage: String?
    private let trailingSystemImage: String?
    private let trailingAccessibilityLabel: String?
    private let supportingText: String?
    private let status: SFKTextFieldStatus
    private let tint: Color
    private let isSecure: Bool
    private let allowsSecureTextReveal: Bool
    private let keyboardType: UIKeyboardType
    private let contentType: UITextContentType?
    private let textInputAutocapitalization: TextInputAutocapitalization
    private let autocorrectionDisabled: Bool
    private let submitLabel: SubmitLabel
    private let externalFocus: Binding<Bool>?
    private let accessibilityIdentifier: String?
    private let appearance: SFKTextFieldAppearance
    private let onSubmit: () -> Void
    private let onTrailingAction: (() -> Void)?

    public init(
        _ title: String? = nil,
        text: Binding<String>,
        placeholder: String,
        leadingSystemImage: String? = nil,
        trailingSystemImage: String? = nil,
        trailingAccessibilityLabel: String? = nil,
        supportingText: String? = nil,
        status: SFKTextFieldStatus = .normal,
        tint: Color = .accentColor,
        isSecure: Bool = false,
        allowsSecureTextReveal: Bool = true,
        keyboardType: UIKeyboardType = .default,
        contentType: UITextContentType? = nil,
        textInputAutocapitalization: TextInputAutocapitalization = .sentences,
        autocorrectionDisabled: Bool = false,
        submitLabel: SubmitLabel = .done,
        isFocused: Binding<Bool>? = nil,
        accessibilityIdentifier: String? = nil,
        appearance: SFKTextFieldAppearance = .standard,
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
        externalFocus = isFocused
        self.accessibilityIdentifier = accessibilityIdentifier
        self.appearance = appearance
        self.onSubmit = onSubmit
        self.onTrailingAction = onTrailingAction
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let title {
                Text(title)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(appearance.labelColor)
            }

            HStack(spacing: appearance.contentSpacing) {
                if let leadingSystemImage {
                    Image(systemName: leadingSystemImage)
                        .font(.body.weight(.medium))
                        .foregroundStyle(resolvedAccessoryColor)
                        .frame(width: 20)
                        .accessibilityHidden(true)
                }

                textInput

                trailingAccessory
            }
            .padding(.horizontal, appearance.horizontalPadding)
            .frame(minHeight: appearance.minimumHeight)
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
                .font(.footnote)
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
                    prompt: Text(placeholder).foregroundStyle(.secondary)
                )
            )
        } else {
            configuredInput(
                TextField(
                    "",
                    text: $text,
                    prompt: Text(placeholder).foregroundStyle(.secondary)
                )
            )
        }
    }

    private func configuredInput<Input: View>(_ input: Input) -> some View {
        input
            .font(.body)
            .foregroundStyle(.primary)
            .tint(tint)
            .keyboardType(keyboardType)
            .textContentType(contentType)
            .textInputAutocapitalization(textInputAutocapitalization)
            .autocorrectionDisabled(autocorrectionDisabled)
            .submitLabel(submitLabel)
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
        RoundedRectangle(cornerRadius: appearance.cornerRadius, style: .continuous)
            .fill(resolvedBackgroundColor)
    }

    private var fieldBorder: some View {
        RoundedRectangle(cornerRadius: appearance.cornerRadius, style: .continuous)
            .strokeBorder(resolvedBorderColor, lineWidth: resolvedBorderWidth)
    }

    private var resolvedBackgroundColor: Color {
        guard isEnabled else { return appearance.disabledBackgroundColor }
        return isInternallyFocused
            ? appearance.focusedBackgroundColor
            : appearance.backgroundColor
    }

    private var resolvedBorderColor: Color {
        switch status {
        case .normal:
            return isInternallyFocused ? tint : appearance.borderColor
        case .error:
            return appearance.errorColor
        case .success:
            return appearance.successColor
        }
    }

    private var resolvedBorderWidth: CGFloat {
        isInternallyFocused || status != .normal ? 1.5 : 1
    }

    private var resolvedAccessoryColor: Color {
        isInternallyFocused ? tint : .secondary
    }

    private var statusMessageColor: Color {
        switch status {
        case .normal:
            return appearance.supportingTextColor
        case .error:
            return appearance.errorColor
        case .success:
            return appearance.successColor
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
        reduceMotion ? nil : .spring(response: 0.3, dampingFraction: 1)
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
