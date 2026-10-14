/****************************************************************************
 * SFKOnboardingWideWindowMode.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2026 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import CoreGraphics

/// How an onboarding flow uses a wide window (iPad, iPhone Duo's inner display).
///
/// Compact windows always get one phone-shaped column; this only decides what
/// happens when there is room for more.
///
/// ## Usage
/// ```swift
/// SFKOnboardingWindow(mode: .centredColumn()) { context in
///     MyOnboardingSteps()
/// }
/// ```
public enum SFKOnboardingWideWindowMode: Equatable, Sendable {
    /// Hero leading, copy and controls trailing, split on the window's centre
    /// line (the fold on iPhone Duo). The default.
    case twoPane
    /// One readable column capped at `maxWidth` and centred. While a fold
    /// divides the window the column moves into one half (trailing when
    /// book-folded, bottom when tabletop) so no control sits on the fold.
    case centredColumn(maxWidth: CGFloat = SFKOnboardingWideWindowMode.defaultColumnWidth)

    /// The readable column width used by `.centredColumn()`.
    public static let defaultColumnWidth: CGFloat = 560

    /// The column cap when the mode is `.centredColumn`, otherwise `nil`.
    public var centredColumnWidth: CGFloat? {
        guard case .centredColumn(let maxWidth) = self else { return nil }
        return maxWidth
    }
}
