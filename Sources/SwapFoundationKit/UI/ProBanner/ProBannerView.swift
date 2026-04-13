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

    public let proEnabledTitle: String
    public let proEnabledSubtitle: String
    public let proDisabledTitle: String
    public let proDisabledSubtitle: String
    public let upgradeButtonTitle: String
    public let onUpgradeTap: () -> Void

    @AppStorage("isProEnabled") private var isProEnabled = false

    public init(
        proEnabledTitle: String,
        proEnabledSubtitle: String,
        proDisabledTitle: String,
        proDisabledSubtitle: String,
        upgradeButtonTitle: String = "Upgrade Now",
        onUpgradeTap: @escaping () -> Void
    ) {
        self.proEnabledTitle = proEnabledTitle
        self.proEnabledSubtitle = proEnabledSubtitle
        self.proDisabledTitle = proDisabledTitle
        self.proDisabledSubtitle = proDisabledSubtitle
        self.upgradeButtonTitle = upgradeButtonTitle
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
                SFKPrimaryButton(
                    title: upgradeButtonTitle,
                    tint: .purple,
                    action: onUpgradeTap
                )
                .frame(minHeight: 44)
                .padding(.top, 8)
            }
        }
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
        proEnabledTitle: "Thank you for upgrading!",
        proEnabledSubtitle: "Your support means the world!",
        proDisabledTitle: "Upgrade to Pro!",
        proDisabledSubtitle: "Unlock all premium features."
    ) {
        print("Upgrade tapped")
    }
}

#Preview("Pro Disabled") {
    SFKProBannerView(
        proEnabledTitle: "Thank you for upgrading!",
        proEnabledSubtitle: "Your support means the world!",
        proDisabledTitle: "Upgrade to Pro!",
        proDisabledSubtitle: "Unlock all premium features."
    ) {
        print("Upgrade tapped")
    }
}
#endif
