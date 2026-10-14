/****************************************************************************
 * EnvironmentValues+OnboardingWideWindowMode.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2026 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import SwiftUI

private struct OnboardingWideWindowModeKey: EnvironmentKey {
    static let defaultValue: SFKOnboardingWideWindowMode = .twoPane
}

public extension EnvironmentValues {
    /// The wide-window mode of the enclosing ``SFKOnboardingWindow``. Steps
    /// and footers read it to cap and place themselves in `.centredColumn`.
    var onboardingWideWindowMode: SFKOnboardingWideWindowMode {
        get { self[OnboardingWideWindowModeKey.self] }
        set { self[OnboardingWideWindowModeKey.self] = newValue }
    }
}
