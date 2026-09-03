/****************************************************************************
 * SFKButtonLabelColorResolver.swift
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

/// Internal color resolution used by ``SFKButton``.
///
/// UIKit resolves dynamic SwiftUI colors against a trait collection before the
/// contrast calculation. That is important for colors such as `Color.primary`,
/// whose RGB values intentionally invert between light and dark appearances.
@available(iOS 16, *)
internal enum SFKButtonLabelColorResolver {
    static func resolve(
        background: Color,
        explicitLabelColor: Color?,
        colorScheme: ColorScheme
    ) -> UIColor {
        if let explicitLabelColor {
            return resolve(explicitLabelColor, colorScheme: colorScheme)
        }

        return resolve(background, colorScheme: colorScheme).contrastingColor
    }

    static func resolve(_ color: Color, colorScheme: ColorScheme) -> UIColor {
        let interfaceStyle: UIUserInterfaceStyle = colorScheme == .dark ? .dark : .light
        let traits = UITraitCollection(userInterfaceStyle: interfaceStyle)
        return UIColor(color).resolvedColor(with: traits)
    }
}
