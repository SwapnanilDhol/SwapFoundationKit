/****************************************************************************
 * SFKSelectableChip.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2026 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import SwiftUI

#if canImport(UIKit) && os(iOS)
import UIKit
#endif

/// A selectable chip/capsule button that toggles between selected and unselected states
/// with distinct visual styling and the shared theme feedback policy.
///
/// ## Usage
/// ```swift
/// // With a conforming model type
/// SFKSelectableChip(item: myGoal, isSelected: true, tintColor: .blue) {
///     toggleSelection()
/// }
///
/// // With raw text
/// SFKSelectableChip("Swift", isSelected: false) {
///     selectLanguage()
/// }
///
/// // With icon and text
/// SFKSelectableChip("Swift", icon: "swift", isSelected: true) {
///     selectLanguage()
/// }
/// ```
public struct SFKSelectableChip: View {
    @Environment(\.sfkTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    private let hapticsHelper = HapticsHelper()

    public enum VisualStyle: Sendable {
        case standard
        case subtle
    }

    private let icon: String?
    private let trailingAccessoryIcon: String?
    private let text: String
    private let isSelected: Bool
    private let tintColor: Color?
    private let iconTint: Color?
    private let visualStyle: VisualStyle
    private let controlSize: ControlSize
    private let action: () -> Void

    /// Creates a chip with text and an optional icon.
    /// - Parameters:
    ///   - text: The label text.
    ///   - icon: An optional SF Symbol name.
    ///   - isSelected: Whether the chip is currently selected.
    ///   - tintColor: The accent color for the selected state. Defaults to `.primary`.
    ///   - iconTint: Optional icon override. When `nil`, the chip uses its built-in tint logic.
    ///   - visualStyle: Visual emphasis variant. Defaults to `.standard`.
    ///   - controlSize: Platform-relative sizing. Use `.small` for dense chip groups.
    ///   - trailingAccessoryIcon: Optional SF Symbol or text accessory displayed after the label.
    ///   - action: Closure executed when the chip is tapped.
    public init(
        _ text: String,
        icon: String? = nil,
        isSelected: Bool,
        tintColor: Color? = nil,
        iconTint: Color? = nil,
        visualStyle: VisualStyle = .standard,
        controlSize: ControlSize = .regular,
        trailingAccessoryIcon: String? = nil,
        action: @escaping () -> Void
    ) {
        self.init(
            text: text,
            icon: icon,
            isSelected: isSelected,
            tintColor: tintColor,
            iconTint: iconTint,
            visualStyle: visualStyle,
            controlSize: controlSize,
            trailingAccessoryIcon: trailingAccessoryIcon,
            action: action
        )
    }

    /// Backwards-compatible convenience initializer for existing `icon:text:` call sites.
    /// - Parameters:
    ///   - icon: An optional SF Symbol name.
    ///   - visualStyle: Visual emphasis variant. Defaults to `.standard`.
    ///   - controlSize: Platform-relative sizing. Use `.small` for dense chip groups.
    ///   - trailingAccessoryIcon: Optional SF Symbol or text accessory displayed after the label.
    ///   - text: The label text.
    ///   - isSelected: Whether the chip is currently selected.
    ///   - tintColor: The accent color for the selected state. Defaults to `.primary`.
    ///   - iconTint: Optional icon override. When `nil`, the chip uses its built-in tint logic.
    ///   - action: Closure executed when the chip is tapped.
    public init(
        icon: String? = nil,
        visualStyle: VisualStyle = .standard,
        controlSize: ControlSize = .regular,
        trailingAccessoryIcon: String? = nil,
        text: String,
        isSelected: Bool,
        tintColor: Color? = nil,
        iconTint: Color? = nil,
        action: @escaping () -> Void
    ) {
        self.init(
            text,
            icon: icon,
            isSelected: isSelected,
            tintColor: tintColor,
            iconTint: iconTint,
            visualStyle: visualStyle,
            controlSize: controlSize,
            trailingAccessoryIcon: trailingAccessoryIcon,
            action: action
        )
    }

    private init(
        text: String,
        icon: String?,
        isSelected: Bool,
        tintColor: Color?,
        iconTint: Color?,
        visualStyle: VisualStyle,
        controlSize: ControlSize,
        trailingAccessoryIcon: String?,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.trailingAccessoryIcon = trailingAccessoryIcon
        self.text = text
        self.isSelected = isSelected
        self.tintColor = tintColor
        self.iconTint = iconTint
        self.visualStyle = visualStyle
        self.controlSize = controlSize
        self.action = action
    }

    public var body: some View {
        Button {
            triggerHaptic()
            action()
        } label: {
            HStack(spacing: contentSpacing) {
                if let icon {
                    iconView(for: icon)
                        .font(iconFont)
                        .foregroundStyle(resolvedIconColor)
                }

                Text(text)
                    .font(labelFont)
                    .lineLimit(1)
                    .multilineTextAlignment(.leading)
                    .foregroundStyle(labelColor)

                if let trailingAccessoryIcon {
                    iconView(for: trailingAccessoryIcon)
                        .font(trailingIconFont)
                        .foregroundStyle(resolvedIconColor)
                }
            }
            .fixedSize(horizontal: true, vertical: false)
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, verticalPadding)
        }
        .buttonStyle(.plain)
        .controlSize(controlSize)
        .overlay(
            Capsule(style: .continuous)
                .strokeBorder(
                    strokeColor,
                    lineWidth: strokeWidth
                )
        )
        .sfkGlass(
            material: .regular,
            tint: glassTintColor,
            isInteractive: true,
            shape: .capsule
        )
        .animation(reduceMotion ? nil : theme.motion.standard, value: isSelected)
    }

    /// Tint applied to the glass effect. Unselected chips carry only a faint
    /// wash of their own `tintColor` so a strip of chips reads as calm and
    /// colorful at rest; selected chips deepen the tint and pair with the
    /// semibold label + stroke for clear differentiation.
    private var glassTintColor: Color {
        switch visualStyle {
        case .standard:
            return isSelected ? resolvedTintColor.opacity(0.34) : resolvedTintColor.opacity(0.10)
        case .subtle:
            return isSelected ? resolvedTintColor.opacity(0.18) : resolvedTintColor.opacity(0.06)
        }
    }

    private var strokeColor: Color {
        switch visualStyle {
        case .standard:
            return isSelected ? resolvedTintColor : .clear
        case .subtle:
            return isSelected ? resolvedTintColor.opacity(0.35) : theme.colors.border
        }
    }

    private var strokeWidth: CGFloat {
        visualStyle == .standard ? 2 : 1
    }

    private var horizontalPadding: CGFloat {
        guard !isCompact else { return sizeMetrics.horizontalPadding }
        return visualStyle == .standard ? theme.spacing.control + 2 : theme.spacing.control
    }

    private var verticalPadding: CGFloat {
        guard !isCompact else { return sizeMetrics.verticalPadding }
        return visualStyle == .standard ? theme.spacing.inline + 2 : theme.spacing.inline
    }

    private var contentSpacing: CGFloat {
        isCompact ? sizeMetrics.contentSpacing : theme.spacing.inline
    }

    private var isCompact: Bool {
        controlSize == .mini || controlSize == .small
    }

    private var labelFont: Font {
        guard !isCompact else {
            return isSelected ? sizeMetrics.labelFont.weight(.semibold) : sizeMetrics.labelFont
        }

        switch visualStyle {
        case .standard:
            return theme.typography.body.weight(isSelected ? .semibold : .regular)
        case .subtle:
            return theme.typography.caption.weight(.semibold)
        }
    }

    private var iconFont: Font {
        guard !isCompact else { return sizeMetrics.iconFont }

        switch visualStyle {
        case .standard:
            return theme.typography.body.weight(isSelected ? .semibold : .regular)
        case .subtle:
            return theme.typography.caption.weight(.semibold)
        }
    }

    private var trailingIconFont: Font {
        switch visualStyle {
        case .standard:
            return .caption.weight(.bold)
        case .subtle:
            return .caption2.weight(.bold)
        }
    }

    private var sizeMetrics: SFKChipSizeMetrics {
        SFKChipSizeMetrics(controlSize: controlSize, theme: theme)
    }

    private var labelColor: Color {
        switch visualStyle {
        case .standard:
            return theme.colors.text
        case .subtle:
            return theme.colors.text.opacity(0.82)
        }
    }

    private var resolvedIconColor: Color {
        if let iconTint {
            return iconTint
        }

        switch visualStyle {
        case .standard:
            return resolvedTintColor
        case .subtle:
            return resolvedTintColor.opacity(0.9)
        }
    }

    /// Renders the icon as an SF Symbol when the string maps to a valid system
    /// image, otherwise falls back to plain text (so emoji icons still work).
    @ViewBuilder
    private func iconView(for icon: String) -> some View {
        #if canImport(UIKit) && os(iOS)
        if UIImage(systemName: icon) != nil {
            Image(systemName: icon)
        } else {
            Text(icon)
        }
        #else
        Text(icon)
        #endif
    }

    private func triggerHaptic() {
        guard theme.feedback.enabled else { return }
        #if canImport(UIKit) && os(iOS)
        switch theme.feedback.style {
        case .none: break
        case .light: hapticsHelper.lightImpact()
        case .medium: hapticsHelper.mediumImpact()
        case .heavy: hapticsHelper.heavyImpact()
        }
        #endif
    }

    private var resolvedTintColor: Color {
        tintColor ?? theme.colors.accent
    }
}

#Preview("SFKSelectableChip") {
    @Previewable @State var selected: String? = "Swift"

    let languages = ["Swift", "Objective-C", "Rust", "Kotlin", "Dart", "Go"]

    VStack(alignment: .leading, spacing: 16) {
        Text("Select a language:")
            .font(.headline)

        SFKChipFlowLayout(spacing: 8) {
            ForEach(languages, id: \.self) { lang in
                SFKSelectableChip(
                    lang,
                    isSelected: selected == lang,
                    tintColor: .blue
                ) {
                    selected = lang
                }
            }
        }
    }
    .padding(24)
}

#Preview("With Icons") {
    @Previewable @State var selected: String? = nil

    VStack(alignment: .leading, spacing: 16) {
        Text("Choose a category:")
            .font(.headline)

        SFKChipFlowLayout(spacing: 8) {
            SFKSelectableChip("Analytics", icon: "chart.line.uptrend.xyaxis", isSelected: selected == "Analytics", tintColor: .purple) {
                selected = "Analytics"
            }
            SFKSelectableChip("Notifications", icon: "bell.fill", isSelected: selected == "Notifications", tintColor: .purple) {
                selected = "Notifications"
            }
            SFKSelectableChip("Security", icon: "lock.fill", isSelected: selected == "Security", tintColor: .purple) {
                selected = "Security"
            }
        }
    }
    .padding(24)
}

#Preview("With Trailing Accessory") {
    VStack(alignment: .leading, spacing: 16) {
        Text("Picker style chip:")
            .font(.headline)

        SFKSelectableChip(
            "USD",
            icon: "$",
            isSelected: true,
            tintColor: .blue,
            visualStyle: .subtle,
            trailingAccessoryIcon: "chevron.down"
        ) {}
    }
    .padding(24)
}

#Preview("Multi-Select") {
    @Previewable @State var selected: Set<String> = ["Swift"]

    let items = ["Swift", "Python", "JavaScript", "Rust"]

    VStack(alignment: .leading, spacing: 16) {
        Text("Select multiple:")
            .font(.headline)

        SFKChipFlowLayout(spacing: 8) {
            ForEach(items, id: \.self) { item in
                SFKSelectableChip(
                    item,
                    isSelected: selected.contains(item),
                    tintColor: .green
                ) {
                    if selected.contains(item) {
                        selected.remove(item)
                    } else {
                        selected.insert(item)
                    }
                }
            }
        }

        Text("Selected: \(selected.sorted().joined(separator: ", "))")
            .font(.caption)
            .foregroundStyle(.secondary)
    }
    .padding(24)
}
