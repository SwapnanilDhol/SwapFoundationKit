/*****************************************************************************
 * SFKButtonVisualTokens.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2025 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

/// Shared visual tokens used by `SFKButton` and the convenience button wrappers.
///
/// Host apps can override these values globally:
/// ```swift
/// SFKButtonVisualTokens.current.primaryCornerRadius = 18
/// SFKButtonVisualTokens.current.inlineCornerRadius = 12
/// ```
public struct SFKButtonVisualTokens: Sendable {
    
    public var buttonLabelHeight: CGFloat
    
    public var primaryCornerRadius: CGFloat
    public var secondaryCornerRadius: CGFloat
    public var inlineCornerRadius: CGFloat

    public var primaryForegroundColor: Color
    public var tintedForegroundColor: Color
    public var toolbarForegroundColor: Color

    public var enabledOpacity: CGFloat
    public var disabledOpacity: CGFloat
    public var disabledForegroundOpacity: CGFloat
    public var inlineFilledBackgroundOpacity: CGFloat
    public var pillFallbackBackgroundOpacity: CGFloat
    public var closeButtonTintOpacity: CGFloat
    public var closeButtonFallbackBackgroundOpacity: CGFloat

    public init(
        buttonLabelHeight: CGFloat = 56,
        primaryCornerRadius: CGFloat = 22,
        secondaryCornerRadius: CGFloat = 22,
        inlineCornerRadius: CGFloat = 10,
        primaryForegroundColor: Color = SFKButtonVisualTokens.defaultPrimaryForegroundColor,
        tintedForegroundColor: Color = .primary,
        toolbarForegroundColor: Color = .primary,
        enabledOpacity: CGFloat = 1.0,
        disabledOpacity: CGFloat = 0.72,
        disabledForegroundOpacity: CGFloat = 0.7,
        inlineFilledBackgroundOpacity: CGFloat = 0.14,
        pillFallbackBackgroundOpacity: CGFloat = 0.18,
        closeButtonTintOpacity: CGFloat = 0.22,
        closeButtonFallbackBackgroundOpacity: CGFloat = 0.12
    ) {
        self.buttonLabelHeight = 56
        self.primaryCornerRadius = primaryCornerRadius
        self.secondaryCornerRadius = secondaryCornerRadius
        self.inlineCornerRadius = inlineCornerRadius
        self.primaryForegroundColor = primaryForegroundColor
        self.tintedForegroundColor = tintedForegroundColor
        self.toolbarForegroundColor = toolbarForegroundColor
        self.enabledOpacity = enabledOpacity
        self.disabledOpacity = disabledOpacity
        self.disabledForegroundOpacity = disabledForegroundOpacity
        self.inlineFilledBackgroundOpacity = inlineFilledBackgroundOpacity
        self.pillFallbackBackgroundOpacity = pillFallbackBackgroundOpacity
        self.closeButtonTintOpacity = closeButtonTintOpacity
        self.closeButtonFallbackBackgroundOpacity = closeButtonFallbackBackgroundOpacity
    }

    /// Global tokens used by SFK buttons. Override from the host app to restyle buttons.
    public static var current = SFKButtonVisualTokens()

    public static var defaultPrimaryForegroundColor: Color {
#if canImport(UIKit)
        Color(uiColor: UIColor(red: 2, green: 2, blue: 2, alpha: 1))
#else
        .white
#endif
    }
}
