/*****************************************************************************
 * _SFKButton.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2026 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import SwiftUI

@available(iOS 16, *)
public struct _SFKButton: View {

    @Environment(\.isEnabled) private var isEnabled
    private let hapticsHelper = HapticsHelper()

    private let title: String
    private let subtitle: String?
    private let icon: String?
    private let textAlignment: Alignment
    private let textColor: Color
    private let fillColor: Color
    private let borderColor: Color
    private let font: Font
    private let subtitleFont: Font
    private let cornerRadius: CGFloat
    private let isFullWidth: Bool
    private let isLoading: Bool
    private let hapticStyle: SFKButtonHapticStyle
    private let action: () -> Void

    public init(
        _ title: String,
        subtitle: String? = nil,
        icon: String? = nil,
        textAlignment: Alignment = .center,
        textColor: Color = .white,
        fillColor: Color = .accentColor,
        borderColor: Color = .clear,
        font: Font = .body.weight(.semibold),
        subtitleFont: Font = .caption,
        cornerRadius: CGFloat = 18,
        isFullWidth: Bool = true,
        isLoading: Bool = false,
        hapticStyle: SFKButtonHapticStyle = .medium,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.textAlignment = textAlignment
        self.textColor = textColor
        self.fillColor = fillColor
        self.borderColor = borderColor
        self.font = font
        self.subtitleFont = subtitleFont
        self.cornerRadius = cornerRadius
        self.isFullWidth = isFullWidth
        self.isLoading = isLoading
        self.hapticStyle = hapticStyle
        self.action = action
    }

    public var body: some View {
        if #available(iOS 26, *) {
            baseButton
                .buttonStyle(.glassProminent)
                .buttonBorderShape(.roundedRectangle(radius: cornerRadius))
                .tint(fillColor)
        } else {
            baseButton
                .buttonStyle(.plain)
                .background(fillColor, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(borderColor, lineWidth: 1)
                }
                .contentShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        }
    }

    // MARK: - Base Button

    private var baseButton: some View {
        Button {
            guard !isLoading else { return }
            triggerHapticIfNeeded()
            action()
        } label: {
            HStack(spacing: 10) {
                if let icon, !icon.isEmpty, !isLoading {
                    Image(systemName: icon)
                        .font(font)
                }

                if isLoading {
                    ProgressView()
                        .tint(textColor)
                } else {
                    content
                }
            }
            .frame(maxWidth: isFullWidth ? .infinity : nil, alignment: frameAlignment)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .foregroundStyle(textColor)
        }
        .disabled(isLoading)
        .animation(.easeInOut(duration: 0.2), value: isLoading)
        .animation(.easeInOut(duration: 0.2), value: isEnabled)
    }

    // MARK: - Content

    private var content: some View {
        VStack(alignment: resolvedHorizontalAlignment, spacing: subtitle == nil ? 0 : 2) {
            Text(title)
                .font(font)
                .lineLimit(2)

            if let subtitle, !subtitle.isEmpty {
                Text(subtitle)
                    .font(subtitleFont)
                    .foregroundStyle(textColor.opacity(0.82))
                    .lineLimit(2)
            }
        }
        .multilineTextAlignment(resolvedMultilineAlignment)
    }

    // MARK: - Alignment Helpers

    private var resolvedHorizontalAlignment: HorizontalAlignment {
        switch textAlignment {
        case .leading, .topLeading, .bottomLeading: .leading
        case .trailing, .topTrailing, .bottomTrailing: .trailing
        default: .center
        }
    }

    private var resolvedMultilineAlignment: TextAlignment {
        switch textAlignment {
        case .leading, .topLeading, .bottomLeading: .leading
        case .trailing, .topTrailing, .bottomTrailing: .trailing
        default: .center
        }
    }

    private var frameAlignment: Alignment {
        switch textAlignment {
        case .leading, .topLeading, .bottomLeading: .leading
        case .trailing, .topTrailing, .bottomTrailing: .trailing
        default: .center
        }
    }

    // MARK: - Haptics

    private func triggerHapticIfNeeded() {
        guard isEnabled, !isLoading else { return }
        switch hapticStyle {
        case .light: hapticsHelper.lightImpact()
        case .medium: hapticsHelper.mediumImpact()
        case .heavy: hapticsHelper.heavyImpact()
        }
    }
}

// MARK: - Previews

@available(iOS 26, *)
#Preview("Primary CTA") {

    VStack(spacing: 16) {
        _SFKButton(
            "Continue",
            subtitle: "Recommended next step",
            icon: "arrow.right",
            fillColor: .blue
        ) { }

        _SFKButton(
            "Upgrade to Pro",
            icon: "sparkles",
            fillColor: .orange
        ) { }
    }
    .padding(24)
}

@available(iOS 26, *)
#Preview("Alignment") {
    VStack(spacing: 16) {
        _SFKButton(
            "Leading aligned title",
            subtitle: "Designed for longer supporting copy",
            icon: "text.alignleft",
            textAlignment: .leading,
            fillColor: .green
        ) { }

        _SFKButton(
            "Trailing aligned title",
            subtitle: "Useful for utility-style treatments",
            icon: "text.alignright",
            textAlignment: .trailing,
            fillColor: .indigo
        ) { }
    }
    .padding(24)
}

@available(iOS 26, *)
#Preview("Compact") {
    HStack(spacing: 12) {
        _SFKButton(
            "Close",
            icon: "xmark",
            fillColor: Color(.quaternarySystemFill),
            cornerRadius: 12,
            isFullWidth: false
        ) { }

        _SFKButton(
            "Filters",
            icon: "slider.horizontal.3",
            fillColor: .primary,
            cornerRadius: 12,
            isFullWidth: false
        ) { }
    }
    .padding(24)
}

@available(iOS 26, *)
#Preview("Loading & Disabled") {
    VStack(spacing: 16) {
        _SFKButton(
            "Saving Changes",
            subtitle: "Syncing your latest edits",
            icon: "arrow.triangle.2.circlepath",
            fillColor: .blue,
            isLoading: true
        ) { }

        _SFKButton(
            "Disabled Action",
            subtitle: "Waiting for required input",
            icon: "lock.fill",
            fillColor: .red
        ) { }
        .disabled(true)
    }
    .padding(24)
}
