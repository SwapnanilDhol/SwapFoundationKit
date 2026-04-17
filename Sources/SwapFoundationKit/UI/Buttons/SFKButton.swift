/*****************************************************************************
 * SFKButton.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2025 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import SwiftUI

public enum SFKButtonKind {
    case primary
    case secondary
    case inline
    case inlinePlain
    case pill
    case toolbar
    case close
}

public struct SFKButton<Label: View>: View {
    private let kind: SFKButtonKind
    private let tint: Color?
    private let isEnabled: Bool
    private let isLoading: Bool
    private let forceLegacyStyle: Bool
    private let action: () -> Void
    @ViewBuilder private let label: () -> Label
    private let haptics = ButtonHaptics.shared

    public init(
        kind: SFKButtonKind,
        tint: Color? = nil,
        isEnabled: Bool = true,
        isLoading: Bool = false,
        action: @escaping () -> Void,
        @ViewBuilder label: @escaping () -> Label
    ) {
        self.kind = kind
        self.tint = tint
        self.isEnabled = isEnabled
        self.isLoading = isLoading
        self.forceLegacyStyle = false
        self.action = action
        self.label = label
    }

    public init(
        kind: SFKButtonKind,
        title: String,
        systemImage: String? = nil,
        tint: Color? = nil,
        isEnabled: Bool = true,
        isLoading: Bool = false,
        action: @escaping () -> Void
    ) where Label == SFKButtonDefaultLabel {
        self.kind = kind
        self.tint = tint
        self.isEnabled = isEnabled
        self.isLoading = isLoading
        self.forceLegacyStyle = false
        self.action = action
        self.label = {
            SFKButtonDefaultLabel(
                kind: kind,
                title: title,
                systemImage: systemImage,
                tint: tint,
                isEnabled: isEnabled,
                isLoading: isLoading
            )
        }
    }

#if DEBUG
    public init(
        kind: SFKButtonKind,
        tint: Color? = nil,
        isEnabled: Bool = true,
        isLoading: Bool = false,
        forceLegacyStyle: Bool,
        action: @escaping () -> Void,
        @ViewBuilder label: @escaping () -> Label
    ) {
        self.kind = kind
        self.tint = tint
        self.isEnabled = isEnabled
        self.isLoading = isLoading
        self.forceLegacyStyle = forceLegacyStyle
        self.action = action
        self.label = label
    }

    public init(
        kind: SFKButtonKind,
        title: String,
        systemImage: String? = nil,
        tint: Color? = nil,
        isEnabled: Bool = true,
        isLoading: Bool = false,
        forceLegacyStyle: Bool,
        action: @escaping () -> Void
    ) where Label == SFKButtonDefaultLabel {
        self.kind = kind
        self.tint = tint
        self.isEnabled = isEnabled
        self.isLoading = isLoading
        self.forceLegacyStyle = forceLegacyStyle
        self.action = action
        self.label = {
            SFKButtonDefaultLabel(
                kind: kind,
                title: title,
                systemImage: systemImage,
                tint: tint,
                isEnabled: isEnabled,
                isLoading: isLoading
            )
        }
    }
#endif

    public var body: some View {
        let button = Button {
            guard isEnabled, !isLoading else { return }
            haptics.mediumImpact()
            action()
        } label: {
            label()
                .frame(maxWidth: labelMaxWidth)
                .frame(height: labelHeight)
                .contentShape(Rectangle())
        }
        .frame(maxWidth: buttonMaxWidth)
        .disabled(!isEnabled || isLoading)
        .opacity(isEnabled ? tokens.enabledOpacity : tokens.disabledOpacity)

        if #available(iOS 26, macOS 26, watchOS 26, tvOS 26, visionOS 26, *),
           usesGlassProminentStyle,
           !forceLegacyStyle {
            button
                .buttonStyle(.glassProminent)
                .tint(glassTint)
        } else {
            button
                .buttonStyle(.plain)
                .background(fallbackBackground)
        }
    }

    private var usesGlassProminentStyle: Bool {
        switch kind {
        case .inlinePlain:
            false
        case .primary, .secondary, .inline, .pill, .toolbar, .close:
            true
        }
    }

    private var tokens: SFKButtonVisualTokens {
        .current
    }

    private var resolvedTint: Color {
        switch kind {
        case .primary, .inline, .inlinePlain:
            tint ?? .accentColor
        case .secondary, .pill, .toolbar:
            tint ?? .secondary
        case .close:
            .white
        }
    }

    private var glassTint: Color {
        if kind == .close {
            return Color.white.opacity(tokens.closeButtonTintOpacity)
        }

        return resolvedTint.opacity(
            isEnabled ? tokens.enabledOpacity : tokens.disabledOpacity
        )
    }

    @ViewBuilder
    private var fallbackBackground: some View {
        switch kind {
        case .primary:
            RoundedRectangle(cornerRadius: tokens.primaryCornerRadius, style: .continuous)
                .fill(glassTint)

        case .secondary:
            RoundedRectangle(cornerRadius: tokens.secondaryCornerRadius, style: .continuous)
                .fill(secondaryFallbackBackgroundColor)

        case .inline:
            RoundedRectangle(cornerRadius: tokens.inlineCornerRadius, style: .continuous)
                .fill(glassTint.opacity(tokens.inlineFilledBackgroundOpacity))

        case .inlinePlain:
            Color.clear

        case .pill:
            Capsule()
                .fill(glassTint.opacity(tokens.pillFallbackBackgroundOpacity))

        case .toolbar:
            Capsule()
                .fill(glassTint.opacity(tokens.closeButtonFallbackBackgroundOpacity))

        case .close:
            Capsule()
                .fill(Color.white.opacity(tokens.closeButtonFallbackBackgroundOpacity))
        }
    }

    private var secondaryFallbackBackgroundColor: Color {
#if canImport(UIKit) && os(iOS)
        Color(uiColor: .secondarySystemGroupedBackground)
#elseif canImport(AppKit)
        Color(nsColor: .windowBackgroundColor)
#else
        Color.secondary.opacity(tokens.inlineFilledBackgroundOpacity)
#endif
    }

    private var labelHeight: CGFloat? {
        switch kind {
        case .primary, .secondary:
            tokens.buttonLabelHeight
        case .inline, .inlinePlain, .pill, .toolbar, .close:
            nil
        }
    }

    private var labelMaxWidth: CGFloat? {
        switch kind {
        case .primary, .secondary:
            .infinity
        case .inline, .inlinePlain, .pill, .toolbar, .close:
            nil
        }
    }

    private var buttonMaxWidth: CGFloat? {
        switch kind {
        case .primary, .secondary:
            .infinity
        case .inline, .inlinePlain, .pill, .toolbar, .close:
            nil
        }
    }
}

public struct SFKButtonDefaultLabel: View {
    private let kind: SFKButtonKind
    private let title: String
    private let systemImage: String?
    private let tint: Color?
    private let isEnabled: Bool
    private let isLoading: Bool

    public init(
        kind: SFKButtonKind,
        title: String,
        systemImage: String?,
        tint: Color?,
        isEnabled: Bool,
        isLoading: Bool
    ) {
        self.kind = kind
        self.title = title
        self.systemImage = systemImage
        self.tint = tint
        self.isEnabled = isEnabled
        self.isLoading = isLoading
    }

    public var body: some View {
        HStack(spacing: spacing) {
            if isLoading {
                ProgressView()
                    .tint(foregroundColor)
            } else if let resolvedSystemImage {
                Image(systemName: resolvedSystemImage)
                    .font(iconFont)
            }

            if !resolvedTitle.isEmpty {
                Text(resolvedTitle)
                    .font(textFont)
                    .lineLimit(1)
            }
        }
        .fixedSize(horizontal: isCompactKind, vertical: false)
        .padding(.horizontal, horizontalPadding)
        .padding(.vertical, verticalPadding)
        .foregroundStyle(foregroundColor)
    }

    private var tokens: SFKButtonVisualTokens {
        .current
    }

    private var resolvedTitle: String {
        if kind == .close, title.isEmpty {
            return "Close"
        }
        return title
    }

    private var resolvedSystemImage: String? {
        if kind == .close, systemImage == nil {
            return "xmark"
        }
        return systemImage
    }

    private var isCompactKind: Bool {
        switch kind {
        case .primary, .secondary:
            false
        case .inline, .inlinePlain, .pill, .toolbar, .close:
            true
        }
    }

    private var spacing: CGFloat {
        switch kind {
        case .primary, .secondary:
            10
        case .inline, .inlinePlain:
            6
        case .pill, .toolbar, .close:
            8
        }
    }

    private var horizontalPadding: CGFloat {
        switch kind {
        case .primary, .secondary:
            0
        case .inline, .inlinePlain:
            12
        case .pill:
            11
        case .toolbar:
            6
        case .close:
            12
        }
    }

    private var verticalPadding: CGFloat {
        switch kind {
        case .primary, .secondary:
            0
        case .inline, .inlinePlain:
            8
        case .pill:
            8
        case .toolbar:
            4
        case .close:
            9
        }
    }

    private var textFont: Font {
        switch kind {
        case .primary, .secondary:
            .headline.weight(.semibold)
        case .inline, .inlinePlain:
            .subheadline.weight(.semibold)
        case .pill, .toolbar, .close:
            .footnote.weight(.semibold)
        }
    }

    private var iconFont: Font {
        switch kind {
        case .primary, .secondary:
            .headline
        case .inline, .inlinePlain:
            .caption.weight(.semibold)
        case .pill, .toolbar, .close:
            .footnote.weight(.bold)
        }
    }

    private var foregroundColor: Color {
        switch kind {
        case .primary:
            isEnabled ? tokens.primaryForegroundColor : tokens.primaryForegroundColor.opacity(tokens.disabledForegroundOpacity)
        case .secondary, .pill, .close:
            isEnabled ? .primary : .secondary
        case .inline:
            isEnabled ? tokens.tintedForegroundColor : .secondary
        case .inlinePlain:
            isEnabled ? (tint ?? .accentColor) : .secondary
        case .toolbar:
            isEnabled ? tokens.toolbarForegroundColor : .secondary
        }
    }
}

#Preview("Button Kinds") {
    VStack(spacing: 16) {
        SFKButton(
            kind: .primary,
            title: "Add Transaction",
            systemImage: "wand.and.stars",
            tint: .red,
            action: {}
        )
        SFKButton(kind: .secondary, title: "Cancel", action: {})
        HStack {
            SFKButton(kind: .inline, title: "Edit", systemImage: "pencil", action: {})
            SFKButton(kind: .inlinePlain, title: "View All", action: {})
        }
        HStack {
            SFKButton(kind: .pill, title: "Approve", systemImage: "checkmark", tint: .green, action: {})
            SFKButton(kind: .close, title: "", action: {})
        }
    }
    .padding()
}

#Preview("Toolbar Buttons In Navigation Bar") {
    NavigationStack {
        List {
            Text("Buttons should be previewed in a navigation bar context.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .navigationTitle("Button Demo")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                SFKButton(kind: .toolbar, title: "", systemImage: "plus", tint: .orange, action: {})
            }
            ToolbarItem(placement: .topBarTrailing) {
                SFKButton(kind: .toolbar, title: "Edit", tint: .blue, action: {})
            }
            ToolbarItem(placement: .topBarTrailing) {
                SFKButton(kind: .close, title: "", action: {})
            }
        }
    }
}

#Preview("Legacy Fallback Buttons") {
    VStack(spacing: 16) {
        SFKButton(
            kind: .primary,
            title: "Add Transaction",
            systemImage: "wand.and.stars",
            tint: .red,
            forceLegacyStyle: true,
            action: {}
        )
        SFKButton(
            kind: .secondary,
            title: "Cancel",
            forceLegacyStyle: true,
            action: {}
        )
        HStack {
            SFKButton(
                kind: .inline,
                title: "Edit",
                systemImage: "pencil",
                tint: .blue,
                forceLegacyStyle: true,
                action: {}
            )
            SFKButton(
                kind: .inlinePlain,
                title: "View All",
                tint: .blue,
                forceLegacyStyle: true,
                action: {}
            )
        }
        HStack {
            SFKButton(
                kind: .pill,
                title: "Approve",
                systemImage: "checkmark",
                tint: .green,
                forceLegacyStyle: true,
                action: {}
            )
            SFKButton(
                kind: .close,
                title: "",
                forceLegacyStyle: true,
                action: {}
            )
        }
    }
    .padding()
}
