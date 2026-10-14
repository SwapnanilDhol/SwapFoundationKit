/****************************************************************************
 * SFKOnboardingPressableRowButtonStyle.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2026 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import SwiftUI

/// A button style for tappable onboarding rows and cards: a slight press-in
/// scale and dim, with a softer fade under Reduce Motion.
///
/// ## Usage
/// ```swift
/// Button(action: select) { row }
///     .buttonStyle(SFKOnboardingPressableRowButtonStyle())
/// ```
public struct SFKOnboardingPressableRowButtonStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed && !reduceMotion ? 0.985 : 1)
            .opacity(configuration.isPressed ? 0.82 : 1)
            .animation(
                reduceMotion
                    ? .easeOut(duration: 0.12)
                    : .spring(response: 0.22, dampingFraction: 1),
                value: configuration.isPressed
            )
    }
}

#Preview {
    Button {} label: {
        Text("Press me")
            .padding()
            .frame(maxWidth: .infinity)
            .background(.quaternary, in: RoundedRectangle(cornerRadius: 18))
    }
    .buttonStyle(SFKOnboardingPressableRowButtonStyle())
    .padding()
}
