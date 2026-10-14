/****************************************************************************
 * SFKOnboardingStep.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2026 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import SwiftUI

/// One onboarding or wizard step: an optional hero, a headline, and the
/// step's own controls, laid out for whatever window it is in.
///
/// - **One column** (compact width): hero on top, headline and content below,
///   capped at ``SFKOnboardingLayout/contentWidth`` and centred. On a short
///   display the hero shrinks just enough for the copy to fit (down to 60%);
///   anything still taller scrolls under the footer.
/// - **Two panes** (`twoPaneSplit` set by ``SFKOnboardingWindow``): hero in
///   the leading pane, headline and content in the trailing one, so nothing
///   runs across the centre of the window (the fold on iPhone Duo). A step
///   without a hero shows the environment's brand mark in the leading pane
///   (see ``SwiftUI/View/sfkOnboardingBrandMark(_:)``).
/// - **Centred column** (`.centredColumn` mode): the one-column layout in a
///   readable column that steps off an active fold.
///
/// ## Usage
/// ```swift
/// SFKOnboardingStep(
///     eyebrow: "YOUR GOAL",
///     title: "What are you saving for?",
///     subtitle: "Pick everything that applies."
/// ) {
///     GoalHeroIllustration()
/// } content: {
///     ForEach(kinds) { kind in
///         SFKOnboardingSelectionCard(emoji: kind.emoji, title: kind.title, tint: kind.color,
///                                    isSelected: selection.contains(kind)) { toggle(kind) }
///     }
/// }
/// ```
public struct SFKOnboardingStep<Hero: View, Content: View>: View {
    private let eyebrow: String
    private let title: String
    private let subtitle: String
    private let heroToHeadlineSpacing: CGFloat?
    private let hero: Hero
    private let content: Content

    /// - Parameters:
    ///   - eyebrow: Short uppercase label above the title.
    ///   - title: The step's title.
    ///   - subtitle: One or two sentences under the title.
    ///   - heroToHeadlineSpacing: Fixed space between hero and headline in
    ///     one column. `nil` lets the headline settle towards the bottom of
    ///     the screen when there is room.
    ///   - hero: The step's illustration. Pass `EmptyView()` for none.
    ///   - content: The step's own controls, under the headline.
    public init(
        eyebrow: String,
        title: String,
        subtitle: String,
        heroToHeadlineSpacing: CGFloat? = nil,
        @ViewBuilder hero: () -> Hero,
        @ViewBuilder content: () -> Content
    ) {
        self.eyebrow = eyebrow
        self.title = title
        self.subtitle = subtitle
        self.heroToHeadlineSpacing = heroToHeadlineSpacing
        self.hero = hero()
        self.content = content()
    }

    @Environment(\.twoPaneSplit) private var twoPaneSplit
    @Environment(\.isOnboardingPaneColumn) private var isPaneColumn
    @Environment(\.onboardingWideWindowMode) private var wideWindowMode
    @Environment(\.onboardingBrandMark) private var brandMark
    @State private var heroNaturalHeight: CGFloat = 0
    @State private var copyHeight: CGFloat = 0

    /// Smallest the hero may shrink to on a short display.
    private let minimumHeroScale: CGFloat = 0.6

    public var body: some View {
        if let twoPaneSplit {
            twoPaneBody(split: twoPaneSplit)
        } else if let columnWidth = wideWindowMode.centredColumnWidth {
            singleColumnBody
                .sfkFoldAwareColumn(maxWidth: columnWidth)
        } else {
            singleColumnBody
        }
    }

    /// Hero in the leading pane, copy and controls in the trailing one, so
    /// nothing runs across the centre of a regular-width window (the fold on
    /// iPhone Duo's inner display).
    private func twoPaneBody(split: SFKTwoPaneSplit) -> some View {
        HStack(spacing: SFKTwoPaneSplit.gutter) {
            GeometryReader { proxy in
                ScrollView(.vertical, showsIndicators: false) {
                    leadingPaneHero
                        .frame(maxWidth: SFKTwoPaneSplit.maximumContentWidth)
                        .padding(.horizontal, SFKTwoPaneSplit.contentInset)
                        .frame(maxWidth: .infinity, minHeight: proxy.size.height)
                }
                .scrollBounceBehavior(.basedOnSize)
            }
            .frame(width: split.leadingWidth)

            GeometryReader { proxy in
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 22) {
                        SFKOnboardingStepHeadline(
                            eyebrow: eyebrow,
                            title: title,
                            subtitle: subtitle
                        )

                        content
                    }
                    .frame(maxWidth: SFKTwoPaneSplit.maximumContentWidth)
                    .padding(.horizontal, SFKTwoPaneSplit.contentInset)
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity, minHeight: proxy.size.height)
                }
                .scrollBounceBehavior(.basedOnSize)
                .scrollDismissesKeyboard(.interactively)
            }
            .frame(width: split.trailingWidth)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private var leadingPaneHero: some View {
        if Hero.self == EmptyView.self {
            brandMark
        } else {
            hero
        }
    }

    private var singleColumnBody: some View {
        GeometryReader { proxy in
            let heroScale = heroScale(availableHeight: proxy.size.height - 32)

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    hero
                        .fixedSize(horizontal: false, vertical: true)
                        .onGeometryChange(for: CGFloat.self) { $0.size.height } action: {
                            heroNaturalHeight = $0
                        }
                        .scaleEffect(heroScale, anchor: .top)
                        .frame(
                            height: heroNaturalHeight > 0 ? heroNaturalHeight * heroScale : nil,
                            alignment: .top
                        )

                    if let heroToHeadlineSpacing {
                        Color.clear
                            .frame(height: heroToHeadlineSpacing)
                            .accessibilityHidden(true)
                    } else if Hero.self != EmptyView.self {
                        // A step without a hero keeps its headline at the top
                        // instead of letting a spacer push it down the screen.
                        Spacer(minLength: 22)
                    }

                    VStack(spacing: 22) {
                        SFKOnboardingStepHeadline(
                            eyebrow: eyebrow,
                            title: title,
                            subtitle: subtitle
                        )

                        content
                    }
                    .onGeometryChange(for: CGFloat.self) { $0.size.height } action: {
                        copyHeight = $0
                    }
                }
                .frame(
                    maxWidth: isPaneColumn ? SFKTwoPaneSplit.maximumContentWidth : SFKOnboardingLayout.contentWidth,
                    minHeight: max(proxy.size.height - 32, 0),
                    alignment: .top
                )
                // Capped, then centred, so a step keeps its shape on an iPad in
                // landscape instead of stretching across the whole screen. In a
                // pane it uses the pane's own inset so it lines up with steps
                // that split themselves.
                .frame(maxWidth: .infinity)
                .padding(.horizontal, isPaneColumn ? SFKTwoPaneSplit.contentInset : 24)
                .padding(.top, 12)
                .padding(.bottom, 20)
            }
            .scrollBounceBehavior(.basedOnSize)
            .scrollClipDisabled()
            .scrollDismissesKeyboard(.interactively)
        }
    }

    /// On a short display (iPhone Duo's outer one is 678 pt tall) a tall hero
    /// pushed the headline under the footer. Shrink the hero just enough for
    /// the copy to fit, down to a floor; anything still taller scrolls. Where
    /// everything already fits this is 1 and nothing changes.
    private func heroScale(availableHeight: CGFloat) -> CGFloat {
        guard heroNaturalHeight > 0, copyHeight > 0 else { return 1 }
        let spacing = heroToHeadlineSpacing ?? 22
        let roomForHero = availableHeight - copyHeight - spacing
        return min(max(roomForHero / heroNaturalHeight, minimumHeroScale), 1)
    }
}

#Preview("One column") {
    SFKOnboardingStep(
        eyebrow: "YOUR GOAL",
        title: "What are you saving for?",
        subtitle: "Pick everything that applies."
    ) {
        Image(systemName: "airplane.departure")
            .font(.system(size: 120))
            .foregroundStyle(.tint)
            .padding(.top, 40)
    } content: {
        SFKOnboardingSelectionStatus(selectionCount: 1)
        SFKOnboardingSelectionCard(emoji: "✈️", title: "A trip", tint: .blue, isSelected: true) {}
        SFKOnboardingSelectionCard(emoji: "🏠", title: "A home", tint: .orange, isSelected: false) {}
    }
}

#Preview("Two panes, brand mark") {
    SFKOnboardingWindow { _ in
        SFKOnboardingStep(
            eyebrow: "REMINDERS",
            title: "Stay on track.",
            subtitle: "A nudge when it matters."
        ) {
            EmptyView()
        } content: {
            EmptyView()
        }
    }
    .sfkOnboardingBrandMark {
        SFKOnboardingBrandMark(image: Image(systemName: "star.fill"))
    }
}
