/****************************************************************************
 * SFKSegmentedProgress.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2026 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import SwiftUI

/// A compact segmented step indicator for short, guided flows.
///
/// ## Usage
/// ```swift
/// SFKSegmentedProgress(currentStep: 2, totalSteps: 5)
///
/// // Custom colors and height
/// SFKSegmentedProgress(
///     currentStep: 1,
///     totalSteps: 4,
///     activeColor: .blue,
///     inactiveColor: .gray.opacity(0.2),
///     currentSegmentWidthMultiplier: 1.75,
///     width: 160
/// )
/// ```
public struct SFKSegmentedProgress: View {
    @Environment(\.accessibilityReduceMotion) private var accessibilityReduceMotion

    /// The index of the current step (0-based).
    public let currentStep: Int

    /// The total number of steps.
    public let totalSteps: Int

    /// The color used for completed/active segments.
    public var activeColor: Color

    /// The color used for remaining/inactive segments.
    public var inactiveColor: Color

    /// The height of each segment.
    public var height: CGFloat

    /// The spacing between segments.
    public var segmentSpacing: CGFloat

    /// The current segment's width relative to every other segment.
    public var currentSegmentWidthMultiplier: CGFloat

    /// The total width of the indicator. Pass `nil` to fill the proposed width.
    public var width: CGFloat?

    /// Creates a segmented progress indicator.
    /// - Parameters:
    ///   - currentStep: The index of the current step (0-based).
    ///   - totalSteps: The total number of steps.
    ///   - activeColor: Color for completed segments. Defaults to `.accentColor`.
    ///   - inactiveColor: Color for remaining segments. Defaults to a subtle secondary tint.
    ///   - height: Height of each segment. Defaults to 4.
    ///   - spacing: Spacing between segments. Defaults to 5.
    ///   - currentSegmentWidthMultiplier: Current segment width relative to the other segments. Defaults to 1.75.
    ///   - width: Total width of the compact indicator. Defaults to 128.
    public init(
        currentStep: Int,
        totalSteps: Int,
        activeColor: Color = .accentColor,
        inactiveColor: Color = .secondary.opacity(0.18),
        height: CGFloat = 4,
        spacing: CGFloat = 5,
        currentSegmentWidthMultiplier: CGFloat = 1.75,
        width: CGFloat? = 128
    ) {
        self.currentStep = currentStep
        self.totalSteps = totalSteps
        self.activeColor = activeColor
        self.inactiveColor = inactiveColor
        self.height = height
        self.segmentSpacing = spacing
        self.currentSegmentWidthMultiplier = max(currentSegmentWidthMultiplier, 1)
        self.width = width
    }

    public var body: some View {
        GeometryReader { proxy in
            HStack(spacing: segmentSpacing) {
                ForEach(0..<safeTotalSteps, id: \.self) { index in
                    Capsule(style: .continuous)
                        .fill(index <= safeCurrentStep ? activeColor : inactiveColor)
                        .frame(width: segmentWidth(in: proxy.size.width, at: index))
                        .frame(height: height)
                }
            }
        }
        .frame(width: width, height: height)
        .animation(progressAnimation, value: safeCurrentStep)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Progress")
        .accessibilityValue("Step \(safeCurrentStep + 1) of \(safeTotalSteps)")
    }

    private var safeTotalSteps: Int {
        max(totalSteps, 1)
    }

    private var safeCurrentStep: Int {
        min(max(currentStep, 0), safeTotalSteps - 1)
    }

    private func segmentWidth(in availableWidth: CGFloat, at index: Int) -> CGFloat {
        let totalSpacing = segmentSpacing * CGFloat(max(safeTotalSteps - 1, 0))
        let segmentUnits = CGFloat(max(safeTotalSteps - 1, 0)) + currentSegmentWidthMultiplier
        let unitWidth = max(availableWidth - totalSpacing, 0) / segmentUnits
        return unitWidth * (index == safeCurrentStep ? currentSegmentWidthMultiplier : 1)
    }

    private var progressAnimation: Animation {
        accessibilityReduceMotion
            ? .easeOut(duration: 0.15)
            : .spring(response: 0.3, dampingFraction: 1)
    }
}

#Preview("SFKSegmentedProgress") {
    @Previewable @State var step = 0
    let totalSteps = 5

    VStack(spacing: 24) {
        Text("Step \(step + 1) of \(totalSteps)")
            .font(.headline)

        SFKSegmentedProgress(currentStep: step, totalSteps: totalSteps)

        HStack(spacing: 16) {
            Button("Previous") {
                step = max(0, step - 1)
            }
            .disabled(step == 0)

            Button("Next") {
                step = min(totalSteps - 1, step + 1)
            }
            .disabled(step == totalSteps - 1)
        }
    }
    .padding(24)
}

#Preview("Custom Colors") {
    VStack(spacing: 16) {
        SFKSegmentedProgress(
            currentStep: 2,
            totalSteps: 6,
            activeColor: .blue,
            inactiveColor: .blue.opacity(0.15),
            currentSegmentWidthMultiplier: 1.75,
            width: 180
        )

        SFKSegmentedProgress(
            currentStep: 1,
            totalSteps: 3,
            activeColor: .green,
            inactiveColor: .green.opacity(0.2),
            height: 4,
            spacing: 10
        )
    }
    .padding(24)
}
