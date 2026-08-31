//
//  ProBannerView.swift
//  SwapFoundationKit
//
//  Created by Swapnanil Dhol on 4/13/26.
//

import SwiftUI

/// A reusable Pro upgrade banner component.
///
/// Displays different content based on pro status:
/// - When pro is enabled: Shows thank you message
/// - When pro is disabled: Shows upgrade prompt with CTA button
///
/// ## Usage
/// ```swift
/// ProBannerView(
///     proEnabledTitle: "Thank you for upgrading!",
///     proEnabledSubtitle: "Your support means the world!",
///     proDisabledTitle: "Upgrade to Pro!",
///     proDisabledSubtitle: "Unlock all premium features.",
///     onUpgradeTap: {
///         // Present paywall
///     }
/// )
/// ```
public struct SFKProBannerView: View {
    @Environment(\.sfkTheme) private var theme

    public let isProEnabled: Bool
    public let proEnabledTitle: String
    public let proEnabledSubtitle: String
    public let proDisabledTitle: String
    public let proDisabledSubtitle: String
    public let upgradeButtonTitle: String
    public let upgradeButtonFillColor: Color
    public let onUpgradeTap: () -> Void
    private let usesThemeUpgradeButtonColor: Bool

    public init(
        isProEnabled: Bool,
        proEnabledTitle: String,
        proEnabledSubtitle: String,
        proDisabledTitle: String,
        proDisabledSubtitle: String,
        upgradeButtonTitle: String = "Upgrade Now".localized,
        upgradeButtonFillColor: Color? = nil,
        onUpgradeTap: @escaping () -> Void
    ) {
        self.isProEnabled = isProEnabled
        self.proEnabledTitle = proEnabledTitle
        self.proEnabledSubtitle = proEnabledSubtitle
        self.proDisabledTitle = proDisabledTitle
        self.proDisabledSubtitle = proDisabledSubtitle
        self.upgradeButtonTitle = upgradeButtonTitle
        self.upgradeButtonFillColor = upgradeButtonFillColor ?? .purple
        self.usesThemeUpgradeButtonColor = upgradeButtonFillColor == nil
        self.onUpgradeTap = onUpgradeTap
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.inline) {
            Text(title)
                .font(theme.typography.title.weight(.bold))
                .foregroundStyle(theme.colors.text)
                .accessibilityIdentifier("proBannerTitle")

            Text(subtitle)
                .font(theme.typography.body)
                .foregroundStyle(theme.colors.secondaryText)

            if !isProEnabled {
                SFKButton(upgradeButtonTitle, role: .primary, action: onUpgradeTap)
                    .sfkIcon("sparkles")
                    .sfkTint(usesThemeUpgradeButtonColor ? nil : upgradeButtonFillColor)
                    .padding(.vertical, theme.spacing.inline)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, theme.spacing.inline)
        .accessibilityIdentifier("proBannerView")
    }

    private var title: String {
        isProEnabled ? proEnabledTitle : proDisabledTitle
    }

    private var subtitle: String {
        isProEnabled ? proEnabledSubtitle : proDisabledSubtitle
    }
}

#if DEBUG
#Preview("Pro Enabled") {
    SFKProBannerView(
        isProEnabled: true,
        proEnabledTitle: "Thank you for upgrading!",
        proEnabledSubtitle: "Your support means the world!",
        proDisabledTitle: "Upgrade to Pro!",
        proDisabledSubtitle: "Unlock all premium features."
    ) {
        print("Upgrade tapped")
    }
    .preferredColorScheme(.dark)
}

#Preview("Pro Disabled") {
    SFKProBannerView(
        isProEnabled: false,
        proEnabledTitle: "Thank you for upgrading!",
        proEnabledSubtitle: "Your support means the world!",
        proDisabledTitle: "Upgrade to Pro!",
        proDisabledSubtitle: "Unlock all premium features.",
        upgradeButtonFillColor: .orange
    ) {
        print("Upgrade tapped")
    }
    .preferredColorScheme(.dark)
}
#endif
