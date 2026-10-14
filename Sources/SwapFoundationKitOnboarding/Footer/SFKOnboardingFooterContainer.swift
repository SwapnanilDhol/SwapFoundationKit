/****************************************************************************
 * SFKOnboardingFooterContainer.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2026 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import SwapFoundationKit
import SwiftUI

/// Places an onboarding step's actions on SwapFoundationKit's shared
/// ``AppFooterView`` surface, lined up with the step's copy.
///
/// The surface, insets and safe-area handling come from `AppFooterView`, and
/// its band spans the window. The actions follow the layout the enclosing
/// ``SFKOnboardingWindow`` chose:
/// - one column: capped at ``SFKOnboardingLayout/contentWidth`` and centred;
/// - two panes: over the trailing pane with the copy they act on, so no
///   button runs through the fold;
/// - a pane column (`isOnboardingPaneColumn`): the pane's width cap and inset;
/// - centred column: inside the same fold-aware column as the step.
///
/// ## Usage
/// ```swift
/// .safeAreaInset(edge: .bottom, spacing: 0) {
///     SFKOnboardingFooterContainer {
///         VStack(spacing: 2) {
///             SFKOnboardingPrimaryButton(title: "Unlock Pro", action: purchase)
///             Button("Continue with Free", action: skip)
///         }
///     }
/// }
/// ```
public struct SFKOnboardingFooterContainer<Content: View>: View {
    private let bottomSafeAreaInset: CGFloat
    private let appearance: SFKFooterAppearance
    private let content: Content

    /// - Parameters:
    ///   - bottomSafeAreaInset: The inset a full-bleed screen ignored, added
    ///     back under the actions.
    ///   - appearance: The shared footer's surface. `.clear` suits screens
    ///     whose footer sits over a static layout rather than scrolling content.
    ///   - content: The actions.
    public init(
        bottomSafeAreaInset: CGFloat = 0,
        appearance: SFKFooterAppearance = .material,
        @ViewBuilder content: () -> Content
    ) {
        self.bottomSafeAreaInset = bottomSafeAreaInset
        self.appearance = appearance
        self.content = content()
    }

    @Environment(\.twoPaneSplit) private var twoPaneSplit
    @Environment(\.isOnboardingPaneColumn) private var isPaneColumn
    @Environment(\.onboardingWideWindowMode) private var wideWindowMode

    public var body: some View {
        AppFooterView(appearance: appearance) {
            if let twoPaneSplit {
                // The shared footer already insets its content by 16 on each
                // side, so the trailing pane is 16 narrower here; the paddings
                // bring the actions to the pane content's 20 pt inset.
                HStack(spacing: 0) {
                    Spacer(minLength: 0)
                    actions(
                        maxContentWidth: SFKTwoPaneSplit.maximumContentWidth,
                        leadingPadding: 20,
                        trailingPadding: 4
                    )
                    .frame(width: max(twoPaneSplit.trailingWidth - 16, 0))
                }
            } else if isPaneColumn {
                actions(maxContentWidth: SFKTwoPaneSplit.maximumContentWidth, leadingPadding: 4, trailingPadding: 4)
            } else if let columnWidth = wideWindowMode.centredColumnWidth {
                actions(maxContentWidth: columnWidth, leadingPadding: 8, trailingPadding: 8)
                    .sfkFoldAwareColumn(maxWidth: columnWidth)
            } else {
                actions(maxContentWidth: SFKOnboardingLayout.contentWidth, leadingPadding: 8, trailingPadding: 8)
            }
        }
    }

    private func actions(
        maxContentWidth: CGFloat,
        leadingPadding: CGFloat,
        trailingPadding: CGFloat
    ) -> some View {
        content
            .frame(maxWidth: maxContentWidth)
            .frame(maxWidth: .infinity)
            .padding(.leading, leadingPadding)
            .padding(.trailing, trailingPadding)
            .padding(.bottom, bottomSafeAreaInset)
    }
}

#Preview {
    Color(.systemBackground)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            SFKOnboardingFooterContainer {
                VStack(spacing: 2) {
                    SFKOnboardingPrimaryButton(title: "Unlock Pro") {}
                    Button("Continue with Free") {}
                        .frame(maxWidth: .infinity, minHeight: 44)
                }
            }
        }
}
