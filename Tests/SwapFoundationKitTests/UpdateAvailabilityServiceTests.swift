import Foundation
import XCTest
@testable import SwapFoundationKit

final class UpdateAvailabilityServiceTests: XCTestCase {
    private var session: URLSession!

    override func setUp() {
        super.setUp()
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [UpdateAvailabilityMockURLProtocol.self]
        session = URLSession(configuration: configuration)
        UpdateAvailabilityMockURLProtocol.mockResponse = nil
    }

    override func tearDown() {
        UpdateAvailabilityMockURLProtocol.mockResponse = nil
        session = nil
        super.tearDown()
    }

    func testVersionComparisonUsesNumericOrdering() {
        XCTAssertTrue(SFKUpdateAvailabilityService.isVersion("2.10.0", newerThan: "2.2.0"))
        XCTAssertFalse(SFKUpdateAvailabilityService.isVersion("2.0.0", newerThan: "2.0.0"))
        XCTAssertFalse(SFKUpdateAvailabilityService.isVersion("1.9.9", newerThan: "2.0.0"))
    }

    @MainActor
    func testCheckForUpdateReturnsUpdateWhenStoreVersionIsNewer() async {
        let url = URL(string: "https://itunes.apple.com/lookup?bundleId=com.example.app")!
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
        let payload = #"{"results":[{"version":"2.3.0"}]}"#.data(using: .utf8)!
        UpdateAvailabilityMockURLProtocol.mockResponse = (payload, response, nil)

        let service = SFKUpdateAvailabilityService(session: session)
        let result = await service.checkForUpdate(
            configuration: SFKUpdateAvailabilityConfiguration(
                bundleID: "com.example.app",
                currentVersion: "2.2.0",
                cacheDuration: 0
            )
        )

        XCTAssertEqual(result, .updateAvailable(newVersion: "2.3.0"))
    }

    @MainActor
    func testCheckForUpdateReturnsNoUpdateWhenVersionMatches() async {
        let url = URL(string: "https://itunes.apple.com/lookup?bundleId=com.example.app")!
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
        let payload = #"{"results":[{"version":"2.3.0"}]}"#.data(using: .utf8)!
        UpdateAvailabilityMockURLProtocol.mockResponse = (payload, response, nil)

        let service = SFKUpdateAvailabilityService(session: session)
        let result = await service.checkForUpdate(
            configuration: SFKUpdateAvailabilityConfiguration(
                bundleID: "com.example.app",
                currentVersion: "2.3.0",
                cacheDuration: 0
            )
        )

        XCTAssertEqual(result, .noUpdatesAvailable)
    }

    @MainActor
    func testCheckForUpdateGracefullyHandlesLookupFailure() async {
        let url = URL(string: "https://itunes.apple.com/lookup?bundleId=com.example.app")!
        let response = HTTPURLResponse(url: url, statusCode: 500, httpVersion: nil, headerFields: nil)!
        UpdateAvailabilityMockURLProtocol.mockResponse = (Data(), response, URLError(.badServerResponse))

        let service = SFKUpdateAvailabilityService(session: session)
        let result = await service.checkForUpdate(
            configuration: SFKUpdateAvailabilityConfiguration(
                bundleID: "com.example.app",
                currentVersion: "2.0.0",
                cacheDuration: 0
            )
        )

        XCTAssertEqual(result, .noUpdatesAvailable)
    }
}

private final class UpdateAvailabilityMockURLProtocol: URLProtocol {
    static var mockResponse: (Data?, URLResponse?, Error?)?

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        if let mockResponse = Self.mockResponse {
            if let response = mockResponse.1 {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            if let data = mockResponse.0 {
                client?.urlProtocol(self, didLoad: data)
            }
            if let error = mockResponse.2 {
                client?.urlProtocol(self, didFailWithError: error)
            } else {
                client?.urlProtocolDidFinishLoading(self)
            }
        }
    }

    override func stopLoading() {}
}
