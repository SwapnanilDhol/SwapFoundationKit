/*****************************************************************************
 * AlertExamplesView.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2026 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import SwiftUI
import SwapFoundationKit

struct AlertExamplesView: View {
    var body: some View {
        List {
            Section("UIKit Presenter") {
                Button("Show Alert") {
                    AlertPresenter.showAlert(
                        title: "SFK Alert",
                        message: "This alert is presented by the shared UIKit presenter."
                    )
                }

                Button("Show Confirmation") {
                    AlertPresenter.showConfirmation(
                        title: "Continue?",
                        message: "Confirmations can use standard or destructive actions.",
                        onConfirm: {}
                    )
                }

                Button("Show Action Sheet") {
                    AlertPresenter.showActionSheet(
                        title: "Choose an action",
                        actions: [
                            AlertAction("Duplicate"),
                            AlertAction("Delete", style: .destructive),
                            AlertAction("Cancel", style: .cancel)
                        ]
                    )
                }
            }

            Section("Included APIs") {
                Text("AlertPresenter").font(.body.monospaced())
                Text("AlertController").font(.body.monospaced())
                Text("AlertConfiguration").font(.body.monospaced())
                Text("AlertAction").font(.body.monospaced())
            }
        }
        .navigationTitle("Alerts")
    }
}

#Preview {
    NavigationStack {
        AlertExamplesView()
    }
}
