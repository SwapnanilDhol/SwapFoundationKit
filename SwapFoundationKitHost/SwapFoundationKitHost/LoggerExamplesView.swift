/*****************************************************************************
 * LoggerExamplesView.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2025 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import SwiftUI
import SwapFoundationKit

/// Examples for `Logger` usage.
struct LoggerExamplesView: View {
    var body: some View {
        List {
            Button("Log Info") { Logger.info("Hello from Logger") }
            Button("Log Debug") { Logger.debug("Debug line") }
            Button("Log Warning") { Logger.warning("Watch out!") }
            Button("Log Error") { Logger.error("Something failed") }
        }
        .navigationTitle("Logger")
    }
}


