/*****************************************************************************
 * AppLinkOpenerExamplesView.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2025 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import SwiftUI
import CoreLocation
import SwapFoundationKit

/// Examples for `AppLinkOpener` helpers.
struct AppLinkOpenerExamplesView: View {
    var body: some View {
        List {
            Section("Open URLs") {
                Button("Open Apple") { AppLinkOpener.open(string: "https://apple.com") }
            }
            Section("Maps") {
                Button("Apple Maps: Cupertino") { AppLinkOpener.open(coordinates: CLLocationCoordinate2D(latitude: 37.332, longitude: -122.011)) }
            }
            Section("App Store") {
                Button("App Store Page (Example)") { AppLinkOpener.openAppStorePage(appID: "284882215") } // Facebook app id example
            }
        }
        .navigationTitle("App Link Opener")
    }
}


