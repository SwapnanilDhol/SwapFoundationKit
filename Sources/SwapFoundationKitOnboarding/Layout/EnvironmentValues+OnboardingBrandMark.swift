/****************************************************************************
 * EnvironmentValues+OnboardingBrandMark.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2026 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import SwiftUI

private struct OnboardingBrandMarkKey: EnvironmentKey {
    static let defaultValue: AnyView? = nil
}

public extension EnvironmentValues {
    /// What a two-pane ``SFKOnboardingStep`` without a hero shows in its
    /// leading pane. Set it with ``SwiftUI/View/sfkOnboardingBrandMark(_:)``.
    var onboardingBrandMark: AnyView? {
        get { self[OnboardingBrandMarkKey.self] }
        set { self[OnboardingBrandMarkKey.self] = newValue }
    }
}
