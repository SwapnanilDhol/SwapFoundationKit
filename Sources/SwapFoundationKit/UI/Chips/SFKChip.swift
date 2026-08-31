/****************************************************************************
 * SFKChip.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2026 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import SwiftUI

/// The visual hierarchy of an action chip.
public enum SFKChipStyle: Sendable {
    /// A prominent chip for the preferred action in a chip group.
    case primary
    /// A quieter chip for supporting actions.
    case secondary
}

/// A compact capsule-shaped action control.
///
/// Use ``SFKChip`` when tapping the chip performs an action. Use
/// ``SFKSelectableChip`` when the chip represents selected state.
///
/// ## Usage
/// ```swift
/// SFKChip(
///     "Category",
///     leadingIconName: "tag",
///     controlSize: .small,
///     style: .secondary
/// ) {
///     presentCategoryEditor()
/// }
/// ```
@available(iOS 16, *)
public struct SFKChip: View {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.sfkTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let hapticsHelper = HapticsHelper()

    private let title: String
    private let leadingIconName: String?
    private let tintColor: Color?
    private let controlSize: ControlSize
    private let style: SFKChipStyle
    private let action: () -> Void

    public init(
        _ title: String,
        leadingIconName: String? = nil,
        tintColor: Color? = nil,
        controlSize: ControlSize = .regular,
        style: SFKChipStyle = .secondary,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.leadingIconName = leadingIconName
        self.tintColor = tintColor
        self.controlSize = controlSize
        self.style = style
        self.action = action
    }

    public var body: some View {
        Button {
            triggerHapticIfNeeded()
            action()
        } label: {
            HStack(spacing: metrics.contentSpacing) {
                if let leadingIconName {
                    Image(systemName: leadingIconName)
                        .font(metrics.iconFont)
                }

                Text(title)
                    .font(metrics.labelFont)
                    .lineLimit(1)
            }
            .fixedSize(horizontal: true, vertical: false)
            .padding(.horizontal, metrics.horizontalPadding)
            .padding(.vertical, metrics.verticalPadding)
            .foregroundStyle(theme.colors.text)
            .contentShape(Capsule(style: .continuous))
        }
        .buttonStyle(.plain)
        .controlSize(controlSize)
        .overlay {
            Capsule(style: .continuous)
                .strokeBorder(strokeColor, lineWidth: strokeWidth)
        }
        .sfkGlass(
            material: .regular,
            tint: glassTintColor,
            isInteractive: isEnabled,
            shape: .capsule
        )
        .opacity(isEnabled ? 1 : 0.55)
        .animation(reduceMotion ? nil : theme.motion.standard, value: isEnabled)
    }

    private var metrics: SFKChipSizeMetrics {
        SFKChipSizeMetrics(controlSize: controlSize, theme: theme)
    }

    private var glassTintColor: Color {
        switch style {
        case .primary:
            resolvedTintColor.opacity(0.28)
        case .secondary:
            resolvedTintColor.opacity(0.08)
        }
    }

    private var strokeColor: Color {
        switch style {
        case .primary:
            resolvedTintColor.opacity(0.75)
        case .secondary:
            theme.colors.border
        }
    }

    private var strokeWidth: CGFloat {
        switch style {
        case .primary: 1.5
        case .secondary: 1
        }
    }

    private func triggerHapticIfNeeded() {
        guard isEnabled else { return }

        guard theme.feedback.enabled else { return }

        switch theme.feedback.style {
        case .light:
            hapticsHelper.lightImpact()
        case .medium:
            hapticsHelper.mediumImpact()
        case .heavy:
            hapticsHelper.heavyImpact()
        case .none:
            break
        }
    }

    private var resolvedTintColor: Color {
        tintColor ?? theme.colors.accent
    }
}

struct SFKChipSizeMetrics {
    let controlSize: ControlSize
    let theme: SFKTheme

    var isCompact: Bool {
        controlSize == .mini || controlSize == .small
    }

    init(controlSize: ControlSize, theme: SFKTheme) {
        self.controlSize = controlSize
        self.theme = theme
    }

    var horizontalPadding: CGFloat {
        isCompact ? theme.spacing.inline + 4 : theme.spacing.control + 2
    }

    var verticalPadding: CGFloat {
        isCompact ? theme.spacing.inline - 2 : theme.spacing.inline + 2
    }

    var contentSpacing: CGFloat {
        isCompact ? theme.spacing.inline - 1 : theme.spacing.inline
    }

    var labelFont: Font {
        isCompact ? theme.typography.caption.weight(.medium) : theme.typography.body.weight(.semibold)
    }

    var iconFont: Font {
        isCompact ? theme.typography.caption.weight(.semibold) : theme.typography.body.weight(.semibold)
    }
}

#Preview("Action Chips") {
    SFKChipFlowLayout(spacing: 8) {
        SFKChip("Primary", leadingIconName: "star.fill", controlSize: .small, style: .primary) {}
        SFKChip("Secondary", leadingIconName: "tag", controlSize: .small, style: .secondary) {}
    }
    .padding()
}
