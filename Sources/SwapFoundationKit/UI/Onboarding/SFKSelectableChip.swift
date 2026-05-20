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
/// SFKSelectableChip(icon: "swift", text: "Swift", isSelected: true) {
///     selectLanguage()
/// }
/// ```
public struct SFKSelectableChip: View {
    private let icon: String?
    private let text: String
    private let isSelected: Bool
    private let tintColor: Color
    private let action: () -> Void

    /// Creates a chip from a conforming `SFKChipItem`.
    /// - Parameters:
    ///   - item: The chip item providing label and optional icon.
    ///   - isSelected: Whether the chip is currently selected.
    ///   - tintColor: The accent color for the selected state. Defaults to `.primary`.
    ///   - action: Closure executed when the chip is tapped.
    public init<Item: SFKChipItem>(
        item: Item,
        isSelected: Bool,
        tintColor: Color = .primary,
        action: @escaping () -> Void
    ) {
        self.icon = item.chipIcon
        self.text = item.chipLabel
        self.isSelected = isSelected
        self.tintColor = tintColor
        self.action = action
    }

    /// Creates a chip with icon and text.
    /// - Parameters:
    ///   - icon: An optional SF Symbol name.
    ///   - text: The label text.
    ///   - isSelected: Whether the chip is currently selected.
    ///   - tintColor: The accent color for the selected state. Defaults to `.primary`.
    ///   - action: Closure executed when the chip is tapped.
    public init(
        icon: String? = nil,
        text: String,
        isSelected: Bool,
        tintColor: Color = .primary,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.text = text
        self.isSelected = isSelected
        self.tintColor = tintColor
        self.action = action
    }

    /// Creates a chip with text only.
    /// - Parameters:
    ///   - title: The label text.
    ///   - isSelected: Whether the chip is currently selected.
    ///   - tintColor: The accent color for the selected state. Defaults to `.primary`.
    ///   - action: Closure executed when the chip is tapped.
    public init(
        _ title: String,
        isSelected: Bool,
        tintColor: Color = .primary,
        action: @escaping () -> Void
    ) {
        self.icon = nil
        self.text = title
        self.isSelected = isSelected
        self.tintColor = tintColor
        self.action = action
    }

    public var body: some View {
        Button(action: {
            triggerHaptic()
            action()
        }) {
            HStack(spacing: 8) {
                if let icon {
                    iconView(for: icon)
                        .font(.subheadline.weight(isSelected ? .semibold : .regular))
                        .foregroundStyle(tintColor)
                }

                Text(text)
                    .font(.subheadline.weight(isSelected ? .semibold : .regular))
                    .lineLimit(1)
                    .multilineTextAlignment(.leading)
                    .foregroundStyle(.primary)
            }
            .fixedSize(horizontal: true, vertical: false)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
        }
        .buttonStyle(.plain)
        .glassEffectCompat(
            style: .regular,
            color: glassTintColor,
            isInteractive: true,
            in: Capsule()
        )
        .overlay(
            Capsule(style: .continuous)
                .strokeBorder(
                    isSelected ? tintColor : Color.clear,
                    lineWidth: 2
                )
        )
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }

    /// Tint applied to the glass effect. Unselected chips carry only a faint
    /// wash of their own `tintColor` so a strip of chips reads as calm and
    /// colorful at rest; selected chips deepen the tint and pair with the
    /// semibold label + stroke for clear differentiation.
    private var glassTintColor: Color {
        isSelected ? tintColor.opacity(0.34) : tintColor.opacity(0.10)
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
            SFKSelectableChip(icon: "chart.line.uptrend.xyaxis", text: "Analytics", isSelected: selected == "Analytics", tintColor: .purple) { selected = "Analytics" }
            SFKSelectableChip(icon: "bell.fill", text: "Notifications", isSelected: selected == "Notifications", tintColor: .purple) { selected = "Notifications" }
            SFKSelectableChip(icon: "lock.fill", text: "Security", isSelected: selected == "Security", tintColor: .purple) { selected = "Security" }
        }
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
