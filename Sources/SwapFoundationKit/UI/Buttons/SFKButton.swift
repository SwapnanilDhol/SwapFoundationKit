/*****************************************************************************
 * SFKButton.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2026 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import SwiftUI

@available(iOS 16, *)
public struct SFKButton: View {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.sfkTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    private let hapticsHelper = HapticsHelper()

    private let title: String
    private var leadingIconName: String?
    private var subtitle: String?
    private var isLoading: Bool
    private var fullWidth: Bool
    private var tintOverride: Color?
    private var controlSize: ControlSize
    private var alignment: SFKButtonAlignment
    private let role: SFKButtonStyle
    private let action: () -> Void

    /// Creates a semantic, theme-aware button.
    public init(
        _ title: String,
        role: SFKButtonStyle = .primary,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.role = role
        self.leadingIconName = nil
        self.subtitle = nil
        self.isLoading = false
        self.fullWidth = true
        self.tintOverride = nil
        self.controlSize = .regular
        self.alignment = .center
        self.action = action
    }

    public var body: some View {
        let button = Button(role: role == .destructive ? .destructive : nil) {
            guard !isLoading else { return }
            triggerHapticIfNeeded()
            action()
        } label: {
            buttonLabel
                .padding(.horizontal, isBorderless ? 0 : resolvedHorizontalPadding)
                .padding(.vertical, isBorderless ? 0 : resolvedVerticalPadding)
                .frame(
                    maxWidth: shouldUseFullWidth ? .infinity : nil,
                    alignment: alignment.frameAlignment
                )
                .foregroundStyle(resolvedTitleColor)
                .contentShape(Rectangle())
        }
        .disabled(isLoading)
        .accessibilityLabel(Text(accessibilityTitle))
        .accessibilityValue(isLoading ? Text("Loading") : Text(""))
        .animation(reduceMotion ? nil : theme.motion.standard, value: isLoading)

        styledButton(button.controlSize(controlSize))
    }

    @ViewBuilder
    private var buttonLabel: some View {
        if isLoading {
            ProgressView()
                .progressViewStyle(.circular)
                .tint(resolvedTitleColor)
        } else {
            HStack(spacing: resolvedSpacing) {
                if alignment == .trailing {
                    textContent
                    iconContent
                } else {
                    iconContent
                    textContent
                }
            }
        }
    }

    @ViewBuilder
    private var iconContent: some View {
        if let leadingIconName, !leadingIconName.isEmpty {
            Image(systemName: leadingIconName)
                .font(resolvedIconFont)
        }
    }

    @ViewBuilder
    private var textContent: some View {
        if hasTextContent {
            VStack(alignment: alignment.horizontalAlignment, spacing: 2) {
                if !title.isEmpty {
                    Text(title)
                        .font(resolvedTitleFont)
                        .foregroundStyle(resolvedTitleColor)
                }

                if let subtitle, !subtitle.isEmpty {
                    Text(subtitle)
                        .font(resolvedSubtitleFont)
                        .foregroundStyle(resolvedSubtitleColor)
                }
            }
        }
    }

    private var hasTextContent: Bool {
        let hasTitle = !title.isEmpty
        let hasSubtitle = subtitle?.isEmpty == false
        return hasTitle || hasSubtitle
    }

    private var accessibilityTitle: String {
        title.isEmpty ? "Button" : title
    }

    private var shouldUseFullWidth: Bool {
        fullWidth && !isLoading && !isBorderless
    }

    private var isBorderless: Bool {
        role == .borderless
    }

    private func triggerHapticIfNeeded() {
        guard isEnabled, !isLoading, theme.feedback.enabled else { return }

        switch theme.feedback.style {
        case .light:
            hapticsHelper.lightImpact()
        case .medium:
            hapticsHelper.mediumImpact()
        case .heavy:
            hapticsHelper.heavyImpact()
        case .none:
            break
        }
    }

    private var resolvedTitleColor: Color {
        guard isEnabled && !isLoading else { return Self.disabledTitleColor }
        switch role {
        case .primary: return theme.colors.onAccent
        case .destructive: return theme.colors.onDestructive
        case .secondary: return theme.colors.text
        case .borderless: return tintOverride ?? theme.colors.secondaryText
        }
    }

    private var resolvedSubtitleColor: Color {
        guard isEnabled && !isLoading else { return Self.disabledSubtitleColor }
        switch role {
        case .primary: return theme.colors.onAccent.opacity(0.8)
        case .destructive: return theme.colors.onDestructive.opacity(0.8)
        case .secondary: return theme.colors.secondaryText
        case .borderless: return tintOverride ?? theme.colors.secondaryText
        }
    }

    private var resolvedColor: Color {
        guard isEnabled && !isLoading else { return Self.disabledColor }
        if let tintOverride { return tintOverride }
        switch role {
        case .primary: return theme.colors.accent
        case .destructive: return theme.colors.destructive
        case .secondary, .borderless: return theme.colors.surface
        }
    }

    private var resolvedSpacing: CGFloat {
        theme.spacing.inline
    }

    private var resolvedHorizontalPadding: CGFloat {
        theme.spacing.control
    }

    private var resolvedVerticalPadding: CGFloat {
        theme.spacing.inline
    }

    private var resolvedTitleFont: Font {
        theme.typography.body.weight(.semibold)
    }

    private var resolvedSubtitleFont: Font {
        theme.typography.caption
    }

    private var resolvedIconFont: Font {
        theme.typography.body.weight(.semibold)
    }

    private static var disabledColor: Color {
        Color(.systemGray4).opacity(0.3)
    }

    private static var disabledTitleColor: Color {
        .secondary
    }

    private static var disabledSubtitleColor: Color {
        .secondary.opacity(0.8)
    }
}

public extension SFKButton {
    /// Returns a copy with its loading state changed.
    func sfkLoading(_ loading: Bool) -> Self {
        var copy = self
        copy.isLoading = loading
        return copy
    }

    /// Returns a copy with an optional leading SF Symbol.
    func sfkIcon(_ systemName: String?) -> Self {
        var copy = self
        copy.leadingIconName = systemName
        return copy
    }

    /// Returns a copy with supporting text.
    func sfkSubtitle(_ subtitle: String?) -> Self {
        var copy = self
        copy.subtitle = subtitle
        return copy
    }

    /// Returns a copy with a full-width or intrinsic-width layout.
    func sfkFullWidth(_ fullWidth: Bool) -> Self {
        var copy = self
        copy.fullWidth = fullWidth
        return copy
    }

    /// Returns a copy with an explicit tint, preserving the semantic role.
    func sfkTint(_ color: Color?) -> Self {
        var copy = self
        copy.tintOverride = color
        return copy
    }

    /// Returns a copy with a platform-relative control size.
    func sfkControlSize(_ controlSize: ControlSize) -> Self {
        var copy = self
        copy.controlSize = controlSize
        return copy
    }

    /// Returns a copy with semantic content alignment.
    func sfkAlignment(_ alignment: SFKButtonAlignment) -> Self {
        var copy = self
        copy.alignment = alignment
        return copy
    }
}

@available(iOS 16, *)
private extension SFKButton {
    @ViewBuilder
    func styledButton<Content: View>(_ content: Content) -> some View {
        if #available(iOS 26, *) {
            switch role {
            case .primary:
                content
                    .buttonStyle(.glassProminent)
                    .tint(resolvedColor)
            case .secondary:
                content
                    .buttonStyle(.glass)
                    .tint(resolvedColor)
            case .destructive:
                content
                    .buttonStyle(.glassProminent)
                    .tint(resolvedColor)
            case .borderless:
                content
                    .buttonStyle(.plain)
                    .tint(resolvedTitleColor)
            }
        } else {
            switch role {
            case .primary:
                content
                    .buttonStyle(.borderedProminent)
                    .tint(resolvedColor)
            case .secondary:
                content
                    .buttonStyle(.bordered)
                    .tint(resolvedColor)
            case .destructive:
                content
                    .buttonStyle(.borderedProminent)
                    .tint(resolvedColor)
            case .borderless:
                content
                    .buttonStyle(.plain)
                    .tint(resolvedTitleColor)
            }
        }
    }
}

// MARK: - Previews

#Preview("SFKButton Gallery") {
    VStack(spacing: 16) {
        SFKButton("Continue", role: .primary) { }
            .sfkIcon("arrow.right")
        SFKButton("Review", role: .secondary) { }
            .sfkIcon("doc.text")
            .sfkFullWidth(false)
        SFKButton("Skip", role: .borderless) { }
            .sfkFullWidth(false)
        SFKButton("Delete", role: .destructive) { }
            .sfkIcon("trash")
        SFKButton("Saving", role: .primary) { }
            .sfkLoading(true)
    }
    .padding()
}
