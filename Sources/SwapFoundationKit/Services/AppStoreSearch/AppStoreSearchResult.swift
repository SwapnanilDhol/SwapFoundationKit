//
//  AppStoreSearchResult.swift
//  SwapFoundationKit
//
//  Created by Swapnanil Dhol  on 3/27/26.
//

import Foundation

struct AppStoreSearchResult: Identifiable, Equatable, Decodable {
    let trackId: Int
    let trackName: String
    let sellerName: String?
    let bundleId: String?
    let artworkUrl100: String?

    var id: Int { trackId }
}

private struct AppStoreSearchResponse: Decodable {
    let results: [AppStoreSearchResult]
}

@MainActor
final public class AppStoreSearchService: ObservableObject {
    @Published var query = ""
    @Published var results: [AppStoreSearchResult] = []
    @Published var isSearching = false
    @Published var errorMessage: String?

    private var searchTask: Task<Void, Never>?

    func updateQuery(_ newValue: String) {
        query = newValue
        searchTask?.cancel()

        let trimmed = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            results = []
            errorMessage = nil
            isSearching = false
            return
        }

        searchTask = Task {
            try? await Task.sleep(for: .milliseconds(300))
            guard !Task.isCancelled else { return }
            await search(term: trimmed)
        }
    }

    func search(term: String) async {
        guard let encodedTerm = term.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://itunes.apple.com/search?entity=software&limit=12&term=\(encodedTerm)") else {
            errorMessage = "Could not build the App Store search URL."
            return
        }

        isSearching = true
        errorMessage = nil

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(AppStoreSearchResponse.self, from: data)
            results = response.results
        } catch {
            if Task.isCancelled { return }
            results = []
            errorMessage = error.localizedDescription
        }

        isSearching = false
    }
}
