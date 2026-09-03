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
import UIKit

@available(iOS 16, *)
public struct SFKButton: View {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.sfkTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.colorScheme) private var colorScheme
    private let hapticsHelper = HapticsHelper()

    private let title: String
    private var leadingIconName: String?
    private var subtitle: String?
    private var isLoading: Bool
    private var fullWidth: Bool
    private var tintOverride: Color?
    private var labelColorOverride: Color?
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
        self.labelColorOverride = nil
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
                // The label owns its foreground. Button styles may supply the
                // container treatment, but never get to replace this color.
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
        if let labelColorOverride {
            return Color(
                SFKButtonLabelColorResolver.resolve(
                    labelColorOverride,
                    colorScheme: colorScheme
                )
            )
        }

        // Disabled/loading glass renders against a system-background-like
        // surface. Use the dynamic system label color for that state instead
        // of contrasting against the pre-disabled tint.
        guard isEnabled && !isLoading else { return .primary }
        return baseTitleColor
    }

    private var baseTitleColor: Color {
        switch role {
        case .primary:
            return filledTitleColor(background: resolvedBackgroundColor)
        case .destructive:
            return filledTitleColor(background: resolvedBackgroundColor)
        case .secondary:
            return filledTitleColor(background: resolvedBackgroundColor)
        case .borderless:
            return tintOverride ?? theme.colors.secondaryText
        }
    }

    private var resolvedSubtitleColor: Color {
        resolvedTitleColor.opacity(0.8)
    }

    private func filledTitleColor(background: Color) -> Color {
        Color(
            SFKButtonLabelColorResolver.resolve(
                background: background,
                explicitLabelColor: nil,
                colorScheme: colorScheme
            )
        )
    }

    private var resolvedBackgroundColor: Color {
        if let tintOverride { return tintOverride }
        switch role {
        case .primary: return theme.colors.accent
        case .destructive: return theme.colors.destructive
        case .secondary: return theme.colors.surface
        case .borderless: return theme.colors.surface
        }
    }

    private var resolvedColor: Color {
        return resolvedBackgroundColor
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

    /// Returns a copy with an explicit label color.
    ///
    /// For buttons with a rendered background, the default label color is the
    /// higher-contrast black or white value for that background in the current
    /// light/dark appearance. This override has precedence over that rule. On
    /// borderless buttons it also takes precedence over the existing tint/title
    /// behavior.
    func sfkLabelColor(_ color: Color?) -> Self {
        var copy = self
        copy.labelColorOverride = color
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
            switch SFKButtonRendering.role(for: role, supportsGlass: true) {
            case .glassProminent:
                content
                    .buttonStyle(.glassProminent)
                    .buttonBorderShape(.capsule)
                    .tint(resolvedColor)
                    .frame(maxWidth: shouldUseFullWidth ? .infinity : nil)
            case .glass:
                content
                    .buttonStyle(.glass)
                    .tint(resolvedColor)
            case .plain:
                content
                    .buttonStyle(.plain)
            case .borderedProminent, .bordered:
                // Unreachable on iOS 26, retained for exhaustive future-proofing.
                content
                    .buttonStyle(.bordered)
            }
        } else {
            switch SFKButtonRendering.role(for: role, supportsGlass: false) {
            case .borderedProminent:
                content
                    .buttonStyle(.borderedProminent)
                    .tint(resolvedColor)
                    .frame(maxWidth: shouldUseFullWidth ? .infinity : nil)
            case .bordered:
                content
                    .buttonStyle(.bordered)
                    .tint(resolvedColor)
            case .plain:
                content
                    .buttonStyle(.plain)
            case .glassProminent, .glass:
                // Unreachable before iOS 26, retained for exhaustive future-proofing.
                content
                    .buttonStyle(.bordered)
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
