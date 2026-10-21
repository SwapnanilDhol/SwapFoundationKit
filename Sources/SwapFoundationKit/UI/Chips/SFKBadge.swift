/*****************************************************************************
 * SFKBadge.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2026 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import SwiftUI

/// A compact, non-interactive capsule that labels a status, such as "PRO",
/// "TODAY", or "UP 25%".
///
/// Use ``SFKBadge`` for information the person reads, not taps. It has no
/// button trait, no haptics, and no glass. For a tappable capsule use
/// ``SFKChip``.
///
/// A badge with a `tintColor` draws the tint as its text over a soft fill of
/// the same color. Without one it uses the theme's secondary text over a
/// neutral fill.
///
/// ## Usage
/// ```swift
/// SFKBadge("TODAY", tintColor: .green)
/// SFKBadge("2 DAYS LATE", leadingIconName: "clock", tintColor: .orange)
/// SFKBadge("PAUSED")
/// ```
@available(iOS 16, *)
public struct SFKBadge: View {
    @Environment(\.sfkTheme) private var theme

    private let title: String
    private let leadingIconName: String?
    private let tintColor: Color?
    private let controlSize: ControlSize

    /// - Parameters:
    ///   - title: The badge label.
    ///   - leadingIconName: An optional SF Symbol shown before the label.
    ///   - tintColor: The text color and the base of the fill. `nil` draws a
    ///     neutral badge.
    ///   - controlSize: `.mini` and `.small` draw a compact badge for rows;
    ///     larger sizes draw a roomier one for headers and cards.
    public init(
        _ title: String,
        leadingIconName: String? = nil,
        tintColor: Color? = nil,
        controlSize: ControlSize = .small
    ) {
        self.title = title
        self.leadingIconName = leadingIconName
        self.tintColor = tintColor
        self.controlSize = controlSize
    }

    public var body: some View {
        HStack(spacing: metrics.contentSpacing) {
            if let leadingIconName {
                Image(systemName: leadingIconName)
                    .font(metrics.font)
                    .accessibilityHidden(true)
            }
            Text(title)
                .font(metrics.font)
                .lineLimit(1)
        }
        .foregroundStyle(foregroundColor)
        .padding(.horizontal, metrics.horizontalPadding)
        .padding(.vertical, metrics.verticalPadding)
        .background(Capsule(style: .continuous).fill(fillColor))
        .fixedSize()
        .accessibilityElement(children: .combine)
    }

    private var metrics: SFKBadgeSizeMetrics {
        SFKBadgeSizeMetrics(controlSize: controlSize, theme: theme)
    }

    private var foregroundColor: Color {
        tintColor ?? theme.colors.secondaryText
    }

    private var fillColor: Color {
        if let tintColor { return tintColor.opacity(0.15) }
        return Color(uiColor: .tertiarySystemFill)
    }
}

struct SFKBadgeSizeMetrics {
    let controlSize: ControlSize
    let theme: SFKTheme

    var isCompact: Bool {
        controlSize == .mini || controlSize == .small
    }

    var horizontalPadding: CGFloat {
        isCompact ? theme.spacing.inline : theme.spacing.control
    }

    var verticalPadding: CGFloat {
        isCompact ? theme.spacing.inline / 2 : theme.spacing.inline - 2
    }

    var contentSpacing: CGFloat {
        isCompact ? theme.spacing.inline / 2 : theme.spacing.inline - 2
    }

    var font: Font {
        isCompact ? .caption2.weight(.bold) : .caption.weight(.bold)
    }
}

#Preview("Badges") {
    VStack(alignment: .leading, spacing: 12) {
        HStack(spacing: 8) {
            SFKBadge("TODAY", tintColor: .green)
            SFKBadge("2 DAYS LATE", tintColor: .orange)
            SFKBadge("PAUSED")
        }
        HStack(spacing: 8) {
            SFKBadge("PRO", leadingIconName: "sparkles", tintColor: .green, controlSize: .regular)
            SFKBadge("UP 25%", leadingIconName: "arrow.up.right", tintColor: .orange, controlSize: .regular)
        }
    }
    .padding()
}
