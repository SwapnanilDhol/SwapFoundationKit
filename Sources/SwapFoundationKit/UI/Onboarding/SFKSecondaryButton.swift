//
//  SFKSecondaryButton.swift
//  SwapFoundationKit
//
//  Created by Swapnanil Dhol on 4/30/26.
//

import SwiftUI

/// A secondary text-only button styled for skip, dismiss, or "not now" actions.
///
/// Renders as a subtle `.subheadline` text button in `.secondary` foreground color.
///
/// ## Usage
/// ```swift
/// SFKSecondaryButton("Skip for now") {
///     skipOnboarding()
/// }
///
/// SFKSecondaryButton("Not now", color: .red) {
///     dismiss()
/// }
/// ```
public struct SFKSecondaryButton: View {
    /// The button label text.
    public let title: String

    /// The text color.
    public var color: Color

    /// The font used for the label.
    public var font: Font

    /// The action executed when the button is tapped.
    public let action: () -> Void

    /// Creates a secondary button.
    /// - Parameters:
    ///   - title: The button label text.
    ///   - color: The text color. Defaults to `.secondary`.
    ///   - font: The label font. Defaults to `.subheadline`.
    ///   - action: Closure executed on tap.
    public init(
        _ title: String,
        color: Color = .secondary,
        font: Font = .subheadline,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.color = color
        self.font = font
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Text(title)
                .font(font)
                .foregroundStyle(color)
        }
    }
}

#Preview("SFKSecondaryButton") {
    VStack(spacing: 20) {
        SFKSecondaryButton("Skip for now") { }

        SFKSecondaryButton("Not now", color: .red) { }

        SFKSecondaryButton("Maybe later", font: .footnote) { }

        SFKSecondaryButton("Dismiss", color: .blue, font: .caption.weight(.semibold)) { }
    }
    .padding(24)
}
