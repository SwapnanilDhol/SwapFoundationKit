//
//  LocationSearchService.swift
//  SwapFoundationKit
//
//  Created by Swapnanil Dhol  on 3/27/26.
//

import Foundation
import MapKit

@MainActor
final public class LocationSearchService: NSObject, ObservableObject {

    // MARK: - Published Properties

    @Published public var searchQuery = ""
    @Published public var completions: [MKLocalSearchCompletion] = []
    @Published public var isSearching = false
    @Published public var errorMessage: String?

    // MARK: - Private Properties

    private var completer: MKLocalSearchCompleter
    
    public override init() {
        completer = MKLocalSearchCompleter()
        super.init()
        completer.delegate = self
        completer.resultTypes = [.pointOfInterest, .address]
    }

    private func performSearch(query: String) {
        if query.isEmpty {
            completions = []
            errorMessage = nil
        } else {
            isSearching = true
            completer.queryFragment = query
        }
    }

    // MARK: - Public Methods

    func search() {
        performSearch(query: searchQuery.trimmingCharacters(in: .whitespacesAndNewlines))
    }

    /// Searches for location details from a completion result
    /// - Parameters:
    ///   - completion: The search completion to resolve
    ///   - completionHandler: Callback with the resolved map item
    func search(for completion: MKLocalSearchCompletion, completionHandler: @escaping (MKMapItem?) -> Void) {
        let searchRequest = MKLocalSearch.Request(completion: completion)
        let search = MKLocalSearch(request: searchRequest)

        search.start { [weak self] response, error in
            Task { @MainActor in
                self?.isSearching = false

                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    Logger.debug("Location search failed: \(error.localizedDescription)")
                    completionHandler(nil)
                    return
                }

                guard let item = response?.mapItems.first else {
                    completionHandler(nil)
                    return
                }

                completionHandler(item)
            }
        }
    }

    /// Clears the search query and results
    func clearSearch() {
        searchQuery = ""
        completions = []
        errorMessage = nil
    }

    func formattedAddress(for mapItem: MKMapItem) -> String {
        let placemark = mapItem.placemark
        let parts: [String] = [
            mapItem.name,
            placemark.locality,
            placemark.administrativeArea,
            placemark.country,
        ]
        .compactMap { value in
            guard let value, !value.isEmpty else { return nil }
            return value
        }

        if !parts.isEmpty {
            var seen = Set<String>()
            return parts
                .filter { seen.insert($0).inserted }
                .joined(separator: ", ")
        }

        return "\(placemark.coordinate.latitude), \(placemark.coordinate.longitude)"
    }
}

// MARK: - MKLocalSearchCompleterDelegate

extension LocationSearchService: MKLocalSearchCompleterDelegate {

    nonisolated public func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        Task { @MainActor in
            self.completions = completer.results
            self.isSearching = false
        }
    }

    nonisolated public func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        Task { @MainActor in
            self.isSearching = false
            self.errorMessage = error.localizedDescription
            Logger.debug("Location completer failed: \(error.localizedDescription)")
        }
    }
}
