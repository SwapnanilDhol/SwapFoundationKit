/****************************************************************************
 * EnvironmentValues+OnboardingPaneColumn.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2026 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import SwiftUI

private struct OnboardingPaneColumnKey: EnvironmentKey {
    static let defaultValue = false
}

public extension EnvironmentValues {
    /// `true` inside the trailing pane of a two-pane window when a step lays
    /// itself out as a single column there (a form beside a live preview
    /// pane), so the column and its footer use the pane's inset and width cap
    /// and line up with steps that split themselves.
    var isOnboardingPaneColumn: Bool {
        get { self[OnboardingPaneColumnKey.self] }
        set { self[OnboardingPaneColumnKey.self] = newValue }
    }
}
