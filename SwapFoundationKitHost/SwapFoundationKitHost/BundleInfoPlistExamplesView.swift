/*****************************************************************************
 * BundleInfoPlistExamplesView.swift
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

/// Examples for `Bundle+InfoPlist` helpers in SwapFoundationKit.
struct BundleInfoPlistExamplesView: View {
    var body: some View {
        let bundle = Bundle.main
        return List {
            Section("Common Keys") {
                LabeledContent("App Name", value: bundle.appName)
                LabeledContent("Display Name", value: bundle.displayName)
                LabeledContent("Executable", value: bundle.executable)
                LabeledContent("Bundle Identifier", value: bundle.bundleIdentifier)
                LabeledContent("Version", value: bundle.releaseVersionNumber)
                LabeledContent("Build", value: bundle.buildVersionNumber)
                LabeledContent("Min OS", value: bundle.minimumOSVersion)
            }
            Section("URL Schemes") {
                ForEach(bundle.urlSchemes, id: \.self) { scheme in
                    Text(scheme)
                }
            }
        }
        .navigationTitle("Info.plist")
    }
}


