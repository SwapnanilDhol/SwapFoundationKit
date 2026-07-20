/*****************************************************************************
 * CatalogExampleGroup.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2026 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import SwiftUI

struct CatalogExampleGroup<Content: View>: View {
    let title: String
    let apiNames: [String]
    private let content: () -> Content

    init(
        title: String,
        apiNames: [String],
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.title = title
        self.apiNames = apiNames
        self.content = content
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)

                Text(apiNames.joined(separator: " · "))
                    .font(.caption2.monospaced())
                    .foregroundStyle(.secondary)
            }

            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
