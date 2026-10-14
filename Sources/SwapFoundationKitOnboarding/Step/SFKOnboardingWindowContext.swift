/****************************************************************************
 * SFKOnboardingWindowContext.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2026 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import SwiftUI

/// What an ``SFKOnboardingWindow`` measured, handed to its content.
public struct SFKOnboardingWindowContext: Equatable {
    /// The pane split, or `nil` for one column (compact width, a window too
    /// narrow for two panes, or `.centredColumn` mode).
    public let split: SFKTwoPaneSplit?
    /// The root's size inside the safe area.
    public let size: CGSize
    /// The root's safe area insets. Pass `bottom` to full-bleed screens that
    /// ignore the bottom safe area and add it back under their actions;
    /// `top` is zero when iPhone Duo puts the status bar on the side.
    public let safeAreaInsets: EdgeInsets

    public init(split: SFKTwoPaneSplit?, size: CGSize, safeAreaInsets: EdgeInsets) {
        self.split = split
        self.size = size
        self.safeAreaInsets = safeAreaInsets
    }
}
