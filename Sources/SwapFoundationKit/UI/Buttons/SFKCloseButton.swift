/*****************************************************************************
 * SFKCloseButton.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2025 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import SwiftUI

/// A glass-style close button with icon + text.
public struct SFKCloseButton: View {
    private let action: () -> Void

    public init(action: @escaping () -> Void) {
        self.action = action
    }

    public var body: some View {
        SFKButton(kind: .close, title: "", action: action)
    }
}

#Preview("Close Button") {
    VStack {
        SFKCloseButton(action: {})
    }
    .padding()
    .background(Color.gray.opacity(0.2))
}
