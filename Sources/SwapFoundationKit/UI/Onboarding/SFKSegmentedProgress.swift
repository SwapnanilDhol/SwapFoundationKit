//
//  SFKSegmentedProgress.swift
//  SwapFoundationKit
//
//  Created by Swapnanil Dhol on 4/30/26.
//

import SwiftUI

/// A segmented progress indicator similar to story indicators, rendering capsule-shaped
/// segments where completed steps are filled and remaining steps are dimmed.
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
///     height: 8
/// )
/// ```
public struct SFKSegmentedProgress: View {
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

    /// Creates a segmented progress indicator.
    /// - Parameters:
    ///   - currentStep: The index of the current step (0-based).
    ///   - totalSteps: The total number of steps.
    ///   - activeColor: Color for completed segments. Defaults to `.primary`.
    ///   - inactiveColor: Color for remaining segments. Defaults to `.gray.opacity(0.25)`.
    ///   - height: Height of each segment. Defaults to 6.
    ///   - spacing: Spacing between segments. Defaults to 6.
    public init(
        currentStep: Int,
        totalSteps: Int,
        activeColor: Color = .primary,
        inactiveColor: Color = .gray.opacity(0.25),
        height: CGFloat = 6,
        spacing: CGFloat = 6
    ) {
        self.currentStep = currentStep
        self.totalSteps = totalSteps
        self.activeColor = activeColor
        self.inactiveColor = inactiveColor
        self.height = height
        self.segmentSpacing = spacing
    }

    public var body: some View {
        HStack(spacing: segmentSpacing) {
            ForEach(0..<totalSteps, id: \.self) { index in
                Capsule(style: .continuous)
                    .fill(index <= currentStep ? activeColor : inactiveColor)
                    .frame(maxWidth: .infinity)
                    .frame(height: height)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: currentStep)
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
            height: 8
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
