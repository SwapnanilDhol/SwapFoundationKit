//
//  SFKSelectableChip.swift
//  SwapFoundationKit
//
//  Created by Swapnanil Dhol on 4/30/26.
//

import SwiftUI

#if canImport(UIKit) && os(iOS)
import UIKit
#endif

/// A protocol that defines the data requirements for a selectable chip.
///
/// Conform your model types to this protocol to use them directly with
/// `SFKSelectableChip`.
///
/// ## Usage
/// ```swift
/// enum Goal: String, CaseIterable, SFKChipItem {
///     case trackSpending = "Track Spending"
///     case saveMoney = "Save Money"
///
///     var chipLabel: String { rawValue }
///     var chipIcon: String? { nil }
/// }
///
/// SFKSelectableChip(item: goal, isSelected: true) { }
/// ```
public protocol SFKChipItem {
    /// The text displayed on the chip.
    var chipLabel: String { get }

    /// An optional SF Symbol name displayed before the label.
    var chipIcon: String? { get }
}

/// Default implementation providing `nil` for the icon.
public extension SFKChipItem {
    var chipIcon: String? { nil }
}

/// A selectable chip/capsule button that toggles between selected and unselected states
/// with distinct visual styling and optional haptic feedback.
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
    public enum VisualStyle: Sendable {
        case standard
        case subtle
    }

    private let icon: String?
    private let trailingAccessoryIcon: String?
    private let text: String
    private let isSelected: Bool
    private let tintColor: Color
    private let iconTint: Color?
    private let visualStyle: VisualStyle
    private let action: () -> Void

    /// Creates a chip from a conforming `SFKChipItem`.
    /// - Parameters:
    ///   - item: The chip item providing label and optional icon.
    ///   - isSelected: Whether the chip is currently selected.
    ///   - tintColor: The accent color for the selected state. Defaults to `.primary`.
    ///   - iconTint: Optional icon override. When `nil`, the chip uses its built-in tint logic.
    ///   - visualStyle: Visual emphasis variant. Defaults to `.standard`.
    ///   - trailingAccessoryIcon: Optional SF Symbol or text accessory displayed after the label.
    ///   - action: Closure executed when the chip is tapped.
    public init<Item: SFKChipItem>(
        item: Item,
        isSelected: Bool,
        tintColor: Color = .primary,
        iconTint: Color? = nil,
        visualStyle: VisualStyle = .standard,
        trailingAccessoryIcon: String? = nil,
        action: @escaping () -> Void
    ) {
        self.init(
            text: item.chipLabel,
            icon: item.chipIcon,
            isSelected: isSelected,
            tintColor: tintColor,
            iconTint: iconTint,
            visualStyle: visualStyle,
            trailingAccessoryIcon: trailingAccessoryIcon,
            action: action
        )
    }

    /// Creates a chip with text and an optional icon.
    /// - Parameters:
    ///   - text: The label text.
    ///   - icon: An optional SF Symbol name.
    ///   - isSelected: Whether the chip is currently selected.
    ///   - tintColor: The accent color for the selected state. Defaults to `.primary`.
    ///   - iconTint: Optional icon override. When `nil`, the chip uses its built-in tint logic.
    ///   - visualStyle: Visual emphasis variant. Defaults to `.standard`.
    ///   - trailingAccessoryIcon: Optional SF Symbol or text accessory displayed after the label.
    ///   - action: Closure executed when the chip is tapped.
    public init(
        _ text: String,
        icon: String? = nil,
        isSelected: Bool,
        tintColor: Color = .primary,
        iconTint: Color? = nil,
        visualStyle: VisualStyle = .standard,
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
            trailingAccessoryIcon: trailingAccessoryIcon,
            action: action
        )
    }

    /// Backwards-compatible convenience initializer for existing `icon:text:` call sites.
    /// - Parameters:
    ///   - icon: An optional SF Symbol name.
    ///   - visualStyle: Visual emphasis variant. Defaults to `.standard`.
    ///   - trailingAccessoryIcon: Optional SF Symbol or text accessory displayed after the label.
    ///   - text: The label text.
    ///   - isSelected: Whether the chip is currently selected.
    ///   - tintColor: The accent color for the selected state. Defaults to `.primary`.
    ///   - iconTint: Optional icon override. When `nil`, the chip uses its built-in tint logic.
    ///   - action: Closure executed when the chip is tapped.
    public init(
        icon: String? = nil,
        visualStyle: VisualStyle = .standard,
        trailingAccessoryIcon: String? = nil,
        text: String,
        isSelected: Bool,
        tintColor: Color = .primary,
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
            trailingAccessoryIcon: trailingAccessoryIcon,
            action: action
        )
    }

    private init(
        text: String,
        icon: String?,
        isSelected: Bool,
        tintColor: Color,
        iconTint: Color?,
        visualStyle: VisualStyle,
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
        self.action = action
    }

    public var body: some View {
        Button {
            triggerHaptic()
            action()
        } label: {
            HStack(spacing: 8) {
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
        .overlay(
            Capsule(style: .continuous)
                .strokeBorder(
                    strokeColor,
                    lineWidth: strokeWidth
                )
        )
        .glassEffectCompat(
            style: .regular,
            color: glassTintColor,
            isInteractive: true,
            in: Capsule()
        )
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }

    /// Tint applied to the glass effect. Unselected chips carry only a faint
    /// wash of their own `tintColor` so a strip of chips reads as calm and
    /// colorful at rest; selected chips deepen the tint and pair with the
    /// semibold label + stroke for clear differentiation.
    private var glassTintColor: Color {
        switch visualStyle {
        case .standard:
            return isSelected ? tintColor.opacity(0.34) : tintColor.opacity(0.10)
        case .subtle:
            return isSelected ? tintColor.opacity(0.18) : tintColor.opacity(0.06)
        }
    }

    private var strokeColor: Color {
        switch visualStyle {
        case .standard:
            return isSelected ? tintColor : .clear
        case .subtle:
            return isSelected ? tintColor.opacity(0.35) : Color.primary.opacity(0.06)
        }
    }

    private var strokeWidth: CGFloat {
        visualStyle == .standard ? 2 : 1
    }

    private var horizontalPadding: CGFloat {
        visualStyle == .standard ? 14 : 12
    }

    private var verticalPadding: CGFloat {
        visualStyle == .standard ? 10 : 8
    }

    private var labelFont: Font {
        switch visualStyle {
        case .standard:
            return .subheadline.weight(isSelected ? .semibold : .regular)
        case .subtle:
            return .footnote.weight(.semibold)
        }
    }

    private var iconFont: Font {
        switch visualStyle {
        case .standard:
            return .subheadline.weight(isSelected ? .semibold : .regular)
        case .subtle:
            return .footnote.weight(.semibold)
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

    private var labelColor: Color {
        switch visualStyle {
        case .standard:
            return .primary
        case .subtle:
            return .primary.opacity(0.82)
        }
    }

    private var resolvedIconColor: Color {
        if let iconTint {
            return iconTint
        }

        switch visualStyle {
        case .standard:
            return tintColor
        case .subtle:
            return tintColor.opacity(0.9)
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
        #if canImport(UIKit) && os(iOS)
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        #endif
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
