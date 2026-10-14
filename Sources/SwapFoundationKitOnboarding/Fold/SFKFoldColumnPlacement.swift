/****************************************************************************
 * SFKFoldColumnPlacement.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2026 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import CoreGraphics

/// Where ``SwiftUI/View/sfkFoldAwareColumn(maxWidth:)`` puts its column, in
/// the container's coordinate space.
public enum SFKFoldColumnPlacement: Equatable, Sendable {
    /// No usable fold: the column is centred, like a readable content width.
    case centred
    /// Book-folded: the column sits inside one side-by-side half (`frame`).
    case bookPane(CGRect)
    /// Tabletop: the column fits inside one stacked half (`frame`).
    case tabletopPane(CGRect)
}
