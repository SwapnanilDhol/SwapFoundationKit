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
    private let hapticsHelper = HapticsHelper()

    private let title: String?
    private let leadingIconName: String?
    private let subtitle: String?
    private let isLoading: Bool
    private let fullWidth: Bool
    private let titleColor: Color
    private let subtitleColor: Color
    private let color: Color
    private let spacing: CGFloat
    private let horizontalPadding: CGFloat
    private let verticalPadding: CGFloat
    private let titleFont: Font
    private let subtitleFont: Font
    private let iconFont: Font
    private let textAlignment: HorizontalAlignment
    private let titleLineLimit: Int
    private let subtitleLineLimit: Int
    private let renderingStyle: SFKButtonRenderingStyle
    private let hapticStyle: SFKButtonHapticStyle?
    private let action: () -> Void

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
            renderingStyle: style.renderingStyle,
            hapticStyle: hapticStyle,
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
        titleLineLimit: Int,
        subtitleLineLimit: Int,
        renderingStyle: SFKButtonRenderingStyle,
        hapticStyle: SFKButtonHapticStyle?,
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
        self.spacing = spacing
        self.horizontalPadding = horizontalPadding
        self.verticalPadding = verticalPadding
        self.titleFont = titleFont
        self.subtitleFont = subtitleFont
        self.iconFont = iconFont
        self.textAlignment = textAlignment
        self.titleLineLimit = titleLineLimit
        self.subtitleLineLimit = subtitleLineLimit
        self.renderingStyle = renderingStyle
        self.hapticStyle = hapticStyle
        self.action = action
    }

    public var body: some View {
        let button = Button {
            guard !isLoading else { return }
            triggerHapticIfNeeded()
            action()
        } label: {
            buttonLabel
                .padding(.horizontal, isToolbarButton ? 0 : horizontalPadding)
                .padding(.vertical, isToolbarButton ? 0 : verticalPadding)
                .frame(maxWidth: shouldUseFullWidth ? .infinity : nil)
                .foregroundStyle(resolvedTitleColor)
                .contentShape(Rectangle())
        }
        .disabled(isLoading)
        .animation(.spring(response: 0.28, dampingFraction: 0.82), value: isLoading)

        styledButton(button)
    }

    @ViewBuilder
    private var buttonLabel: some View {
        if isLoading {
            ProgressView()
                .progressViewStyle(.circular)
                .tint(resolvedTitleColor)
        } else {
            HStack(spacing: spacing) {
                if let leadingIconName, !leadingIconName.isEmpty {
                    Image(systemName: leadingIconName)
                        .font(iconFont)
                }

                if hasTextContent {
                    VStack(alignment: textAlignment, spacing: 2) {
                        if let title, !title.isEmpty {
                            Text(title)
                                .font(titleFont)
                                .lineLimit(titleLineLimit)
                        }

                        if let subtitle, !subtitle.isEmpty {
                            Text(subtitle)
                                .font(subtitleFont)
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
        guard isEnabled, !isLoading else { return }

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
        isEnabled && !isLoading ? titleColor : Self.disabledTitleColor
    }

    private var resolvedSubtitleColor: Color {
        isEnabled && !isLoading ? subtitleColor : Self.disabledSubtitleColor
    }

    private var resolvedColor: Color {
        isEnabled && !isLoading ? color : Self.disabledColor
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
