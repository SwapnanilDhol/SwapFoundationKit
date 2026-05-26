//
//  AppStoreSearchResult.swift
//  SwapFoundationKit
//
//  Created by Swapnanil Dhol  on 3/27/26.
//

import Foundation

public struct AppStoreSearchResult: Identifiable, Equatable, Decodable {
    public let trackId: Int
    public let trackName: String
    public let sellerName: String?
    public let bundleId: String?
    public let artworkUrl100: String?

    public var id: Int { trackId }
}

private struct AppStoreSearchResponse: Decodable {
    let results: [AppStoreSearchResult]
}

private struct AppStoreSearchRequest: NetworkRequest {
    let term: String

    var scheme: String { "https" }
    var baseURL: String { "itunes.apple.com" }
    var path: String { "/search" }
    var method: HTTPMethod { .get }
    var parameters: [String : String]? {
        [
            "entity": "software",
            "limit": "12",
            "term": term
        ]
    }
    var headers: [String : String]? { nil }
    var body: Data? { nil }
}

@MainActor
final public class AppStoreSearchService: ObservableObject {
    @Published public var query = ""
    @Published public var results: [AppStoreSearchResult] = []
    @Published public var isSearching = false
    @Published public var errorMessage: String?

    private var searchTask: Task<Void, Never>?
    private let client: HTTPClient

    public init(client: HTTPClient = .shared) {
        self.client = client
    }

    public func updateQuery(_ newValue: String) {
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
        isSearching = true
        errorMessage = nil

        do {
            let response: AppStoreSearchResponse = try await client.executeAndDecode(AppStoreSearchRequest(term: term))
            results = response.results
        } catch {
            if Task.isCancelled { return }
            results = []
            errorMessage = error.localizedDescription
        }

        isSearching = false
    }
}
