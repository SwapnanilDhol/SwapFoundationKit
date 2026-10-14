/****************************************************************************
 * SFKOnboardingSelectionEmoji.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2026 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import SwiftUI

/// An emoji sized for the icon tile of ``SFKOnboardingSelectionCard``.
public struct SFKOnboardingSelectionEmoji: View {
    private let emoji: String

    public init(_ emoji: String) {
        self.emoji = emoji
    }

    public var body: some View {
        Text(verbatim: emoji)
            .font(.system(size: 21))
    }
}

#Preview {
    SFKOnboardingSelectionEmoji("✈️")
}
