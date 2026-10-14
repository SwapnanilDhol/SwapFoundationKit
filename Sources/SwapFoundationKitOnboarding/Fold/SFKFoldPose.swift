/****************************************************************************
 * SFKFoldPose.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2026 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import CoreGraphics

/// How an active fold (a division reserved region) splits a container.
///
/// Derived from the region's shape, never from orientation or hinge angle:
/// a region taller than wide divides the container into leading and trailing
/// halves (book), a region wider than tall into top and bottom halves (tabletop).
/// The half rects exclude the region itself, which already includes the
/// system's margins for interactive content.
public enum SFKFoldPose: Equatable, Sendable {
    /// No active fold crosses the container.
    case flat
    /// Partially folded like a book: left and right halves.
    case book(leading: CGRect, trailing: CGRect)
    /// Partially folded on a surface: raised top half and flat bottom half.
    case tabletop(top: CGRect, bottom: CGRect)

    /// The half interactive content prefers: trailing when book-folded (thumb
    /// side, where the vertical bar sits and where content continues when the
    /// device closes), bottom when tabletop (the surface you touch).
    public var preferredPane: CGRect? {
        switch self {
        case .flat:
            nil
        case .book(_, let trailing):
            trailing
        case .tabletop(_, let bottom):
            bottom
        }
    }

    /// The other half, used when the preferred one is too small.
    public var alternatePane: CGRect? {
        switch self {
        case .flat:
            nil
        case .book(let leading, _):
            leading
        case .tabletop(let top, _):
            top
        }
    }

    /// Whether the halves sit side by side (book) rather than stacked (tabletop).
    public var splitsHorizontally: Bool {
        switch self {
        case .book:
            true
        case .flat, .tabletop:
            false
        }
    }
}
