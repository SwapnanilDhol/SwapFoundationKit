/****************************************************************************
 * SFKNumberPadButton.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2026 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import SwiftUI
import AVFoundation

/// A single key in ``SFKNumberPad``.
///
/// Styling is intentionally fixed: this mirrors the amount-entry keypad
/// button shared by every host app, down to the system sound IDs and haptic
/// weight, so it is not configurable beyond which key it represents.
public struct SFKNumberPadButton: View {

    @State private var isPressed = false
    private let haptics = HapticsHelper()
    private let number: SFKNumberPadInput
    private let action: () -> Void

    public init(number: SFKNumberPadInput, action: @escaping () -> Void) {
        self.number = number
        self.action = action
    }

    public var body: some View {
        Button {
            let systemSoundID: SystemSoundID
            switch number {
            case .backspace:
                systemSoundID = 1155
            case .period:
                systemSoundID = 1156
            default:
                systemSoundID = 1104
            }
            haptics.lightImpact()
            AudioServicesPlaySystemSound(systemSoundID)
            action()
        } label: {
            Group {
                if number == .backspace {
                    Image(systemName: "delete.left")
                } else {
                    Text(number.rawValue)
                }
            }
            .font(.system(size: 28, weight: .medium, design: .rounded))
            .foregroundStyle(Color.primary.opacity(0.92))
            .frame(maxWidth: .infinity)
            .frame(height: 58)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .sfkGlass(
            material: .regular,
            tint: Color(.quaternarySystemFill),
            isInteractive: true,
            shape: .roundedRectangle(cornerRadius: 12)
        )
        .opacity(isPressed ? 0.58 : 1.0)
        .scaleEffect(isPressed ? 0.96 : 1.0)
        .animation(.easeOut(duration: 0.12), value: isPressed)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if isPressed == false {
                        isPressed = true
                    }
                }
                .onEnded { _ in
                    isPressed = false
                }
        )
        .onDisappear {
            isPressed = false
        }
    }
}

#Preview {
    SFKNumberPadButton(number: .one) {}
        .padding()
}
