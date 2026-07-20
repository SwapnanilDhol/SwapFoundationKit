/*****************************************************************************
 * SwapFoundationKitHostApp.swift
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

@main
struct SwapFoundationKitHostApp: App {
    init() {
        SFKAppearanceManager.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
