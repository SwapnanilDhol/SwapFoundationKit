/****************************************************************************
 * SFKOnboardingBrandMark.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2026 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import SwapFoundationKit
import SwiftUI

/// The app's mark with a soft shadow and an accent glow behind it. Hand it to
/// ``SwiftUI/View/sfkOnboardingBrandMark(_:)`` to fill the leading pane of
/// two-pane steps that have no hero of their own.
///
/// ## Usage
/// ```swift
/// // Any view as the mark:
/// SFKOnboardingBrandMark(shadowTint: .pink) { AppIconView(size: 132) }
///
/// // Or an image, drawn as a rounded app icon:
/// SFKOnboardingBrandMark(image: Image("BrandIcon"))
/// ```
public struct SFKOnboardingBrandMark<Mark: View>: View {
    @Environment(\.sfkTheme) private var theme

    private let shadowTint: Color?
    private let mark: Mark

    /// - Parameters:
    ///   - shadowTint: Colour of the drop shadow. Defaults to the theme accent.
    ///   - mark: The brand's mark, already sized.
    public init(shadowTint: Color? = nil, @ViewBuilder mark: () -> Mark) {
        self.shadowTint = shadowTint
        self.mark = mark()
    }

    public var body: some View {
        mark
            .shadow(color: (shadowTint ?? theme.colors.accent).opacity(0.28), radius: 28, y: 12)
            .background {
                RadialGradient(
                    colors: [theme.colors.accent.opacity(0.14), .clear],
                    center: .center,
                    startRadius: 20,
                    endRadius: 240
                )
                .frame(width: 480, height: 480)
                .allowsHitTesting(false)
            }
            .accessibilityHidden(true)
    }
}

public extension SFKOnboardingBrandMark where Mark == SFKOnboardingBrandMarkIcon {
    /// Draws `image` as a rounded app icon.
    /// - Parameters:
    ///   - image: The brand image, usually the app icon.
    ///   - size: The icon's side length. Defaults to 132 pt.
    ///   - shadowTint: Colour of the drop shadow. Defaults to the theme accent.
    init(image: Image, size: CGFloat = 132, shadowTint: Color? = nil) {
        self.init(shadowTint: shadowTint) {
            SFKOnboardingBrandMarkIcon(image: image, size: size)
        }
    }
}

#Preview {
    VStack(spacing: 80) {
        SFKOnboardingBrandMark(image: Image(systemName: "leaf.fill"))
        SFKOnboardingBrandMark(shadowTint: .pink) {
            Circle().fill(.pink.gradient).frame(width: 100, height: 100)
        }
    }
    .sfkTheme(.system.accent(.green))
}
