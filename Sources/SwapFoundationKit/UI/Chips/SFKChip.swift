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

/// The haptic feedback emitted when an ``SFKChip`` is tapped.
public enum SFKChipHapticStyle: Sendable {
    case light
    case medium
    case heavy
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

    private let hapticsHelper = HapticsHelper()

    private let title: String
    private let leadingIconName: String?
    private let tintColor: Color
    private let controlSize: ControlSize
    private let style: SFKChipStyle
    private let hapticStyle: SFKChipHapticStyle?
    private let action: () -> Void

    public init(
        _ title: String,
        leadingIconName: String? = nil,
        tintColor: Color = .blue,
        controlSize: ControlSize = .regular,
        style: SFKChipStyle = .secondary,
        hapticStyle: SFKChipHapticStyle? = .light,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.leadingIconName = leadingIconName
        self.tintColor = tintColor
        self.controlSize = controlSize
        self.style = style
        self.hapticStyle = hapticStyle
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
            .foregroundStyle(.primary)
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
    }

    private var metrics: SFKChipSizeMetrics {
        SFKChipSizeMetrics(controlSize: controlSize)
    }

    private var glassTintColor: Color {
        switch style {
        case .primary:
            tintColor.opacity(0.28)
        case .secondary:
            tintColor.opacity(0.08)
        }
    }

    private var strokeColor: Color {
        switch style {
        case .primary:
            tintColor.opacity(0.75)
        case .secondary:
            Color.primary.opacity(0.06)
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

        switch hapticStyle {
        case .light:
            hapticsHelper.lightImpact()
        case .medium:
            hapticsHelper.mediumImpact()
        case .heavy:
            hapticsHelper.heavyImpact()
        case nil:
            break
        }
    }
}

struct SFKChipSizeMetrics {
    let controlSize: ControlSize

    var isCompact: Bool {
        controlSize == .mini || controlSize == .small
    }

    var horizontalPadding: CGFloat {
        isCompact ? 12 : 14
    }

    var verticalPadding: CGFloat {
        isCompact ? 6 : 10
    }

    var contentSpacing: CGFloat {
        isCompact ? 7 : 8
    }

    var labelFont: Font {
        isCompact ? .subheadline.weight(.medium) : .subheadline.weight(.semibold)
    }

    var iconFont: Font {
        isCompact ? .footnote.weight(.semibold) : .subheadline.weight(.semibold)
    }
}

#Preview("Action Chips") {
    SFKChipFlowLayout(spacing: 8) {
        SFKChip("Primary", leadingIconName: "star.fill", controlSize: .small, style: .primary) {}
        SFKChip("Secondary", leadingIconName: "tag", controlSize: .small, style: .secondary) {}
    }
    .padding()
}
