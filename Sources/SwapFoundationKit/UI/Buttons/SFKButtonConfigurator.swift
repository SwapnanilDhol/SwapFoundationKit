/*****************************************************************************
 * SFKButtonConfigurator.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2025 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import SwiftUI

/// The haptic feedback style triggered when an `SFKButton` is tapped.
public enum SFKButtonHapticStyle {
    case light
    case medium
    case heavy
}

/// The shape used by `SFKButtonChrome.glassEffect`.
public enum SFKButtonShape {
    case roundedRectangle(cornerRadius: CGFloat)
    case capsule
    case circle
}

/// The visual chrome applied to an `SFKButton`.
public enum SFKButtonChrome {
    /// Applies the prominent Liquid Glass button style with a compatibility fallback.
    case glassProminent
    /// Applies the regular Liquid Glass button style with a compatibility fallback.
    case glass
    /// Applies Liquid Glass directly to a custom shape with a compatibility fallback.
    case glassEffect(
        style: GlassEffectCompatStyle = .regular,
        shape: SFKButtonShape = .capsule,
        isInteractive: Bool = true
    )
    /// Applies no extra chrome.
    case plain
}

/// A reusable configuration object that defines the content, layout, styling, and interaction
/// behavior for an `SFKButton`.
///
/// Use `SFKButtonConfigurator` when you want to:
/// - reuse the same button style across multiple screens
/// - start from a preset such as `.primary` or `.close`
/// - mutate a button setup before passing it into `SFKButton(configuration:action:)`
/// - control padding-driven sizing and loading behavior without introducing another button type
///
/// Example:
/// ```swift
/// var config = SFKButtonConfigurator.close
/// config.title = "Close"
///
/// SFKButton(configuration: config) {
///     dismiss()
/// }
/// ```
public struct SFKButtonConfigurator {
    public var leadingIconName: String?
    public var title: String?
    public var subtitle: String?
    public var isLoading: Bool
    public var fullWidth: Bool
    public var titleColor: Color
    public var subtitleColor: Color
    public var color: Color
    public var spacing: CGFloat
    public var horizontalPadding: CGFloat
    public var verticalPadding: CGFloat
    public var titleFont: Font
    public var subtitleFont: Font
    public var iconFont: Font
    public var textAlignment: HorizontalAlignment
    public var titleLineLimit: Int
    public var subtitleLineLimit: Int
    public var chrome: SFKButtonChrome
    public var hapticStyle: SFKButtonHapticStyle?

    /// Creates a new button configuration with explicit values for every line item.
    ///
    /// Button height is derived from `verticalPadding`. When `isLoading` is `true`, the button
    /// disables interaction and shows a spinner in place of its normal content.
    public init(
        leadingIconName: String? = nil,
        title: String? = nil,
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
        hapticStyle: SFKButtonHapticStyle? = .medium
    ) {
        self.leadingIconName = leadingIconName
        self.title = title
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
        self.chrome = chrome
        self.hapticStyle = hapticStyle
    }

    /// A sensible default configuration for a prominent primary action.
    public static var primary: Self {
        Self()
    }

    /// A preset for close and dismiss controls.
    ///
    /// You can copy and mutate it before use:
    /// ```swift
    /// var close = SFKButtonConfigurator.close
    /// close.title = "Close"
    /// ```
    public static var close: Self {
        Self(
            leadingIconName: "xmark",
            title: nil,
            subtitle: nil,
            isLoading: false,
            fullWidth: false,
            titleColor: .primary,
            subtitleColor: .secondary,
            color: .white.opacity(0.12),
            spacing: 8,
            horizontalPadding: 12,
            verticalPadding: 9,
            titleFont: .footnote.weight(.semibold),
            subtitleFont: .caption2,
            iconFont: .footnote.weight(.bold),
            textAlignment: .center,
            titleLineLimit: 1,
            subtitleLineLimit: 1,
            chrome: .glassEffect(style: .regular, shape: .capsule, isInteractive: true),
            hapticStyle: .medium
        )
    }
}
