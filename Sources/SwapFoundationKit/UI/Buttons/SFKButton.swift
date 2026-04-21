/*****************************************************************************
 * SFKButton.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2025 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import SwiftUI

/// A configurable SwiftUI button for SwapFoundationKit.
///
/// `SFKButton` supports two usage styles:
/// - pass line-item values directly through the main initializer
/// - build and reuse a `SFKButtonConfigurator`
///
/// Height is determined by the configured padding values. When loading, the button disables taps,
/// swaps its label for a spinner, and collapses out of full-width layout.
///
/// Example:
/// ```swift
/// SFKButton(
///     "Continue",
///     leadingIconName: "arrow.right",
///     subtitle: "Recommended",
///     color: .blue
/// ) {
///     continueFlow()
/// }
///
/// var close = SFKButtonConfigurator.close
/// close.title = "Close"
///
/// SFKButton(configuration: close) {
///     dismiss()
/// }
/// ```
public struct SFKButton: View {
    private let hapticsHelper = HapticsHelper()
    private let configuration: SFKButtonConfigurator
    private let action: () -> Void

    /// Creates a button by specifying each configuration value directly.
    public init(
        _ title: String? = nil,
        leadingIconName: String? = nil,
        subtitle: String? = nil,
        isLoading: Bool = false,
        fullWidth: Bool = true,
        titleColor: Color = .white,
        subtitleColor: Color = Color.white.opacity(0.8),
        color: Color = .blue,
        spacing: CGFloat = 8,
        horizontalPadding: CGFloat = 16,
        verticalPadding: CGFloat = 12,
        titleFont: Font = .headline.weight(.semibold),
        subtitleFont: Font = .subheadline,
        iconFont: Font = .headline.weight(.semibold),
        textAlignment: HorizontalAlignment = .center,
        titleLineLimit: Int = 1,
        subtitleLineLimit: Int = 1,
        chrome: SFKButtonChrome = .glassProminent,
        hapticStyle: SFKButtonHapticStyle? = .medium,
        action: @escaping () -> Void
    ) {
        self.configuration = SFKButtonConfigurator(
            leadingIconName: leadingIconName,
            title: title,
            subtitle: subtitle,
            isLoading: isLoading,
            fullWidth: fullWidth,
            titleColor: titleColor,
            subtitleColor: subtitleColor,
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
            chrome: chrome,
            hapticStyle: hapticStyle
        )
        self.action = action
    }

    /// Creates a button from an existing `SFKButtonConfigurator`.
    public init(
        configuration: SFKButtonConfigurator,
        action: @escaping () -> Void
    ) {
        self.configuration = configuration
        self.action = action
    }

    public var body: some View {
        let button = Button {
            guard !configuration.isLoading else { return }
            triggerHapticIfNeeded()
            action()
        } label: {
            buttonLabel
            .padding(.horizontal, configuration.horizontalPadding)
            .padding(.vertical, configuration.verticalPadding)
            .frame(maxWidth: shouldUseFullWidth ? .infinity : nil)
            .foregroundStyle(configuration.titleColor)
            .contentShape(Rectangle())
        }
        .disabled(configuration.isLoading)
        .animation(.spring(response: 0.28, dampingFraction: 0.82), value: configuration.isLoading)

        styledButton(button)
    }

    @ViewBuilder
    private var buttonLabel: some View {
        if configuration.isLoading {
            ProgressView()
                .progressViewStyle(.circular)
                .tint(configuration.titleColor)
        } else {
            HStack(spacing: configuration.spacing) {
                if let leadingIconName = configuration.leadingIconName {
                    Image(systemName: leadingIconName)
                        .font(configuration.iconFont)
                }

                if hasTextContent {
                    VStack(alignment: configuration.textAlignment, spacing: 2) {
                        if let title = configuration.title, !title.isEmpty {
                            Text(title)
                                .font(configuration.titleFont)
                                .lineLimit(configuration.titleLineLimit)
                        }

                        if let subtitle = configuration.subtitle, !subtitle.isEmpty {
                            Text(subtitle)
                                .font(configuration.subtitleFont)
                                .foregroundStyle(configuration.subtitleColor)
                                .lineLimit(configuration.subtitleLineLimit)
                        }
                    }
                }
            }
        }
    }

    private var hasTextContent: Bool {
        let hasTitle = configuration.title?.isEmpty == false
        let hasSubtitle = configuration.subtitle?.isEmpty == false
        return hasTitle || hasSubtitle
    }

    private var shouldUseFullWidth: Bool {
        configuration.fullWidth && !configuration.isLoading
    }

    private func triggerHapticIfNeeded() {
        switch configuration.hapticStyle {
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
}

private extension SFKButton {
    @ViewBuilder
    func styledButton<Content: View>(_ content: Content) -> some View {
        switch configuration.chrome {
        case .glassProminent:
            content.glassProminentCompat(color: configuration.color)

        case .glass:
            content.glassCompat(color: configuration.color)

        case let .glassEffect(style, shape, isInteractive):
            switch shape {
            case let .roundedRectangle(cornerRadius):
                content.glassEffectCompat(
                    style: style,
                    color: configuration.color,
                    isInteractive: isInteractive,
                    in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                )
            case .capsule:
                content.glassEffectCompat(
                    style: style,
                    color: configuration.color,
                    isInteractive: isInteractive,
                    in: Capsule()
                )
            case .circle:
                content.glassEffectCompat(
                    style: style,
                    color: configuration.color,
                    isInteractive: isInteractive,
                    in: Circle()
                )
            }

        case .plain:
            content
        }
    }
}

#Preview("SFKButton Gallery") {
    var closeConfig = SFKButtonConfigurator.close
    closeConfig.title = "Close"

    var closeIconOnlyConfig = SFKButtonConfigurator.close

    var successConfig = SFKButtonConfigurator.primary
    successConfig.leadingIconName = "checkmark.circle.fill"
    successConfig.title = "Save Changes"
    successConfig.subtitle = "Everything is ready to sync"
    successConfig.color = .green

    var warningConfig = SFKButtonConfigurator.primary
    warningConfig.leadingIconName = "exclamationmark.triangle.fill"
    warningConfig.title = "Review Permissions"
    warningConfig.subtitle = "Camera access is required"
    warningConfig.color = .orange

    var loadingConfig = SFKButtonConfigurator.primary
    loadingConfig.title = "Saving"
    loadingConfig.leadingIconName = "arrow.triangle.2.circlepath"
    loadingConfig.isLoading = true
    loadingConfig.hapticStyle = nil

    var toolbarLikeConfig = SFKButtonConfigurator(
        leadingIconName: "slider.horizontal.3",
        title: "Filters",
        isLoading: false,
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
        chrome: .glass,
        hapticStyle: .light
    )

    var compactPlainConfig = SFKButtonConfigurator(
        leadingIconName: "doc.text.magnifyingglass",
        title: "Details",
        isLoading: false,
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
        chrome: .plain,
        hapticStyle: .light
    )

    var circularIconConfig = SFKButtonConfigurator(
        leadingIconName: "plus",
        title: nil,
        subtitle: nil,
        isLoading: false,
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
        chrome: .glassEffect(style: .regular, shape: .circle, isInteractive: true),
        hapticStyle: .medium
    )

    return ScrollView {
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

                SFKButton(configuration: successConfig) {
                }

                SFKButton(configuration: warningConfig) {
                }

                SFKButton(configuration: loadingConfig) {
                }
            }

            VStack(alignment: .leading, spacing: 12) {
                Text("Compact")
                    .font(.headline)
                    .foregroundStyle(.secondary)

                HStack(spacing: 12) {
                    SFKButton(configuration: toolbarLikeConfig) {
                    }

                    SFKButton(configuration: compactPlainConfig) {
                    }

                    SFKButton(configuration: circularIconConfig) {
                    }
                }
            }

            VStack(alignment: .leading, spacing: 12) {
                Text("Close")
                    .font(.headline)
                    .foregroundStyle(.secondary)

                HStack(spacing: 12) {
                    SFKButton(configuration: closeConfig) {
                    }

                    SFKButton(configuration: closeIconOnlyConfig) {
                    }
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
