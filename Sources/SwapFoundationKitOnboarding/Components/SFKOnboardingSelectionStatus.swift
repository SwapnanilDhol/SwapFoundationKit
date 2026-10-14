/****************************************************************************
 * SFKOnboardingSelectionStatus.swift
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

/// The small caps line above a list of ``SFKOnboardingSelectionCard``s: how
/// to answer on the leading side, how many are selected (or whether an answer
/// is required) on the trailing side.
///
/// Labels are looked up in the host app's string catalogue, so localise
/// "SELECT ALL THAT APPLY", "SELECT ONE", "REQUIRED", "OPTIONAL" and
/// "SELECTED" there, or pass your own.
///
/// ## Usage
/// ```swift
/// SFKOnboardingSelectionStatus(selectionCount: selection.count, isRequired: true)
/// ```
public struct SFKOnboardingSelectionStatus: View {
    @Environment(\.sfkTheme) private var theme

    private let selectionCount: Int
    private let allowsMultiple: Bool
    private let isRequired: Bool

    /// - Parameters:
    ///   - selectionCount: How many options are selected.
    ///   - allowsMultiple: Whether more than one option may be selected.
    ///   - isRequired: Whether the step needs an answer to continue.
    public init(selectionCount: Int, allowsMultiple: Bool = true, isRequired: Bool = false) {
        self.selectionCount = selectionCount
        self.allowsMultiple = allowsMultiple
        self.isRequired = isRequired
    }

    public var body: some View {
        HStack(spacing: 7) {
            Image(systemName: "hand.tap.fill")
            Text(allowsMultiple ? "SELECT ALL THAT APPLY" : "SELECT ONE")
            Spacer()
            Text(status)
                .foregroundStyle(selectionCount == 0 ? theme.colors.secondaryText : theme.colors.accent)
        }
        .font(.system(size: 11, weight: .bold, design: .rounded))
        .tracking(1.2)
        .foregroundStyle(theme.colors.secondaryText)
        .padding(.horizontal, 4)
        .accessibilityHidden(true)
    }

    private var status: LocalizedStringKey {
        guard selectionCount > 0 else { return isRequired ? "REQUIRED" : "OPTIONAL" }
        return allowsMultiple ? "\(selectionCount) SELECTED" : "SELECTED"
    }
}

#Preview {
    VStack(spacing: 20) {
        SFKOnboardingSelectionStatus(selectionCount: 0, isRequired: true)
        SFKOnboardingSelectionStatus(selectionCount: 2)
        SFKOnboardingSelectionStatus(selectionCount: 1, allowsMultiple: false)
    }
    .padding()
}
