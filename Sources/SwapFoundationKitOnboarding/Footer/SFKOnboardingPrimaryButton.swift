/****************************************************************************
 * SFKOnboardingPrimaryButton.swift
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

/// The full-width primary action of an onboarding step: an ``SFKButton`` in
/// the theme's primary tint that dims while disabled and shows a spinner while
/// loading.
///
/// ## Usage
/// ```swift
/// SFKOnboardingPrimaryButton(
///     title: "Unlock Pro",
///     isEnabled: canPurchase,
///     isLoading: isPurchasing,
///     loadingAccessibilityLabel: "Unlocking Pro",
///     action: purchase
/// )
/// ```
public struct SFKOnboardingPrimaryButton: View {
    private let title: String
    private let isEnabled: Bool
    private let isLoading: Bool
    private let loadingAccessibilityLabel: String?
    private let accessibilityIdentifier: String
    private let action: () -> Void

    /// - Parameters:
    ///   - title: The button title.
    ///   - isEnabled: Dims the button and ignores taps when `false`.
    ///   - isLoading: Shows a spinner and ignores taps.
    ///   - loadingAccessibilityLabel: What VoiceOver reads while loading.
    ///     Defaults to the title.
    ///   - accessibilityIdentifier: UI-test identifier.
    ///   - action: Runs on tap.
    public init(
        title: String,
        isEnabled: Bool = true,
        isLoading: Bool = false,
        loadingAccessibilityLabel: String? = nil,
        accessibilityIdentifier: String = "onboarding.primary_button",
        action: @escaping () -> Void
    ) {
        self.title = title
        self.isEnabled = isEnabled
        self.isLoading = isLoading
        self.loadingAccessibilityLabel = loadingAccessibilityLabel
        self.accessibilityIdentifier = accessibilityIdentifier
        self.action = action
    }

    public var body: some View {
        SFKButton(
            title,
            role: .primary,
            action: action
        )
        .sfkTint(.primary)
        .sfkLoading(isLoading)
        .disabled(!isEnabled || isLoading)
        .opacity(isEnabled ? 1 : 0.68)
        .accessibilityLabel(isLoading ? (loadingAccessibilityLabel ?? title) : title)
        .accessibilityIdentifier(accessibilityIdentifier)
    }
}

#Preview {
    VStack(spacing: 16) {
        SFKOnboardingPrimaryButton(title: "Continue") {}
        SFKOnboardingPrimaryButton(title: "Continue", isEnabled: false) {}
        SFKOnboardingPrimaryButton(title: "Continue", isLoading: true) {}
    }
    .padding()
}
