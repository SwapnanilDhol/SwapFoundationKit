/*****************************************************************************
 * SFKButtonHaptics.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2025 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import SwiftUI

#if canImport(UIKit) && os(iOS)
import UIKit

@MainActor
internal final class ButtonHaptics {
    static let shared = ButtonHaptics()
    private let impactFeedbackGenerator = UIImpactFeedbackGenerator()
    private init() { impactFeedbackGenerator.prepare() }

    func mediumImpact() {
        impactFeedbackGenerator.impactOccurred()
    }
}
#else
internal final class ButtonHaptics {
    static let shared = ButtonHaptics()
    func mediumImpact() { }
}
#endif

