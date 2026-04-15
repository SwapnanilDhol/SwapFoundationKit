/*****************************************************************************
 * SFKButtons.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2025 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import SwiftUI

#if canImport(UIKit) && os(iOS)
import UIKit
#endif

// MARK: - SFKButtonStyle Protocol

/// Defines the visual style of an SFK button
public protocol SFKButtonStyle {
    var tint: Color { get }
    var isGlass: Bool { get }
    var cornerRadius: CGFloat { get }
}

/// Configuration for primary action buttons
public struct SFKPrimaryButtonStyle: SFKButtonStyle {
    public let tint: Color
    public let isGlass: Bool
    public let cornerRadius: CGFloat

    public init(tint: Color = .accentColor, isGlass: Bool = true, cornerRadius: CGFloat = 22) {
        self.tint = tint
        self.isGlass = isGlass
        self.cornerRadius = cornerRadius
    }
}

/// Configuration for secondary action buttons
public struct SFKSecondaryButtonStyle: SFKButtonStyle {
    public let tint: Color
    public let cornerRadius: CGFloat

    public init(tint: Color = .primary, cornerRadius: CGFloat = 22) {
        self.tint = tint
        self.cornerRadius = cornerRadius
    }

    public var isGlass: Bool { false }
}

// MARK: - Haptics Helper

#if canImport(UIKit) && os(iOS)
@MainActor
private final class ButtonHaptics {
    static let shared = ButtonHaptics()
    private let impactFeedbackGenerator = UIImpactFeedbackGenerator()
    private init() { impactFeedbackGenerator.prepare() }
    func mediumImpact() {
        impactFeedbackGenerator.impactOccurred()
    }
}
#else
private final class ButtonHaptics {
    static let shared = ButtonHaptics()
    func mediumImpact() { }
}
#endif

// MARK: - Visual Tokens

private enum SFKButtonVisualTokens {
    static let enabledOpacity: CGFloat = 1.0
    static let disabledOpacity: CGFloat = 0.72
    static let disabledForegroundOpacity: CGFloat = 0.7
    static let inlineFilledBackgroundOpacity: CGFloat = 0.14
    static let pillFallbackBackgroundOpacity: CGFloat = 0.18
    static let closeButtonTintOpacity: CGFloat = 0.22
    static let closeButtonFallbackBackgroundOpacity: CGFloat = 0.12
}

// MARK: - SFKButton Variants

/// A primary action button with glassmorphism effect, loading state, and haptic feedback.
///
/// ## Usage
/// ```swift
/// SFKPrimaryButton(
///     title: "Add Transaction",
///     systemImage: "wand.and.stars",
///     tint: .blue
/// ) {
///     // action
/// }
/// ```
public struct SFKPrimaryButton: View {
    private let title: String
    private let systemImage: String?
    private let style: SFKPrimaryButtonStyle
    private let isEnabled: Bool
    private let isLoading: Bool
    private let action: () -> Void
    private let haptics = ButtonHaptics.shared

    public init(
        title: String,
        systemImage: String? = nil,
        style: SFKPrimaryButtonStyle = .init(),
        isEnabled: Bool = true,
        isLoading: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.systemImage = systemImage
        self.style = style
        self.isEnabled = isEnabled
        self.isLoading = isLoading
        self.action = action
    }

    /// Convenience initializer with tint color instead of full style
    public init(
        title: String,
        systemImage: String? = nil,
        tint: Color,
        isEnabled: Bool = true,
        isLoading: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.systemImage = systemImage
        self.style = SFKPrimaryButtonStyle(tint: tint)
        self.isEnabled = isEnabled
        self.isLoading = isLoading
        self.action = action
    }

    public var body: some View {
        Button {
            guard isEnabled, !isLoading else { return }
            haptics.mediumImpact()
            action()
        } label: {
            HStack(spacing: 10) {
                if isLoading {
                    ProgressView()
                        .tint(foregroundColor)
                } else if let systemImage {
                    Image(systemName: systemImage)
                        .font(.headline)
                }

                Text(title)
                    .font(.headline.weight(.semibold))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .foregroundStyle(foregroundColor)
            .contentShape(Rectangle())
            .background(backgroundView)
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .disabled(!isEnabled || isLoading)
        .opacity(isEnabled ? SFKButtonVisualTokens.enabledOpacity : SFKButtonVisualTokens.disabledOpacity)
        .glassProminentButton(
            tint: style.tint.opacity(isEnabled ? SFKButtonVisualTokens.enabledOpacity : SFKButtonVisualTokens.disabledOpacity),
            fallbackBackgroundColor: style.tint.opacity(
                isEnabled ? SFKButtonVisualTokens.enabledOpacity : SFKButtonVisualTokens.disabledOpacity
            )
        )
    }

    private var foregroundColor: Color {
        isEnabled ? .white : .white.opacity(SFKButtonVisualTokens.disabledForegroundOpacity)
    }

    @ViewBuilder
    private var backgroundView: some View {
        RoundedRectangle(cornerRadius: style.cornerRadius, style: .continuous)
            .fill(style.tint.opacity(isEnabled ? SFKButtonVisualTokens.enabledOpacity : SFKButtonVisualTokens.disabledOpacity))
    }
}

/// A secondary action button with card-like surface styling.
public struct SFKSecondaryButton: View {
    private let title: String
    private let systemImage: String?
    private let style: SFKSecondaryButtonStyle
    private let isEnabled: Bool
    private let action: () -> Void
    private let haptics = ButtonHaptics.shared

    public init(
        title: String,
        systemImage: String? = nil,
        style: SFKSecondaryButtonStyle = .init(),
        isEnabled: Bool = true,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.systemImage = systemImage
        self.style = style
        self.isEnabled = isEnabled
        self.action = action
    }

    public var body: some View {
        Button {
            guard isEnabled else { return }
            haptics.mediumImpact()
            action()
        } label: {
            HStack(spacing: 10) {
                if let systemImage {
                    Image(systemName: systemImage)
                        .font(.headline)
                }

                Text(title)
                    .font(.headline.weight(.semibold))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .foregroundStyle(isEnabled ? .primary : .secondary)
            .contentShape(Rectangle())
            .background(backgroundColor)
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
        .disabled(!isEnabled)
        .opacity(isEnabled ? SFKButtonVisualTokens.enabledOpacity : SFKButtonVisualTokens.disabledOpacity)
        .glassProminentButton(
            tint: style.tint.opacity(isEnabled ? SFKButtonVisualTokens.enabledOpacity : SFKButtonVisualTokens.disabledOpacity),
            fallbackBackgroundColor: Color.secondary.opacity(
                isEnabled ? SFKButtonVisualTokens.inlineFilledBackgroundOpacity : SFKButtonVisualTokens.closeButtonFallbackBackgroundOpacity
            )
        )
    }

    private var backgroundColor: some View {
        #if canImport(UIKit) && os(iOS)
        return RoundedRectangle(cornerRadius: style.cornerRadius, style: .continuous)
            .fill(Color(uiColor: .secondarySystemGroupedBackground))
        #else
        return RoundedRectangle(cornerRadius: style.cornerRadius, style: .continuous)
            .fill(Color(nsColor: .windowBackgroundColor))
        #endif
    }
}

/// An inline action button for compact UI contexts.
public struct SFKInlineButton: View {
    public enum InlineStyle {
        case filled
        case plain
    }

    private let title: String
    private let systemImage: String?
    private let style: InlineStyle
    private let tint: Color
    private let isEnabled: Bool
    private let action: () -> Void
    private let haptics = ButtonHaptics.shared

    public init(
        title: String,
        systemImage: String? = nil,
        style: InlineStyle = .filled,
        tint: Color = .accentColor,
        isEnabled: Bool = true,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.systemImage = systemImage
        self.style = style
        self.tint = tint
        self.isEnabled = isEnabled
        self.action = action
    }

    public var body: some View {
        Button {
            guard isEnabled else { return }
            haptics.mediumImpact()
            action()
        } label: {
            HStack(spacing: 6) {
                if let systemImage {
                    Image(systemName: systemImage)
                        .font(.caption.weight(.semibold))
                }

                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .foregroundStyle(foregroundColor)
            .background(backgroundView)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .opacity(isEnabled ? SFKButtonVisualTokens.enabledOpacity : SFKButtonVisualTokens.disabledOpacity)
        .glassProminentButton(
            tint: tint.opacity(isEnabled ? SFKButtonVisualTokens.enabledOpacity : SFKButtonVisualTokens.disabledOpacity),
            fallbackBackgroundColor: style == .filled
                ? tint.opacity(SFKButtonVisualTokens.inlineFilledBackgroundOpacity)
                : Color.secondary.opacity(SFKButtonVisualTokens.closeButtonFallbackBackgroundOpacity)
        )
    }

    private var foregroundColor: Color {
        isEnabled ? tint : .secondary
    }

    @ViewBuilder
    private var backgroundView: some View {
        switch style {
        case .filled:
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(tint.opacity(SFKButtonVisualTokens.inlineFilledBackgroundOpacity))
        case .plain:
            Color.clear
        }
    }
}

/// A pill/capsule style button with glass effect.
public struct SFKPillButton: View {
    public enum PillStyle {
        case glass
        case toolbar
    }

    private let title: String
    private let systemImage: String?
    private let pillStyle: PillStyle
    private let tint: Color
    private let isEnabled: Bool
    private let action: () -> Void
    private let haptics = ButtonHaptics.shared

    public init(
        title: String,
        systemImage: String? = nil,
        pillStyle: PillStyle = .glass,
        tint: Color = .secondary,
        isEnabled: Bool = true,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.systemImage = systemImage
        self.pillStyle = pillStyle
        self.tint = tint
        self.isEnabled = isEnabled
        self.action = action
    }

    public var body: some View {
        Button {
            guard isEnabled else { return }
            haptics.mediumImpact()
            action()
        } label: {
            labelContent
                .foregroundStyle(isEnabled ? .primary : .secondary)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .opacity(isEnabled ? SFKButtonVisualTokens.enabledOpacity : SFKButtonVisualTokens.disabledOpacity)
    }

    @ViewBuilder
    private var labelContent: some View {
        let baseLabel = HStack(spacing: 8) {
            if let systemImage {
                Image(systemName: systemImage)
                    .font(.footnote.weight(.bold))
            }
            if !title.isEmpty {
                Text(title)
                    .font(.footnote.weight(.semibold))
                    .lineLimit(1)
            }
        }
        .fixedSize(horizontal: true, vertical: false)

        switch pillStyle {
        case .glass:
            baseLabel
                .padding(.horizontal, 11)
                .padding(.vertical, 8)
                .glassProminentButton(
                    tint: tint,
                    fallbackBackgroundColor: tint.opacity(SFKButtonVisualTokens.pillFallbackBackgroundOpacity)
                )
        case .toolbar:
            baseLabel
                .padding(.horizontal, 6)
                .padding(.vertical, 4)
        }
    }
}

/// A close/dismiss pill button (convenience initializer).
public struct SFKClosePillButton: View {
    public enum CloseStyle {
        case glass
        case toolbar
    }

    private let style: CloseStyle
    private let action: () -> Void

    public init(
        style: CloseStyle = .glass,
        action: @escaping () -> Void
    ) {
        self.style = style
        self.action = action
    }

    public var body: some View {
        SFKPillButton(
            title: "",
            systemImage: "xmark",
            pillStyle: style == .glass ? .glass : .toolbar,
            tint: .secondary,
            action: action
        )
    }
}

/// A glass-style close button with icon + text, recommended for modal sheets and onboarding flows.
///
/// Use this button instead of custom close implementations to maintain UI consistency across the app.
/// The button uses `.glassProminentButton()` modifier and includes haptic feedback on tap.
///
/// ## Usage
/// ```swift
/// struct MyModalView: View {
///     let onClose: () -> Void
///
///     var body: some View {
///         VStack {
///             SFKCloseButton(action: onClose)
///             // modal content
///         }
///     }
/// }
/// ```
public struct SFKCloseButton: View {
    private let action: () -> Void

    public init(action: @escaping () -> Void) {
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: "xmark")
                    .font(.footnote.weight(.bold))

                Text("Close")
                    .font(.footnote.weight(.semibold))
            }
            .foregroundStyle(.primary)
            .padding(.horizontal, 12)
            .padding(.vertical, 9)
        }
        .buttonStyle(.plain)
        .glassProminentButton(
            tint: Color.white.opacity(SFKButtonVisualTokens.closeButtonTintOpacity),
            fallbackBackgroundColor: Color.white.opacity(SFKButtonVisualTokens.closeButtonFallbackBackgroundOpacity)
        )
    }
}

/// A toolbar button with custom label support and haptic feedback.
public struct SFKToolbarButton<Label: View>: View {
    private let isEnabled: Bool
    private let action: () -> Void
    @ViewBuilder private let label: () -> Label
    private let haptics = ButtonHaptics.shared

    public init(
        isEnabled: Bool = true,
        action: @escaping () -> Void,
        @ViewBuilder label: @escaping () -> Label
    ) {
        self.isEnabled = isEnabled
        self.action = action
        self.label = label
    }

    public var body: some View {
        Button {
            guard isEnabled else { return }
            haptics.mediumImpact()
            action()
        } label: {
            label()
                .padding(.horizontal, 4)
                .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .glassProminentButton(
            tint: .secondary.opacity(isEnabled ? SFKButtonVisualTokens.enabledOpacity : SFKButtonVisualTokens.disabledOpacity),
            fallbackBackgroundColor: Color.secondary.opacity(SFKButtonVisualTokens.closeButtonFallbackBackgroundOpacity)
        )
    }

    /// Convenience initializer for simple toolbar buttons with title/image
    public init(
        title: String? = nil,
        systemImage: String? = nil,
        tint: Color = .primary,
        isEnabled: Bool = true,
        action: @escaping () -> Void
    ) where Label == SFKToolbarButtonLabel {
        self.isEnabled = isEnabled
        self.action = action
        self.label = {
            SFKToolbarButtonLabel(
                title: title,
                systemImage: systemImage,
                tint: tint,
                isEnabled: isEnabled
            )
        }
    }
}

/// Label view for SFKToolbarButton
public struct SFKToolbarButtonLabel: View {
    private let title: String?
    private let systemImage: String?
    private let tint: Color
    private let isEnabled: Bool

    public init(
        title: String? = nil,
        systemImage: String? = nil,
        tint: Color = .primary,
        isEnabled: Bool = true
    ) {
        self.title = title
        self.systemImage = systemImage
        self.tint = tint
        self.isEnabled = isEnabled
    }

    public var body: some View {
        Group {
            if let title, let systemImage {
                HStack(spacing: 6) {
                    Image(systemName: systemImage)
                        .font(.footnote.weight(.bold))
                    Text(title)
                        .font(.footnote.weight(.semibold))
                        .lineLimit(1)
                }
            } else if let title {
                Text(title)
                    .font(.footnote.weight(.semibold))
                    .lineLimit(1)
            } else if let systemImage {
                Image(systemName: systemImage)
                    .font(.headline.weight(.semibold))
            }
        }
        .foregroundStyle(isEnabled ? tint : .secondary)
        .fixedSize(horizontal: true, vertical: false)
    }
}

// MARK: - Previews

#if DEBUG
#Preview("SFK Primary Buttons") {
    VStack(spacing: 16) {
        SFKPrimaryButton(
            title: "Add Transaction",
            systemImage: "wand.and.stars",
            tint: .blue,
            action: {}
        )

        SFKPrimaryButton(
            title: "Record Transaction",
            tint: .green,
            action: {}
        )

        SFKPrimaryButton(
            title: "Loading...",
            tint: .accentColor,
            isLoading: true,
            action: {}
        )

        SFKPrimaryButton(
            title: "Disabled",
            tint: .accentColor,
            isEnabled: false,
            action: {}
        )
    }
    .padding()
    .background(Color.gray.opacity(0.2) as Color)
}

#Preview("SFK Secondary & Inline Buttons") {
    VStack(spacing: 16) {
        SFKSecondaryButton(title: "Cancel", action: {})

        SFKInlineButton(title: "Edit", systemImage: "pencil", action: {})

        SFKInlineButton(title: "Delete", systemImage: "trash", tint: .red, action: {})

        SFKInlineButton(title: "Plain Style", style: .plain, action: {})
    }
    .padding()
    .background(Color.gray.opacity(0.2) as Color)
}

#Preview("SFK Pill & Toolbar Buttons") {
    VStack(spacing: 20) {
        SFKPillButton(title: "Close", systemImage: "xmark", action: {})

        SFKPillButton(title: "Approve", systemImage: "checkmark", tint: .green, action: {})

        SFKClosePillButton(action: {})

        SFKCloseButton(action: {})

        HStack(spacing: 16) {
            SFKToolbarButton(title: "Save", systemImage: "checkmark", action: {})
            SFKToolbarButton(systemImage: "plus", action: {})
            SFKToolbarButton(title: "Edit", tint: .blue, action: {})
        }
    }
    .padding()
    .background(Color.gray.opacity(0.2) as Color)
}
#endif
