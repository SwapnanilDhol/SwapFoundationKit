/****************************************************************************
 * SFKOnboardingWindow.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2026 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import SwiftUI

/// The root of a full-screen onboarding or wizard flow: measures the window,
/// decides between one column and two panes, and publishes the result to every
/// ``SFKOnboardingStep`` and ``SFKOnboardingFooterContainer`` inside it.
///
/// The split is re-resolved on every size change, so opening iPhone Duo
/// mid-flow re-lays the current step out in two panes without resetting it,
/// and folding it lays the step back out as one column.
///
/// ## Usage
/// ```swift
/// SFKOnboardingWindow { context in
///     VStack(spacing: 0) {
///         SFKSegmentedProgress(currentStep: index, totalSteps: count, width: 128)
///             .frame(width: context.split?.trailingWidth)
///             .frame(maxWidth: .infinity, alignment: context.split == nil ? .center : .trailing)
///         currentStepView
///     }
///     .safeAreaInset(edge: .bottom, spacing: 0) {
///         SFKOnboardingFooter(primaryTitle: "Continue", primaryAction: advance)
///     }
/// }
/// .sfkOnboardingBrandMark { SFKOnboardingBrandMark(image: Image("Logo")) }
/// ```
public struct SFKOnboardingWindow<Content: View>: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    private let mode: SFKOnboardingWideWindowMode
    private let content: (SFKOnboardingWindowContext) -> Content

    /// - Parameters:
    ///   - mode: How a wide window is used. Defaults to `.twoPane`.
    ///   - content: The flow, given the measured window.
    public init(
        mode: SFKOnboardingWideWindowMode = .twoPane,
        @ViewBuilder content: @escaping (SFKOnboardingWindowContext) -> Content
    ) {
        self.mode = mode
        self.content = content
    }

    public var body: some View {
        GeometryReader { proxy in
            let split = mode == .twoPane
                ? SFKTwoPaneSplit.resolve(
                    sizeClass: horizontalSizeClass,
                    size: proxy.size,
                    safeAreaInsets: proxy.safeAreaInsets
                )
                : nil

            content(
                SFKOnboardingWindowContext(
                    split: split,
                    size: proxy.size,
                    safeAreaInsets: proxy.safeAreaInsets
                )
            )
            .environment(\.twoPaneSplit, split)
            .environment(\.onboardingWideWindowMode, mode)
        }
    }
}

#Preview("Two panes") {
    SFKOnboardingWindow { context in
        SFKOnboardingStep(
            eyebrow: "STEP ONE",
            title: "Plan the trip.",
            subtitle: context.split == nil ? "One column." : "Hero leading, copy trailing."
        ) {
            Image(systemName: "airplane")
                .font(.system(size: 96))
                .foregroundStyle(.tint)
        } content: {
            EmptyView()
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            SFKOnboardingFooter(primaryTitle: "Continue") {}
        }
    }
}

#Preview("Centred column") {
    SFKOnboardingWindow(mode: .centredColumn()) { _ in
        SFKOnboardingStep(
            eyebrow: "STEP ONE",
            title: "Plan the trip.",
            subtitle: "A readable column that steps off the fold."
        ) {
            EmptyView()
        } content: {
            EmptyView()
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            SFKOnboardingFooter(primaryTitle: "Continue") {}
        }
    }
}
