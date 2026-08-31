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

enum SFKButtonRenderingStyle {
    case primary
    case secondary
    case toolbar
    case customGlass(material: SFKButtonLegacyGlassMaterial, shape: SFKGlassShape, isInteractive: Bool)
}

enum SFKButtonLegacyGlassMaterial {
    case regular
    case clear
    case identity
}

@available(iOS 16, *)
public struct SFKButton: View {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.sfkTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    private let hapticsHelper = HapticsHelper()

    private var title: String?
    private var leadingIconName: String?
    private var subtitle: String?
    private var isLoading: Bool
    private var fullWidth: Bool
    private let titleColor: Color
    private let subtitleColor: Color
    private var color: Color
    private var tintOverride: Color?
    private let spacing: CGFloat
    private let horizontalPadding: CGFloat
    private let verticalPadding: CGFloat
    private let titleFont: Font
    private let subtitleFont: Font
    private let iconFont: Font
    private let textAlignment: HorizontalAlignment
    private let titleLineLimit: Int?
    private let subtitleLineLimit: Int?
    private let controlSize: ControlSize
    private let renderingStyle: SFKButtonRenderingStyle
    private let hapticStyle: SFKButtonHapticStyle?
    private let semanticRole: SFKButtonStyle?
    private let action: () -> Void

    /// Creates a semantic button whose appearance follows the nearest
    /// ``SFKTheme``. Explicit legacy initializer arguments remain available
    /// when a one-off appearance is required.
    public init(
        _ title: String,
        role: SFKButtonStyle = .primary,
        action: @escaping () -> Void
    ) {
        self.init(
            title,
            leadingIconName: nil,
            subtitle: nil,
            isLoading: false,
            fullWidth: true,
            titleColor: .white,
            subtitleColor: .white.opacity(0.8),
            color: .accentColor,
            spacing: 8,
            horizontalPadding: 16,
            verticalPadding: 9,
            titleFont: .body.weight(.semibold),
            subtitleFont: .caption,
            iconFont: .body.weight(.semibold),
            textAlignment: .center,
            titleLineLimit: nil,
            subtitleLineLimit: nil,
            controlSize: .regular,
            renderingStyle: role.renderingStyle,
            hapticStyle: .medium,
            tintOverride: nil,
            semanticRole: role,
            action: action
        )
    }

    @_disfavoredOverload
    @available(*, deprecated, message: "Use SFKButton(_:role:action:) for theme-aware controls.")
    public init(
        _ title: String? = nil,
        leadingIconName: String? = nil,
        subtitle: String? = nil,
        isLoading: Bool = false,
        fullWidth: Bool = true,
        titleColor: Color? = nil,
        subtitleColor: Color? = nil,
        color: Color = .blue,
        spacing: CGFloat = 8,
        horizontalPadding: CGFloat = 16,
        verticalPadding: CGFloat = 9,
        titleFont: Font = .body.weight(.semibold),
        subtitleFont: Font = .subheadline,
        iconFont: Font = .body.weight(.semibold),
        textAlignment: HorizontalAlignment = .center,
        titleLineLimit: Int = 1,
        subtitleLineLimit: Int = 1,
        controlSize: ControlSize = .regular,
        style: SFKButtonStyle = .primary,
        hapticStyle: SFKButtonHapticStyle? = .medium,
        action: @escaping () -> Void
    ) {
        self.init(
            title,
            leadingIconName: leadingIconName,
            subtitle: subtitle,
            isLoading: isLoading,
            fullWidth: fullWidth,
            titleColor: titleColor ?? style.defaultTitleColor,
            subtitleColor: subtitleColor ?? style.defaultSubtitleColor,
            color: color,
            spacing: spacing,
            horizontalPadding: horizontalPadding,
            verticalPadding: verticalPadding,
            titleFont: titleFont,
            subtitleFont: subtitleFont,
            iconFont: iconFont,
            textAlignment: textAlignment,
            titleLineLimit: titleLineLimit,
            subtitleLineLimit: subtitleLineLimit,
            controlSize: controlSize,
            renderingStyle: style.renderingStyle,
            hapticStyle: hapticStyle,
            tintOverride: nil,
            semanticRole: nil,
            action: action
        )
    }

