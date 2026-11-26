/*****************************************************************************
 * SFKRemoteBannerCard.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2026 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import SwiftUI

/// A quiet, dismissible card for an ``SFKRemoteBanner``, sized to sit above a list.
///
/// The whole card is the tap target; a small chevron after the title is the
/// only hint. A banner whose action is `.none` is plain text. The host
/// performs the action and tells ``SFKRemoteBannerService`` about dismissal;
/// the card only reports taps.
///
/// ## Usage
/// ```swift
/// SFKRemoteBannerCard(
///     banner: banner,
///     onAction: { open(banner.action) },
///     onDismiss: { service.dismiss(banner) }
/// )
/// ```
public struct SFKRemoteBannerCard: View {
    @Environment(\.sfkTheme) private var theme

    private let banner: SFKRemoteBanner
    private let onAction: () -> Void
    private let onDismiss: () -> Void

    public init(
        banner: SFKRemoteBanner,
        onAction: @escaping () -> Void,
        onDismiss: @escaping () -> Void
    ) {
        self.banner = banner
        self.onAction = onAction
        self.onDismiss = onDismiss
    }

    public var body: some View {
        Group {
            if isTappable {
                Button(action: onAction) { card }
                    .buttonStyle(.plain)
                    .accessibilityLabel(Text(verbatim: spokenCopy))
                    .accessibilityIdentifier("remoteBanner.action")
            } else {
                card.accessibilityElement(children: .combine)
            }
        }
        .overlay(alignment: .topTrailing) {
            SFKCompactButton(type: .close, chrome: .corner, foreground: theme.colors.secondaryText.opacity(0.7), action: onDismiss)
                .padding(2)
                .accessibilityIdentifier("remoteBanner.dismiss")
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("remoteBanner.card")
    }

    private static let padding: CGFloat = 14
    private static let cornerRadius: CGFloat = 16

    private var isTappable: Bool { banner.action != .none }

    private var card: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: banner.symbolName ?? "megaphone.fill")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(tint)
                .frame(width: 36, height: 36)
                .background(tint.opacity(0.12), in: Circle())
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 2) {
                title
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(theme.colors.text)
                    .fixedSize(horizontal: false, vertical: true)

                if let message = banner.message, !message.isEmpty {
                    Text(message)
                        .font(.caption)
                        .foregroundStyle(theme.colors.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            // Keeps the copy clear of the close button in the corner.
            .padding(.trailing, 18)
        }
        .padding(Self.padding)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: Self.cornerRadius, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: Self.cornerRadius, style: .continuous)
                .stroke(Color.primary.opacity(0.06), lineWidth: 1)
        }
        .contentShape(RoundedRectangle(cornerRadius: Self.cornerRadius, style: .continuous))
    }

    /// The chevron rides the last line of the title so it wraps with the text.
    private var title: Text {
        guard isTappable else { return Text(verbatim: banner.title) }
        let chevron = Text(Image(systemName: "chevron.right"))
            .font(.caption2.weight(.semibold))
            .foregroundStyle(theme.colors.secondaryText)
        return Text("\(Text(verbatim: banner.title))\u{00A0}\(chevron)")
    }

    /// The title and message without the decorative chevron.
    private var spokenCopy: String {
        [banner.title, banner.message ?? ""].filter { !$0.isEmpty }.joined(separator: ", ")
    }

    private var tint: Color {
        banner.tintHex.flatMap { Color(hex: $0) } ?? theme.colors.accent
    }
}

#if DEBUG
#Preview {
    var banner = SFKRemoteBanner(
        id: "preview",
        title: "Black Friday: 50% off Pro",
        message: "Unlimited goals and Savings Plans, half price until Monday.",
        action: .paywall(plan: nil)
    )
    banner.symbolName = "tag.fill"
    banner.tintHex = "#FF3B30"
    return SFKRemoteBannerCard(banner: banner, onAction: {}, onDismiss: {})
        .padding()
}
#endif
