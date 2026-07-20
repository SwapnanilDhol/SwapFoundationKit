/*****************************************************************************
 * ContentView.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2025-2026 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import SwiftUI

struct ContentView: View {
    @State private var searchText = ""

    private var filteredDestinations: [CatalogDestination] {
        CatalogDestination.allCases.filter { $0.matches(searchText) }
    }

    var body: some View {
        NavigationStack {
            List {
                CatalogHeroView(componentCount: CatalogDestination.visualComponentCount)

                ForEach(CatalogSection.allCases) { section in
                    let destinations = filteredDestinations.filter { $0.section == section }

                    if !destinations.isEmpty {
                        Section(section.rawValue) {
                            ForEach(destinations) { destination in
                                NavigationLink(value: destination) {
                                    CatalogRow(destination: destination)
                                }
                            }
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("SFK Catalog")
            .searchable(text: $searchText, prompt: "Search components and APIs")
            .navigationDestination(for: CatalogDestination.self) { destination in
                CatalogDestinationView(destination: destination)
            }
            .overlay {
                if filteredDestinations.isEmpty {
                    ContentUnavailableView.search(text: searchText)
                }
            }
        }
        .fontDesign(.rounded)
    }
}

private struct CatalogHeroView: View {
    let componentCount: Int

    var body: some View {
        Section {
            VStack(alignment: .leading, spacing: 10) {
                Image(systemName: "square.grid.2x2.fill")
                    .font(.title2)
                    .foregroundStyle(.tint)

                Text("SwapFoundationKit")
                    .font(.title2.bold())

                Text("Explore live components, interactions, and foundation APIs in one place.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Label("\(componentCount) visual components indexed", systemImage: "checkmark.seal.fill")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 8)
            .accessibilityElement(children: .combine)
        }
    }
}

private struct CatalogRow: View {
    let destination: CatalogDestination

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: destination.symbolName)
                .font(.body.weight(.semibold))
                .foregroundStyle(destination.tint)
                .frame(width: 34, height: 34)
                .background(destination.tint.opacity(0.12), in: RoundedRectangle(cornerRadius: 9, style: .continuous))

            VStack(alignment: .leading, spacing: 3) {
                Text(destination.title)
                    .font(.body.weight(.semibold))

                Text(destination.summary)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)

                if !destination.apiNames.isEmpty {
                    Text(destination.apiNames.prefix(3).joined(separator: " · "))
                        .font(.caption2.monospaced())
                        .foregroundStyle(.tertiary)
                        .lineLimit(1)
                }
            }
        }
        .padding(.vertical, 2)
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    ContentView()
}
