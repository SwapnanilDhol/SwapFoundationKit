/*****************************************************************************
 * UpdateAvailableBannerTheme.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2025 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import SwiftUI

/// Theme configuration for ``UpdateAvailableBannerView``.
///
/// Inject a custom instance to override colors, icons, and text.
///
///
/// ## Usage
/// ```swift
/// let theme = UpdateAvailableBannerTheme(
///     backgroundColor: .purple.opacity(0.15),
///     titleColor: .purple,
///     subtitleColor: .secondary,
///     iconName: "arrow.down.circle.fill"
/// )
/// ```
public struct UpdateAvailableBannerTheme: Sendable {
    public let backgroundColor: Color
    public let titleColor: Color
    public let subtitleColor: Color
    public let iconName: String
    public let buttonTitle: String
    public let buttonColor: Color
    public let buttonTitleColor: Color

    public init(
        backgroundColor: Color = Color.purple.opacity(0.12),
        titleColor: Color = .purple,
        subtitleColor: Color = .secondary,
        iconName: String = "arrow.down.app.fill",
        buttonTitle: String = "Update Now",
        buttonColor: Color = .purple,
        buttonTitleColor: Color = .white
    ) {
        self.backgroundColor = backgroundColor
        self.titleColor = titleColor
        self.subtitleColor = subtitleColor
        self.iconName = iconName
        self.buttonTitle = buttonTitle
        self.buttonColor = buttonColor
        self.buttonTitleColor = buttonTitleColor
    }

    public static let `default` = UpdateAvailableBannerTheme()
}
