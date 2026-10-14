/****************************************************************************
 * EnvironmentValues+TwoPaneSplit.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2026 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import SwiftUI

private struct TwoPaneSplitKey: EnvironmentKey {
    static let defaultValue: SFKTwoPaneSplit? = nil
}

public extension EnvironmentValues {
    /// Set by a full-screen flow's root while the window shows two panes.
    /// `nil` means one column; views inside a pane reset it to `nil` so
    /// they lay out as the phone-shaped column they are.
    var twoPaneSplit: SFKTwoPaneSplit? {
        get { self[TwoPaneSplitKey.self] }
        set { self[TwoPaneSplitKey.self] = newValue }
    }
}
