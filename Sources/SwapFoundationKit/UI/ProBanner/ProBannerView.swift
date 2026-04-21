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

    public let isProEnabled: Bool
    public let proEnabledTitle: String
    public let proEnabledSubtitle: String
    public let proDisabledTitle: String
    public let proDisabledSubtitle: String
    public let upgradeButtonTitle: String
    public let upgradeButtonFillColor: Color
    public let onUpgradeTap: () -> Void

    public init(
        isProEnabled: Bool,
        proEnabledTitle: String,
        proEnabledSubtitle: String,
        proDisabledTitle: String,
        proDisabledSubtitle: String,
        upgradeButtonTitle: String = "Upgrade Now".localized,
        upgradeButtonFillColor: Color = .purple,
        onUpgradeTap: @escaping () -> Void
    ) {
        self.isProEnabled = isProEnabled
        self.proEnabledTitle = proEnabledTitle
        self.proEnabledSubtitle = proEnabledSubtitle
        self.proDisabledTitle = proDisabledTitle
        self.proDisabledSubtitle = proDisabledSubtitle
        self.upgradeButtonTitle = upgradeButtonTitle
        self.upgradeButtonFillColor = upgradeButtonFillColor
        self.onUpgradeTap = onUpgradeTap
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.title3)
                .fontWeight(.heavy)
                .accessibilityIdentifier("proBannerTitle")

            Text(subtitle)
                .font(.body)
                .foregroundStyle(.secondary)

            if !isProEnabled {
                SFKButton(
                    upgradeButtonTitle,
                    leadingIconName: "sparkles",
                    color: upgradeButtonFillColor,
                    action: onUpgradeTap
                )
                .padding(.vertical)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
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
