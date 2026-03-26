/*****************************************************************************
 * HapticsExamplesView.swift
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

/// Examples for `HapticsHelper`.
struct HapticsExamplesView: View {
    var body: some View {
        List {
            Section("Impact") {
                Button("Light Impact") { HapticsHelper().lightImpact() }
                Button("Medium Impact") { HapticsHelper().mediumImpact() }
                Button("Heavy Impact") { HapticsHelper().heavyImpact() }
                Button("Custom 0.7") { HapticsHelper().customImpact(intensity: 0.7) }
            }
            Section("Notification") {
                Button("Success") { HapticsHelper().successNotification() }
                Button("Warning") { HapticsHelper().warningNotification() }
                Button("Error") { HapticsHelper().errorNotification() }
            }
            // Selection haptic not exposed by helper currently
        }
        .navigationTitle("Haptics")
    }
}


