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

@available(iOS 26, *)
public enum SFKButtonStyle {
    case standard   // uses fillColor + custom background
    case glass      // uses .buttonStyle(.glass)
    case glassProminent // uses .buttonStyle(.glassProminent)
}

@available(iOS 26, *)
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
    private let style: SFKButtonStyle
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
        cornerRadius: CGFloat = 14,
        isFullWidth: Bool = true,
        isLoading: Bool = false,
        hapticStyle: SFKButtonHapticStyle = .medium,
        style: SFKButtonStyle = .standard,
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
        self.style = style
        self.action = action
    }

    public var body: some View {
        switch style {
        case .standard:
            standardButton
        case .glass:
            glassButton
                .buttonStyle(.glass)
        case .glassProminent:
            glassButton
                .buttonStyle(.glassProminent)
        }
    }

    // MARK: - Standard (custom background)

    private var standardButton: some View {
        baseButton
            .background(fillColor, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(borderColor, lineWidth: 1)
            }
            .contentShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .buttonStyle(.plain)
    }

    // MARK: - Glass (system renders the background)

    private var glassButton: some View {
        baseButton
            // No custom background — .buttonStyle(.glass/.glassProminent) owns the surface.
            // cornerRadius is expressed via buttonBorderShape instead.
            .buttonBorderShape(.roundedRectangle(radius: cornerRadius))
            .contentShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }

    // MARK: - Shared label

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
                        .tint(style == .standard ? textColor : nil)
                } else {
                    content
                }
            }
            .frame(maxWidth: isFullWidth ? .infinity : nil, alignment: frameAlignment)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .foregroundStyle(style == .standard ? textColor : .primary)
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
                    .foregroundStyle(
                        style == .standard
                            ? AnyShapeStyle(textColor.opacity(0.82))
                            : AnyShapeStyle(.secondary)
                    )
                    .lineLimit(2)
            }
        }
        .multilineTextAlignment(resolvedMultilineAlignment)
    }

    // MARK: - Alignment helpers

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
#Preview("Standard") {
    VStack(spacing: 16) {
        _SFKButton("Continue", icon: "arrow.right", fillColor: .blue) { }
        _SFKButton("Delete", fillColor: .red) { }
    }
    .padding(24)
}

@available(iOS 26, *)
#Preview("Glass") {
    ZStack {
        LinearGradient(colors: [.blue, .purple], startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea()

        VStack(spacing: 16) {
            _SFKButton("Filters", icon: "slider.horizontal.3", isFullWidth: false, style: .glass) { }
            _SFKButton("Save", icon: "square.and.arrow.down", style: .glassProminent) { }
        }
        .padding(24)
    }
}

@available(iOS 26, *)
#Preview("Loading") {
    VStack(spacing: 16) {
        _SFKButton("Saving...", fillColor: .blue, isLoading: true, style: .standard) { }
        _SFKButton("Saving...", isLoading: true, style: .glass) { }
    }
    .padding(24)
}
