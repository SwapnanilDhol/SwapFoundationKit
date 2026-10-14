/****************************************************************************
 * SFKOnboardingStepHeadline.swift
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

/// Eyebrow, title and subtitle at the top of an onboarding step's copy.
///
/// Colours come from ``SFKTheme``: the eyebrow uses the accent, the title the
/// text colour and the subtitle the secondary text colour.
///
/// ## Usage
/// ```swift
/// SFKOnboardingStepHeadline(
///     eyebrow: "YOUR GOAL",
///     title: "What are you saving for?",
///     subtitle: "Pick everything that applies."
/// )
/// ```
public struct SFKOnboardingStepHeadline: View {
    @Environment(\.sfkTheme) private var theme

    private let eyebrow: String
    private let title: String
    private let subtitle: String

    public init(eyebrow: String, title: String, subtitle: String) {
        self.eyebrow = eyebrow
        self.title = title
        self.subtitle = subtitle
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 13) {
            Text(eyebrow)
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .tracking(1.6)
                .foregroundStyle(theme.colors.accent)

            Text(title)
                .font(.system(size: 37, weight: .bold, design: .rounded))
                .tracking(-1.2)
                .foregroundStyle(theme.colors.text)
                .minimumScaleFactor(0.78)
                .fixedSize(horizontal: false, vertical: true)

            Text(subtitle)
                .font(.system(size: 17, weight: .medium, design: .rounded))
                .foregroundStyle(theme.colors.secondaryText)
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    SFKOnboardingStepHeadline(
        eyebrow: "YOUR GOAL",
        title: "What are you saving for?",
        subtitle: "Pick everything that applies. You can change it later."
    )
    .padding(24)
    .sfkTheme(.system.accent(.green))
}
