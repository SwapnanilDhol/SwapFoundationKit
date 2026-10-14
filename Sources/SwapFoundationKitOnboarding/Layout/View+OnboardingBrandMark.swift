/****************************************************************************
 * View+OnboardingBrandMark.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2026 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import SwiftUI

public extension View {
    /// Supplies the brand mark that fills the leading pane of two-pane
    /// onboarding steps that have no hero of their own, so the layout does not
    /// jump between an empty pane and a full one as the user moves through
    /// the flow.
    ///
    /// ## Usage
    /// ```swift
    /// MyOnboardingFlow()
    ///     .sfkOnboardingBrandMark {
    ///         SFKOnboardingBrandMark(shadowTint: .pink) { AppIconView(size: 132) }
    ///     }
    /// ```
    func sfkOnboardingBrandMark<Mark: View>(@ViewBuilder _ mark: () -> Mark) -> some View {
        environment(\.onboardingBrandMark, AnyView(mark()))
    }
}
