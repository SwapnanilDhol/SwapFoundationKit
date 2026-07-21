/****************************************************************************
 * SFKButton+Legacy.swift
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
public extension SFKButton {
    /// Source-compatible adapter for the pre-semantic button chrome API.
    @available(*, deprecated, message: "Use init(..., style: .primary/.secondary/.toolbar, ...) instead.")
    init(
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
        chrome: SFKButtonChrome,
        hapticStyle: SFKButtonHapticStyle? = .medium,
        action: @escaping () -> Void
    ) {
        self.init(
            title,
            leadingIconName: leadingIconName,
            subtitle: subtitle,
            isLoading: isLoading,
            fullWidth: fullWidth,
            titleColor: titleColor ?? chrome.defaultTitleColor,
            subtitleColor: subtitleColor ?? chrome.defaultSubtitleColor,
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
            renderingStyle: chrome.renderingStyle,
            hapticStyle: hapticStyle,
            action: action
        )
    }
}

private extension SFKButtonChrome {
    var renderingStyle: SFKButtonRenderingStyle {
        switch self {
        case .glassProminent:
            .primary
        case .glass:
            .secondary
        case let .glassEffect(style, shape, isInteractive):
            .customGlass(
                material: style.legacyButtonMaterial,
                shape: shape,
                isInteractive: isInteractive
            )
        case .plain:
            .toolbar
        }
    }
}

private extension SFKGlassStyle {
    var legacyButtonMaterial: SFKButtonLegacyGlassMaterial {
        switch self {
        case .regular: .regular
        case .clear: .clear
        case .identity: .identity
        }
    }
}
