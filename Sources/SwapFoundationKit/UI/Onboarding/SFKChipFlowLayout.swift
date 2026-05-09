//
//  SFKChipFlowLayout.swift
//  SwapFoundationKit
//
//  Created by Swapnanil Dhol on 4/30/26.
//

import SwiftUI

/// A generic wrapping/flex-flow `Layout` that places subviews left-to-right and wraps
/// to the next line when the row exceeds the available width.
///
/// Use this layout to create chip-style tag clouds, multi-select option groups,
/// or any content that needs to flow naturally across multiple lines.
///
/// ## Usage
/// ```swift
/// SFKChipFlowLayout(spacing: 8) {
///     SFKSelectableChip("Swift", isSelected: true) { }
///     SFKSelectableChip("Objective-C", isSelected: false) { }
///     SFKSelectableChip("Rust", isSelected: false) { }
/// }
/// ```
public struct SFKChipFlowLayout: Layout {
    /// The spacing between items both horizontally and vertically.
    public var spacing: CGFloat

    /// Creates a chip flow layout with the specified spacing.
    /// - Parameter spacing: The gap between items. Defaults to 8.
    public init(spacing: CGFloat = 8) {
        self.spacing = spacing
    }

    public func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) -> CGSize {
        let maxWidth = proposal.width ?? 0
        guard maxWidth > 0 else {
            let totalWidth = subviews.reduce(CGFloat.zero) { partial, subview in
                partial + subview.sizeThatFits(.unspecified).width
            } + CGFloat(max(0, subviews.count - 1)) * spacing
            let maxHeight = subviews.map { $0.sizeThatFits(.unspecified).height }.max() ?? 0
            return CGSize(width: totalWidth, height: maxHeight)
        }

        var rowWidth: CGFloat = 0
        var rowHeight: CGFloat = 0
        var totalHeight: CGFloat = 0
        var usedRows = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            let proposedRowWidth = rowWidth == 0 ? size.width : rowWidth + spacing + size.width

            if proposedRowWidth > maxWidth, rowWidth > 0 {
                totalHeight += rowHeight
                rowWidth = size.width
                rowHeight = size.height
                usedRows += 1
            } else {
                rowWidth = proposedRowWidth
                rowHeight = max(rowHeight, size.height)
            }
        }

        if rowHeight > 0 {
            totalHeight += rowHeight
            usedRows += 1
        }

        let totalSpacing = CGFloat(max(0, usedRows - 1)) * spacing
        return CGSize(width: maxWidth, height: totalHeight + totalSpacing)
    }

    public func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) {
        var x = bounds.minX
        var y = bounds.minY
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            let nextX = x + size.width

            if nextX > bounds.maxX, x > bounds.minX {
                x = bounds.minX
                y += rowHeight + spacing
                rowHeight = 0
            }

            subview.place(
                at: CGPoint(x: x, y: y),
                proposal: ProposedViewSize(width: size.width, height: size.height)
            )

            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}

#Preview("SFKChipFlowLayout") {
    @Previewable @State var selected: String? = "Swift"

    let chips = ["Swift", "Objective-C", "Rust", "Kotlin", "Dart", "Go", "Python", "TypeScript"]

    ScrollView {
        VStack(alignment: .leading, spacing: 16) {
            Text("Select a language:")
                .font(.headline)

            SFKChipFlowLayout(spacing: 8) {
                ForEach(chips, id: \.self) { chip in
                    Button(action: { selected = chip }) {
                        Text(chip)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(selected == chip ? .white : .primary)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(
                                Capsule(style: .continuous)
                                    .fill(selected == chip ? Color.blue : Color(.secondarySystemBackground))
                            )
                            .overlay(
                                Capsule(style: .continuous)
                                    .stroke(selected == chip ? Color.blue : Color.gray.opacity(0.45), lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(24)
    }
}

#Preview("Long Chips") {
    SFKChipFlowLayout(spacing: 10) {
        Text("Short")
            .padding(12)
            .background(Capsule().fill(Color.blue.opacity(0.2)))
        Text("A significantly longer chip that tests wrapping behavior")
            .padding(12)
            .background(Capsule().fill(Color.green.opacity(0.2)))
        Text("Medium chip")
            .padding(12)
            .background(Capsule().fill(Color.orange.opacity(0.2)))
        Text("Another one")
            .padding(12)
            .background(Capsule().fill(Color.purple.opacity(0.2)))
    }
    .padding(24)
}
