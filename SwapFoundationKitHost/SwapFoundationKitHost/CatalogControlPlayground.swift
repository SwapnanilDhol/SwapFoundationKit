/****************************************************************************
 * CatalogControlPlayground.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2026 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import SwiftUI

struct CatalogControlPlayground<Preview: View, Configuration: View>: View {
    let title: String
    @Binding var isInspectorPresented: Bool
    private let preview: () -> Preview
    private let configuration: () -> Configuration

    init(
        title: String,
        isInspectorPresented: Binding<Bool>,
        @ViewBuilder preview: @escaping () -> Preview,
        @ViewBuilder configuration: @escaping () -> Configuration
    ) {
        self.title = title
        _isInspectorPresented = isInspectorPresented
        self.preview = preview
        self.configuration = configuration
    }

    var body: some View {
        ScrollView {
            preview()
                .padding(16)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(title)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isInspectorPresented.toggle()
                } label: {
                    Image(systemName: "slider.horizontal.3")
                }
                .accessibilityLabel(isInspectorPresented ? "Hide configuration" : "Show configuration")
            }
        }
        .inspector(isPresented: $isInspectorPresented) {
            NavigationStack {
                configuration()
                    .navigationTitle("Configure")
                    .navigationBarTitleDisplayMode(.inline)
            }
            .presentationDetents([.medium, .large])
            .presentationBackgroundInteraction(.enabled(upThrough: .medium))
            .presentationDragIndicator(.visible)
            .inspectorColumnWidth(min: 320, ideal: 360, max: 440)
        }
    }
}

#Preview {
    @Previewable @State var isInspectorPresented = false

    NavigationStack {
        CatalogControlPlayground(
            title: "Component",
            isInspectorPresented: $isInspectorPresented
        ) {
            Text("Live preview")
                .frame(maxWidth: .infinity, minHeight: 240)
        } configuration: {
            Form {
                Toggle("Enabled", isOn: .constant(true))
            }
        }
    }
}