    init(
        _ title: String?,
        leadingIconName: String?,
        subtitle: String?,
        isLoading: Bool,
        fullWidth: Bool,
        titleColor: Color,
        subtitleColor: Color,
        color: Color,
        spacing: CGFloat,
        horizontalPadding: CGFloat,
        verticalPadding: CGFloat,
        titleFont: Font,
        subtitleFont: Font,
        iconFont: Font,
        textAlignment: HorizontalAlignment,
        titleLineLimit: Int?,
        subtitleLineLimit: Int?,
        controlSize: ControlSize,
        renderingStyle: SFKButtonRenderingStyle,
        hapticStyle: SFKButtonHapticStyle?,
        tintOverride: Color? = nil,
        semanticRole: SFKButtonStyle? = nil,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.leadingIconName = leadingIconName
        self.subtitle = subtitle
        self.isLoading = isLoading
        self.fullWidth = fullWidth
        self.titleColor = titleColor
        self.subtitleColor = subtitleColor
        self.color = color
        self.tintOverride = tintOverride
        self.spacing = spacing
        self.horizontalPadding = horizontalPadding
        self.verticalPadding = verticalPadding
        self.titleFont = titleFont
        self.subtitleFont = subtitleFont
        self.iconFont = iconFont
        self.textAlignment = textAlignment
        self.titleLineLimit = titleLineLimit
        self.subtitleLineLimit = subtitleLineLimit
        self.controlSize = controlSize
        self.renderingStyle = renderingStyle
        self.hapticStyle = hapticStyle
        self.semanticRole = semanticRole
        self.action = action
    }

    public var body: some View {
        let button = Button {
            guard !isLoading else { return }
            triggerHapticIfNeeded()
            action()
        } label: {
            buttonLabel
                .padding(.horizontal, isToolbarButton ? 0 : resolvedHorizontalPadding)
                .padding(.vertical, isToolbarButton ? 0 : resolvedVerticalPadding)
                .frame(
                    maxWidth: shouldUseFullWidth ? .infinity : nil,
                    alignment: Alignment(horizontal: textAlignment, vertical: .center)
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
                if let leadingIconName, !leadingIconName.isEmpty {
                    Image(systemName: leadingIconName)
                        .font(resolvedIconFont)
                }

                if hasTextContent {
                    VStack(alignment: textAlignment, spacing: 2) {
                        if let title, !title.isEmpty {
                            Text(title)
                                .font(resolvedTitleFont)
                                .lineLimit(titleLineLimit)
                        }

                        if let subtitle, !subtitle.isEmpty {
                            Text(subtitle)
                                .font(resolvedSubtitleFont)
                                .foregroundStyle(resolvedSubtitleColor)
                                .lineLimit(subtitleLineLimit)
                        }
                    }
                }
            }
        }
    }

    private var hasTextContent: Bool {
        let hasTitle = title?.isEmpty == false
        let hasSubtitle = subtitle?.isEmpty == false
        return hasTitle || hasSubtitle
    }

    private var accessibilityTitle: String {
        guard let title, !title.isEmpty else { return "Button" }
        return title
    }

    private var shouldUseFullWidth: Bool {
        fullWidth && !isLoading && !isToolbarButton
    }

    private var isToolbarButton: Bool {
        switch renderingStyle {
        case .toolbar:
            true
        case .primary, .secondary, .customGlass:
            false
        }
    }

    private func triggerHapticIfNeeded() {
        guard isEnabled, !isLoading, theme.feedback.enabled else { return }

        switch hapticStyle {
        case .light:
            hapticsHelper.lightImpact()
        case .medium:
            hapticsHelper.mediumImpact()
        case .heavy:
            hapticsHelper.heavyImpact()
        case nil:
            break
        }
    }

    private var resolvedTitleColor: Color {
        guard isEnabled && !isLoading else { return Self.disabledTitleColor }
        guard let semanticRole else { return titleColor }
        switch semanticRole {
        case .primary: return theme.colors.onAccent
        case .destructive: return theme.colors.onDestructive
        case .secondary, .toolbar: return theme.colors.text
        }
    }

