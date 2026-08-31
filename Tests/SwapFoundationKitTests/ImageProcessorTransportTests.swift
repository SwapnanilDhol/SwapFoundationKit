/*****************************************************************************
 * ImageProcessorTransportTests.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2025 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

#if canImport(UIKit) && !os(watchOS)
import XCTest
import UIKit
@testable import SwapFoundationKit

/// Covers that `ImageProcessor.cacheImage(from:targetSize:quality:)` routes remote fetches through
/// its injected `ImageProcessorTransport` (not `URLSession.shared`), and the deliberate non-2xx
/// error mapping to `.downloadFailed` documented on that method.
@MainActor
final class ImageProcessorTransportTests: XCTestCase {
    func testHTTPClientImageTransportPreservesURLHeadersAndTimeout() async throws {
        defer {
            MockURLProtocol.mockResponse = nil
            MockURLProtocol.lastRequest = nil
        }
        let url = URL(string: "https://images.example.com/assets/%2Fencoded/?first=1&dup=a&dup=b&raw&last=#fragment")!
        MockURLProtocol.mockResponse = (
            data: Self.makePNGData(),
            response: HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!,
            error: nil
        )
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let client = HTTPClient(configuration: config)
        let transport = HTTPClientImageTransport(client: client)

        _ = try await transport.data(from: url)

        let request = try XCTUnwrap(MockURLProtocol.lastRequest)
        XCTAssertEqual(request.url?.absoluteString, url.absoluteString)
        XCTAssertEqual(request.timeoutInterval, 60, accuracy: 0.001)
        XCTAssertNil(request.value(forHTTPHeaderField: "Accept"))
        XCTAssertNil(request.value(forHTTPHeaderField: "Content-Type"))
    }

    func testCacheImageUsesInjectedTransportOnSuccess() async throws {
        let url = URL(string: "https://images.example.com/avatar.png")!
        let transport = FakeImageTransport(outcome: .success(data: Self.makePNGData(), statusCode: 200))
        let processor = ImageProcessor(transport: transport)

        let image = try await processor.cacheImage(from: url)

        XCTAssertNotNil(image)
        XCTAssertEqual(transport.requestedURLs, [url])
    }

    func testCacheImageThrowsDownloadFailedForNon2xxStatus() async throws {
        let url = URL(string: "https://images.example.com/missing.png")!
        let transport = FakeImageTransport(
            outcome: .failure(NetworkError.httpError(statusCode: 404, data: Data("<html>not found</html>".utf8)))
        )
        let processor = ImageProcessor(transport: transport)

        do {
            _ = try await processor.cacheImage(from: url)
            XCTFail("Expected a thrown ImageProcessorError")
        } catch let error as ImageProcessorError {
            switch error {
            case .downloadFailed:
                break // Expected: see the doc comment on cacheImage(from:targetSize:quality:).
            default:
                XCTFail("Expected .downloadFailed, got \(error)")
            }
        }

        XCTAssertEqual(transport.requestedURLs, [url])
    }

    func testCacheImageThrowsInvalidRemoteImageDataFor2xxUndecodableBody() async throws {
        let url = URL(string: "https://images.example.com/not-an-image.png")!
        let transport = FakeImageTransport(outcome: .success(data: Data("not image bytes".utf8), statusCode: 200))
        let processor = ImageProcessor(transport: transport)

        do {
            _ = try await processor.cacheImage(from: url)
            XCTFail("Expected a thrown ImageProcessorError")
        } catch let error as ImageProcessorError {
            switch error {
            case .invalidRemoteImageData:
                break // Expected: 2xx response, but the body isn't decodable image data.
            default:
                XCTFail("Expected .invalidRemoteImageData, got \(error)")
            }
        }
    }

    private static func makePNGData() -> Data {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 2, height: 2))
        let image = renderer.image { context in
            UIColor.red.setFill()
            context.fill(CGRect(x: 0, y: 0, width: 2, height: 2))
        }
        return image.pngData()!
    }
}

/// Test-only `ImageProcessorTransport` that records requested URLs and returns a scripted outcome.
private final class FakeImageTransport: ImageProcessorTransport, @unchecked Sendable {
    enum Outcome {
        case success(data: Data, statusCode: Int)
        case failure(Error)
    }

    private(set) var requestedURLs: [URL] = []
    private let outcome: Outcome

    init(outcome: Outcome) {
        self.outcome = outcome
    }

    func data(from url: URL) async throws -> (Data, HTTPURLResponse) {
        requestedURLs.append(url)
        switch outcome {
        case .success(let data, let statusCode):
            let response = HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
            return (data, response)
        case .failure(let error):
            throw error
        }
    }
}
#endif
