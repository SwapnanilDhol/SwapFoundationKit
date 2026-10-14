/****************************************************************************
 * SFKOnboardingLayout.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2026 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import CoreGraphics

/// Shared widths for onboarding, which runs full screen and therefore has to
/// hold its own shape on an iPad in landscape rather than stretching to fill it.
public enum SFKOnboardingLayout {

    /// Widest a single column of onboarding copy or controls should ever get.
    public static let contentWidth: CGFloat = 640

    /// Widest a welcome stage of scattered icons may spread. Icon positions
    /// are usually fractions of the stage, so an uncapped stage flings them
    /// off both edges.
    public static let iconStageWidth: CGFloat = 560

    /// Widest icon stage whose icons all land inside `availableWidth`.
    ///
    /// Assumes tiles placed at fractions from -0.05 to 1.04 of the stage, up
    /// to 112 pt wide, rotated and drifting a few points: a stage as wide as
    /// its pane flings the outer ones over the edges, and in a two-pane window
    /// across the centre line.
    public static func iconStageWidth(fitting availableWidth: CGFloat) -> CGFloat {
        min(iconStageWidth, max((availableWidth - 180) / 1.1, 0))
    }
}
