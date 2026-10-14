/****************************************************************************
 * SFKFoldRegionLayout.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2026 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import CoreGraphics

/// Pure fold math for a container: which pose an active division region puts
/// it in, and where a column of interactive content should sit so nothing
/// interactive lands on the fold.
///
/// All rects are in the container's own coordinate space. SwiftUI already
/// mirrors reserved-region frames for right-to-left layouts, so "trailing"
/// here is simply the half with the larger x.
///
/// ## Usage
/// ```swift
/// let layout = SFKFoldRegionLayout(containerSize: size, divisionFrame: fold)
/// let column = layout.columnFrame(maxWidth: 560)
/// ```
public struct SFKFoldRegionLayout: Equatable, Sendable {

    /// A half narrower (book) or shorter (tabletop) than this is too cramped
    /// for a column; the layout then uses the other half, or stays centred.
    public static let minimumPaneLength: CGFloat = 300

    /// The container's size.
    public let containerSize: CGSize
    /// Frame of the active division region in the container's coordinates,
    /// or `nil` when there is none (flat, no fold, or before iOS 27.1).
    public let divisionFrame: CGRect?

    public init(containerSize: CGSize, divisionFrame: CGRect? = nil) {
        self.containerSize = containerSize
        self.divisionFrame = divisionFrame
    }

    private var bounds: CGRect {
        CGRect(origin: .zero, size: containerSize)
    }

    /// The pose, read from the region's shape: taller than wide is a book
    /// (left/right halves), wider than tall is tabletop (top/bottom halves).
    /// A region that misses the container, or has no area (the inactive fold
    /// of a flat device), is `.flat`.
    public var pose: SFKFoldPose {
        guard let divisionFrame, bounds.width > 0, bounds.height > 0 else { return .flat }

        let overlap = divisionFrame.intersection(bounds)
        guard !overlap.isNull, overlap.width > 0, overlap.height > 0 else { return .flat }

        // Classify on the whole region, not the overlap: a short container
        // (a footer, a progress bar) clips a book fold into a wide sliver.
        if divisionFrame.height >= divisionFrame.width {
            return .book(
                leading: CGRect(x: 0, y: 0, width: overlap.minX, height: bounds.height),
                trailing: CGRect(
                    x: overlap.maxX,
                    y: 0,
                    width: bounds.width - overlap.maxX,
                    height: bounds.height
                )
            )
        }

        return .tabletop(
            top: CGRect(x: 0, y: 0, width: bounds.width, height: overlap.minY),
            bottom: CGRect(
                x: 0,
                y: overlap.maxY,
                width: bounds.width,
                height: bounds.height - overlap.maxY
            )
        )
    }

    /// The half the column uses: the preferred one (trailing / bottom) when it
    /// is large enough, otherwise the other half, otherwise `nil` (centred).
    public var columnPane: CGRect? {
        let pose = pose
        if let preferred = pose.preferredPane, isUsable(preferred, in: pose) {
            return preferred
        }
        if let alternate = pose.alternatePane, isUsable(alternate, in: pose) {
            return alternate
        }
        return nil
    }

    /// Both halves of a book fold when each is wide enough for content, so a
    /// two-column layout can put one column per half and widen its gutter to
    /// the fold. `nil` when flat, tabletop, or either half is too narrow.
    public var usableBookHalves: (leading: CGRect, trailing: CGRect)? {
        let pose = pose
        guard case .book(let leading, let trailing) = pose,
              isUsable(leading, in: pose),
              isUsable(trailing, in: pose) else { return nil }
        return (leading, trailing)
    }

    /// The rect a column of interactive content of at most `maxWidth` should
    /// occupy: centred in the container when flat, centred inside the chosen
    /// half when folded.
    public func columnFrame(maxWidth: CGFloat) -> CGRect {
        Self.centredColumn(in: columnPane ?? bounds, maxWidth: maxWidth)
    }

    /// How the column modifier should place content of `contentHeight`.
    /// Tabletop only displaces content that fits inside the half; taller
    /// content stays centred and scrolls instead of being cropped.
    public func placement(maxWidth: CGFloat, contentHeight: CGFloat?) -> SFKFoldColumnPlacement {
        guard let pane = columnPane else { return .centred }
        let frame = Self.centredColumn(in: pane, maxWidth: maxWidth)

        switch pose {
        case .flat:
            return .centred
        case .book:
            return .bookPane(frame)
        case .tabletop:
            guard let contentHeight, contentHeight <= frame.height else { return .centred }
            return .tabletopPane(frame)
        }
    }

    private func isUsable(_ pane: CGRect, in pose: SFKFoldPose) -> Bool {
        let length = pose.splitsHorizontally ? pane.width : pane.height
        return length >= Self.minimumPaneLength
    }

    private static func centredColumn(in rect: CGRect, maxWidth: CGFloat) -> CGRect {
        let width = max(0, min(maxWidth, rect.width))
        return CGRect(
            x: rect.midX - width / 2,
            y: rect.minY,
            width: width,
            height: rect.height
        )
    }
}