    private var resolvedSubtitleColor: Color {
        guard isEnabled && !isLoading else { return Self.disabledSubtitleColor }
        guard let semanticRole else { return subtitleColor }
        switch semanticRole {
        case .primary: return theme.colors.onAccent.opacity(0.8)
        case .destructive: return theme.colors.onDestructive.opacity(0.8)
        case .secondary, .toolbar: return theme.colors.secondaryText
        }
    }

    private var resolvedColor: Color {
        guard isEnabled && !isLoading else { return Self.disabledColor }
        guard let semanticRole else { return color }
        if let tintOverride { return tintOverride }
        switch semanticRole {
        case .primary: return theme.colors.accent
        case .destructive: return theme.colors.destructive
        case .secondary, .toolbar: return theme.colors.surface
        }
    }

    private var resolvedSpacing: CGFloat {
        semanticRole == nil ? spacing : theme.spacing.inline
    }

    private var resolvedHorizontalPadding: CGFloat {
        semanticRole == nil ? horizontalPadding : theme.spacing.control
    }

    private var resolvedVerticalPadding: CGFloat {
        semanticRole == nil ? verticalPadding : theme.spacing.inline
    }

    private var resolvedTitleFont: Font {
        semanticRole == nil ? titleFont : theme.typography.body.weight(.semibold)
    }

    private var resolvedSubtitleFont: Font {
        semanticRole == nil ? subtitleFont : theme.typography.caption
    }

    private var resolvedIconFont: Font {
        semanticRole == nil ? iconFont : theme.typography.body.weight(.semibold)
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
        copy.color = color ?? copy.color
        copy.tintOverride = color
        return copy
    }
}

@available(iOS 16, *)
private extension SFKButton {
    @ViewBuilder
    func styledButton<Content: View>(_ content: Content) -> some View {
        if #available(iOS 26, *) {
            switch renderingStyle {
            case .primary:
                content
                    .buttonStyle(.glassProminent)
                    .tint(resolvedColor)
            case .secondary:
                content
                    .buttonStyle(.glass)
                    .tint(resolvedColor)
            case .toolbar:
                content
            case let .customGlass(material, shape, isInteractive):
                customGlass(
                    content,
                    material: material,
                    shape: shape,
                    isInteractive: isInteractive
                )
            }
        } else {
            switch renderingStyle {
            case .primary:
                content
                    .buttonStyle(.borderedProminent)
                    .tint(resolvedColor)
            case .secondary:
                content
                    .buttonStyle(.bordered)
                    .tint(resolvedColor)
            case .toolbar:
                content
            case let .customGlass(material, shape, isInteractive):
                customGlass(
                    content,
                    material: material,
                    shape: shape,
                    isInteractive: isInteractive
                )
            }
        }
    }

    @ViewBuilder
    private func customGlass<Content: View>(
        _ content: Content,
        material: SFKButtonLegacyGlassMaterial,
        shape: SFKGlassShape,
        isInteractive: Bool
    ) -> some View {
        switch material {
        case .regular:
            content.sfkGlass(
                material: .regular,
                tint: resolvedColor,
                isInteractive: isInteractive && isEnabled,
                shape: shape
            )
        case .clear:
            content.sfkGlass(
                material: .clear,
                tint: resolvedColor,
                isInteractive: isInteractive && isEnabled,
                shape: shape
            )
        case .identity:
            content
        }
    }
}

private extension SFKButtonStyle {
    var renderingStyle: SFKButtonRenderingStyle {
        switch self {
        case .primary: .primary
        case .destructive: .primary
        case .secondary: .secondary
        case .toolbar: .toolbar
        }
    }
}

// MARK: - Previews

