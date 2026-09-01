/****************************************************************************
 * SFKCompactButton.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2026 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import SwiftUI

/// Semantic meaning for a compact button with platform-independent visuals.
public enum SFKCompactButtonType: Sendable {
    /// An action that dismisses or closes the current surface.
    case close
}

/// Visual treatment for an ``SFKCompactButton``.
public enum SFKCompactButtonChrome: Sendable {
    /// A control placed in a system toolbar or navigation bar.
    ///
    /// This leaves sizing and the surrounding surface to the toolbar.
    case toolbar

    /// A self-contained glass control over content.
    ///
    /// Icon-only content uses a circular surface. Text and icon/text content
    /// use a capsule that grows with the visible title.
    case glass
}

/// A lightweight button for toolbar actions and compact controls over content.
///
/// Use ``SFKButton`` for semantic primary/secondary actions, loading states,
/// haptics, and full-width presentation. Use this component when the action is
/// represented by a small icon or a short label in navigation chrome, an
/// overlay, or another compact surface.
public struct SFKCompactButton: View {
    @Environment(\.sfkTheme) private var theme

    private let title: String?
    private let systemImage: String?
    private let accessibilityLabel: LocalizedStringKey?
    private let chrome: SFKCompactButtonChrome
    private let foreground: Color?
    private let action: () -> Void

    /// Creates a compact button for a semantic action.
    ///
    /// The close type uses the standard X symbol and exposes "Close" as its
    /// accessibility label. Semantic types keep intent explicit while all
    /// compact buttons share one rendering and sizing implementation.
    public init(
        type: SFKCompactButtonType,
        chrome: SFKCompactButtonChrome = .glass,
        foreground: Color? = nil,
        action: @escaping () -> Void
    ) {
        switch type {
        case .close:
            self.title = nil
            self.systemImage = "xmark"
            self.accessibilityLabel = "Close"
        }
        self.chrome = chrome
        self.foreground = foreground
        self.action = action
    }

    /// Creates an icon-only compact button.
    ///
    /// Both the symbol and its accessible name are required so a generic
    /// compact action never silently becomes a close button.
    public init(
        systemImage: String,
        accessibilityLabel: LocalizedStringKey,
        chrome: SFKCompactButtonChrome = .glass,
        foreground: Color? = nil,
        action: @escaping () -> Void
    ) {
        self.title = nil
        self.systemImage = systemImage
        self.accessibilityLabel = accessibilityLabel
        self.chrome = chrome
        self.foreground = foreground
        self.action = action
    }

    /// Creates a text-only or icon-and-text compact button.
    public init(
        _ title: String,
        systemImage: String? = nil,
        chrome: SFKCompactButtonChrome = .glass,
        foreground: Color? = nil,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.systemImage = systemImage
        self.accessibilityLabel = nil
        self.chrome = chrome
        self.foreground = foreground
        self.action = action
    }

    public var body: some View {
        let button = Button(action: action) {
            buttonLabel
        }
        .modifier(CompactButtonStyleModifier(chrome: chrome))
        .modifier(CompactButtonChromeModifier(chrome: chrome, isLabeled: title != nil))

        if let accessibilityLabel {
            button.accessibilityLabel(accessibilityLabel)
        } else if let title {
            button.accessibilityLabel(Text(title))
        } else {
            button
        }
    }

    @ViewBuilder
    private var buttonLabel: some View {
        if let title {
            let label = HStack(spacing: theme.spacing.inline) {
                if let systemImage {
                    Image(systemName: systemImage)
                        .font(iconFont)
                }

                Text(title)
                    .font(theme.typography.caption.weight(.semibold))
            }
            .foregroundStyle(resolvedForeground)

            if chrome == .glass {
                label
                    .padding(.horizontal, max(12, theme.spacing.control))
                    .padding(.vertical, max(8, theme.spacing.inline))
                    .frame(minWidth: minimumSize, minHeight: minimumSize)
                    .contentShape(Capsule())
            } else {
                label
            }
        } else if let systemImage {
            let label = Image(systemName: systemImage)
                .font(iconFont)
                .foregroundStyle(resolvedForeground)

            if chrome == .glass {
                label
                    .padding(iconPadding)
                    .frame(minWidth: minimumSize, minHeight: minimumSize)
                    .contentShape(Circle())
            } else {
                label
            }
        }
    }

    private var minimumSize: CGFloat {
        switch chrome {
        case .toolbar:
            0
        case .glass:
            35
        }
    }

    private var iconPadding: CGFloat {
        switch chrome {
        case .toolbar:
            0
        case .glass:
            8
        }
    }

    private var iconFont: Font {
        switch chrome {
        case .toolbar:
            theme.typography.caption.weight(.bold)
        case .glass:
            theme.typography.body.weight(.semibold)
        }
    }

    private var resolvedForeground: Color {
        foreground ?? theme.colors.text
    }
}

// MARK: - Chrome

private struct CompactButtonStyleModifier: ViewModifier {
    let chrome: SFKCompactButtonChrome

    @ViewBuilder
    func body(content: Content) -> some View {
        switch chrome {
        case .toolbar:
            // The navigation bar owns the toolbar button surface and sizing.
            content
        case .glass:
            if #available(iOS 26, *) {
                content.buttonStyle(.glass)
            } else {
                content.buttonStyle(.plain)
            }
        }
    }
}

private struct CompactButtonChromeModifier: ViewModifier {
    @Environment(\.sfkTheme) private var theme
    let chrome: SFKCompactButtonChrome
    let isLabeled: Bool

    @ViewBuilder
    func body(content: Content) -> some View {
        switch chrome {
        case .toolbar:
            content
        case .glass:
            if #available(iOS 26, *) {
                if isLabeled {
                    content.buttonBorderShape(.capsule)
                } else {
                    content.buttonBorderShape(.circle)
                }
            } else if isLabeled {
                content
                    .background(theme.colors.surface.opacity(0.10), in: Capsule())
                    .overlay {
                        Capsule()
                            .strokeBorder(theme.colors.border, lineWidth: 1)
                    }
            } else {
                content
                    .background(theme.colors.surface.opacity(0.10), in: Circle())
            }
        }
    }
}

// MARK: - Previews

#Preview("SFKCompactButton") {
    ZStack {
        LinearGradient(
            colors: [.orange, .pink, .purple],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()

        VStack(spacing: 24) {
            SFKCompactButton(
                systemImage: "chevron.left",
                accessibilityLabel: "Back"
            ) { }

            SFKCompactButton("Edit", systemImage: "pencil") { }
            SFKCompactButton("Text only") { }
        }
        .foregroundStyle(.white)
    }
}
