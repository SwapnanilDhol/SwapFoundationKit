/****************************************************************************
 * SFKOnboardingFooter.swift
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

/// The standard onboarding footer: an optional back or secondary action
/// beside a full-width primary action, on ``SFKOnboardingFooterContainer``.
///
/// The secondary action slides in and out as it appears and disappears (a
/// back button that only exists after the first step).
///
/// ## Usage
/// ```swift
/// .safeAreaInset(edge: .bottom, spacing: 0) {
///     SFKOnboardingFooter(
///         primaryTitle: "Continue",
///         isPrimaryEnabled: isValid,
///         secondaryTitle: canGoBack ? "Back" : nil,
///         secondaryLeadingIconName: "chevron.left",
///         secondaryIsCircular: true,
///         secondaryAction: canGoBack ? goBack : nil,
///         primaryAction: advance
///     )
/// }
/// ```
public struct SFKOnboardingFooter: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let primaryTitle: String
    private let isPrimaryEnabled: Bool
    private let isLoading: Bool
    private let loadingAccessibilityLabel: String?
    private let accessibilityIdentifier: String
    private let bottomSafeAreaInset: CGFloat
    private let appearance: SFKFooterAppearance
    private let secondaryTitle: String?
    private let secondaryLeadingIconName: String?
    private let secondaryIsCircular: Bool
    private let secondaryAccessibilityIdentifier: String
    private let secondaryAction: (() -> Void)?
    private let primaryAction: () -> Void

    /// - Parameters:
    ///   - primaryTitle: The primary button's title.
    ///   - isPrimaryEnabled: Dims the primary button when `false`.
    ///   - isLoading: Shows a spinner on the primary button.
    ///   - loadingAccessibilityLabel: What VoiceOver reads while loading.
    ///   - accessibilityIdentifier: The primary button's UI-test identifier.
    ///   - bottomSafeAreaInset: The inset a full-bleed screen ignored.
    ///   - appearance: The footer surface.
    ///   - secondaryTitle: The secondary action's title (its accessibility
    ///     label when circular). The action shows only when this and
    ///     `secondaryAction` are both set.
    ///   - secondaryLeadingIconName: SF Symbol for the secondary action.
    ///   - secondaryIsCircular: Draws the secondary action as a glass circle
    ///     holding only its symbol (a back button).
    ///   - secondaryAccessibilityIdentifier: The secondary action's UI-test identifier.
    ///   - secondaryAction: Runs when the secondary action is tapped.
    ///   - primaryAction: Runs when the primary button is tapped.
    public init(
        primaryTitle: String,
        isPrimaryEnabled: Bool = true,
        isLoading: Bool = false,
        loadingAccessibilityLabel: String? = nil,
        accessibilityIdentifier: String = "onboarding.primary_button",
        bottomSafeAreaInset: CGFloat = 0,
        appearance: SFKFooterAppearance = .material,
        secondaryTitle: String? = nil,
        secondaryLeadingIconName: String? = nil,
        secondaryIsCircular: Bool = false,
        secondaryAccessibilityIdentifier: String = "onboarding.secondary_button",
        secondaryAction: (() -> Void)? = nil,
        primaryAction: @escaping () -> Void
    ) {
        self.primaryTitle = primaryTitle
        self.isPrimaryEnabled = isPrimaryEnabled
        self.isLoading = isLoading
        self.loadingAccessibilityLabel = loadingAccessibilityLabel
        self.accessibilityIdentifier = accessibilityIdentifier
        self.bottomSafeAreaInset = bottomSafeAreaInset
        self.appearance = appearance
        self.secondaryTitle = secondaryTitle
        self.secondaryLeadingIconName = secondaryLeadingIconName
        self.secondaryIsCircular = secondaryIsCircular
        self.secondaryAccessibilityIdentifier = secondaryAccessibilityIdentifier
        self.secondaryAction = secondaryAction
        self.primaryAction = primaryAction
    }

    public var body: some View {
        SFKOnboardingFooterContainer(
            bottomSafeAreaInset: bottomSafeAreaInset,
            appearance: appearance
        ) {
            HStack(spacing: 12) {
                if let secondaryTitle, let secondaryAction {
                    if secondaryIsCircular {
                        // A glass circle with the symbol in the label colour. An
                        // `SFKButton` tinted clear resolved its icon to white and
                        // vanished on a light footer.
                        SFKCompactButton(
                            systemImage: secondaryLeadingIconName ?? "chevron.left",
                            accessibilityLabel: LocalizedStringKey(secondaryTitle),
                            chrome: .glass,
                            action: secondaryAction
                        )
                        .frame(width: 52, height: 52)
                        .accessibilityIdentifier(secondaryAccessibilityIdentifier)
                        .transition(secondaryButtonTransition)
                    } else {
                        SFKButton(secondaryTitle, role: .secondary, action: secondaryAction)
                            .sfkIcon(secondaryLeadingIconName)
                            .sfkFullWidth(false)
                            .sfkTint(.clear)
                            .fixedSize()
                            .accessibilityLabel(secondaryTitle)
                            .accessibilityIdentifier(secondaryAccessibilityIdentifier)
                            .transition(secondaryButtonTransition)
                    }
                }

                SFKOnboardingPrimaryButton(
                    title: primaryTitle,
                    isEnabled: isPrimaryEnabled,
                    isLoading: isLoading,
                    loadingAccessibilityLabel: loadingAccessibilityLabel,
                    accessibilityIdentifier: accessibilityIdentifier,
                    action: primaryAction
                )
                .layoutPriority(1)
            }
        }
        .animation(footerAnimation, value: showsSecondaryButton)
    }

    private var showsSecondaryButton: Bool {
        secondaryTitle != nil && secondaryAction != nil
    }

    private var secondaryButtonTransition: AnyTransition {
        guard !reduceMotion else { return .opacity }
        return .asymmetric(
            insertion: .offset(x: -24)
                .combined(with: .scale(scale: 0.86, anchor: .leading))
                .combined(with: .opacity),
            removal: .offset(x: -24)
                .combined(with: .scale(scale: 0.86, anchor: .leading))
                .combined(with: .opacity)
        )
    }

    private var footerAnimation: Animation {
        reduceMotion
            ? .easeOut(duration: 0.18)
            : .spring(response: 0.38, dampingFraction: 0.90, blendDuration: 0.06)
    }
}

#Preview("Primary only") {
    Color(.systemBackground)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            SFKOnboardingFooter(primaryTitle: "Get Started") {}
        }
}

#Preview("With back") {
    Color(.systemBackground)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            SFKOnboardingFooter(
                primaryTitle: "Continue",
                secondaryTitle: "Back",
                secondaryLeadingIconName: "chevron.left",
                secondaryIsCircular: true,
                secondaryAction: {},
                primaryAction: {}
            )
        }
}
