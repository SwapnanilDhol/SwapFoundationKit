/****************************************************************************
 * EmptyStateExamplesView.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2026 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import SwapFoundationKit
import SwiftUI

struct EmptyStateExamplesView: View {
    @State private var isInspectorPresented = false
    @State private var title = "No Items Yet"
    @State private var message = "Add your first item to get started."
    @State private var systemImage = "tray"
    @State private var showsAction = true
    @State private var actionTitle = "Add Item"
    @State private var actionSystemImage = "plus"
    @State private var actionColor = Color.accentColor

    var body: some View {
        CatalogControlPlayground(
            title: "Empty State",
            isInspectorPresented: $isInspectorPresented
        ) {
            CatalogExampleGroup(
                title: "Live Preview",
                apiNames: ["SFKEmptyStateView"]
            ) {
                Group {
                    if showsAction {
                        SFKEmptyStateView(
                            title: LocalizedStringKey(title),
                            message: LocalizedStringKey(message),
                            systemImage: systemImage,
                            actionTitle: actionTitle,
                            actionSystemImage: actionSystemImage,
                            actionColor: actionColor
                        ) {}
                    } else {
                        SFKEmptyStateView(
                            title: LocalizedStringKey(title),
                            message: LocalizedStringKey(message),
                            systemImage: systemImage
                        )
                    }
                }
                .padding(.vertical, 8)
                .background(.background, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            }
        } configuration: {
            Form {
                Section("Copy") {
                    TextField("Title", text: $title)
                    TextField("Message", text: $message)
                    TextField("SF Symbol", text: $systemImage)
                }

                Section("Action") {
                    Toggle("Show Action", isOn: $showsAction)
                    if showsAction {
                        TextField("Action Title", text: $actionTitle)
                        TextField("Action Symbol", text: $actionSystemImage)
                        ColorPicker("Action Color", selection: $actionColor)
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        EmptyStateExamplesView()
    }
}