@available(iOS 26, *)
#Preview("SFKButton Gallery") {
    ScrollView {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Prominent")
                    .font(.headline)
                    .foregroundStyle(.secondary)

                SFKButton("Continue") {
                }

                SFKButton(
                    "Back Up Now",
                    leadingIconName: "icloud.and.arrow.up",
                    subtitle: "Recommended before updating"
                ) {
                }

                SFKButton(
                    "Save Changes",
                    leadingIconName: "checkmark.circle.fill",
                    subtitle: "Everything is ready to sync",
                    color: .green
                ) {
                }

                SFKButton(
                    "Review Permissions",
                    leadingIconName: "exclamationmark.triangle.fill",
                    subtitle: "Camera access is required",
                    color: .orange
                ) {
                }

                SFKButton(
                    "Saving",
                    leadingIconName: "arrow.triangle.2.circlepath",
                    isLoading: true,
                    hapticStyle: nil
                ) {
                }
            }

            VStack(alignment: .leading, spacing: 12) {
                Text("Compact")
                    .font(.headline)
                    .foregroundStyle(.secondary)

                HStack(spacing: 12) {
                    SFKButton(
                        "Filters",
                        leadingIconName: "slider.horizontal.3",
                        fullWidth: false,
                        titleColor: .primary,
                        subtitleColor: .secondary,
                        color: .white.opacity(0.14),
                        spacing: 6,
                        horizontalPadding: 12,
                        verticalPadding: 8,
                        titleFont: .footnote.weight(.semibold),
                        subtitleFont: .caption,
                        iconFont: .footnote.weight(.semibold),
                        style: .secondary,
                        hapticStyle: .light
                    ) {
                    }

                    SFKButton(
                        "Details",
                        leadingIconName: "doc.text.magnifyingglass",
                        fullWidth: false,
                        titleColor: .primary,
                        subtitleColor: .secondary,
                        color: .clear,
                        spacing: 6,
                        horizontalPadding: 10,
                        verticalPadding: 6,
                        titleFont: .footnote.weight(.semibold),
                        subtitleFont: .caption2,
                        iconFont: .footnote.weight(.semibold),
                        style: .toolbar,
                        hapticStyle: .light
                    ) {
                    }

                    SFKButton(
                        leadingIconName: "plus",
                        fullWidth: false,
                        titleColor: .white,
                        subtitleColor: .white,
                        color: .purple,
                        spacing: 0,
                        horizontalPadding: 14,
                        verticalPadding: 14,
                        titleFont: .headline,
                        subtitleFont: .caption,
                        iconFont: .headline.weight(.bold),
                        style: .secondary
                    ) {
                    }
                }
            }

            VStack(alignment: .leading, spacing: 12) {
                Text("Close & Disabled")
                    .font(.headline)
                    .foregroundStyle(.secondary)

                HStack(spacing: 12) {
                    SFKButton(
                        "Close",
                        leadingIconName: "xmark",
                        fullWidth: false,
                        titleColor: .primary,
                        subtitleColor: .secondary,
                        color: .white.opacity(0.12),
                        spacing: 8,
                        horizontalPadding: 12,
                        verticalPadding: 5,
                        titleFont: .footnote.weight(.semibold),
                        subtitleFont: .caption2,
                        iconFont: .footnote.weight(.bold)
                    ) {
                    }

                    SFKButton(
                        leadingIconName: "xmark",
                        fullWidth: false,
                        titleColor: .primary,
                        subtitleColor: .secondary,
                        color: .white.opacity(0.12),
                        spacing: 8,
                        horizontalPadding: 12,
                        verticalPadding: 5,
                        titleFont: .footnote.weight(.semibold),
                        subtitleFont: .caption2,
                        iconFont: .footnote.weight(.bold)
                    ) {
                    }

                    SFKButton(
                        "Disabled Action",
                        leadingIconName: "lock.fill",
                        subtitle: "Waiting for required input",
                        color: .red
                    ) {
                    }
                    .disabled(true)
                }
            }

            VStack(alignment: .leading, spacing: 12) {
                Text("Alignment")
                    .font(.headline)
                    .foregroundStyle(.secondary)

                SFKButton(
                    "Leading aligned title",
                    leadingIconName: "text.alignleft",
                    subtitle: "Designed for longer supporting copy",
                    color: .green,
                    textAlignment: .leading,
                    titleLineLimit: 2,
                    subtitleLineLimit: 2
                ) {
                }

                SFKButton(
                    "Trailing aligned title",
                    leadingIconName: "text.alignright",
                    subtitle: "Useful for utility-style treatments",
                    color: .indigo,
                    textAlignment: .trailing,
                    titleLineLimit: 2,
                    subtitleLineLimit: 2
                ) {
                }
            }
        }
        .padding(24)
    }
    .background(
        LinearGradient(
            colors: [
                Color.black.opacity(0.04),
                Color.blue.opacity(0.08)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    )
}
