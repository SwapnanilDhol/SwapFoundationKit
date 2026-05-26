/*****************************************************************************
 * SFKPulseConsoleView.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2025 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import SwiftUI
#if canImport(PulseUI)
import PulseUI
#endif

public enum SFKPulseConsoleMode: Sendable {
    case all
    case logs
    case network
}

/// A ready-made SwiftUI screen for browsing SFK logs and network requests with Pulse.
public struct SFKPulseConsoleView: View {
    private let mode: SFKPulseConsoleMode
    private let hidesCloseButton: Bool

    public init(mode: SFKPulseConsoleMode = .all, hidesCloseButton: Bool = false) {
        self.mode = mode
        self.hidesCloseButton = hidesCloseButton
    }

    public var body: some View {
        #if canImport(PulseUI)
        ConsoleView(mode: pulseMode)
            .closeButtonHidden(hidesCloseButton)
        #else
        Text("PulseUI is unavailable on this platform.")
        #endif
    }

    #if canImport(PulseUI)
    private var pulseMode: ConsoleMode {
        switch mode {
        case .all:
            return .all
        case .logs:
            return .logs
        case .network:
            return .network
        }
    }
    #endif
}
