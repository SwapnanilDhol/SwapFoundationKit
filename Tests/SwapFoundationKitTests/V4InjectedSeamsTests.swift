import XCTest
@testable import SwapFoundationKit
@testable import SwapFoundationKitNetworking
#if canImport(UIKit) && !os(watchOS)
import UIKit
@testable import SwapFoundationKitMedia
#endif

@MainActor
final class V4InjectedSeamsTests: XCTestCase {
    func testAccessGateUsesInjectedPolicyAndOnlyRunsAllowedAction() {
        let policy = TestAccessPolicy(isProEnabled: false)
        let gate = SFKAccessGate(policy: policy)
        var actionCount = 0

        XCTAssertFalse(gate.check("export"))
        gate.require("export") { actionCount += 1 }
        XCTAssertEqual(actionCount, 0)
        XCTAssertEqual(policy.reasons, ["export", "export"])

        policy.isProEnabled = true
        XCTAssertTrue(gate.check("export"))
        gate.require("export") { actionCount += 1 }
        XCTAssertEqual(actionCount, 1)
        XCTAssertEqual(policy.reasons, ["export", "export"])
    }

    func testNetworkServiceWaitForConnectionReturnsFalseWhenCancelledBeforePolling() async {
        let service = NetworkService(monitor: NetworkMonitor())
        let task = Task { @MainActor in
            await Task.yield()
            return await service.waitForConnection(timeout: 3)
        }
        task.cancel()

        let result = await task.value
        XCTAssertFalse(result)
    }
}

@MainActor
private final class TestAccessPolicy: SFKAccessPolicy {
    var isProEnabled: Bool
    private(set) var reasons: [String] = []

    init(isProEnabled: Bool) {
        self.isProEnabled = isProEnabled
    }

    func presentUpgrade(for reason: String) {
        reasons.append(reason)
    }
}

#if canImport(UIKit) && !os(watchOS)
@MainActor
final class V4MediaSeamsTests: XCTestCase {
    func testMemoryImageCacheStoresAndRemovesImages() {
        let cache = SFKMemoryImageCache()
        let image = Self.makeImage()

        cache.insert(image, forKey: "avatar")
        XCTAssertNotNil(cache.image(forKey: "avatar"))
        cache.removeImage(forKey: "avatar")
        XCTAssertNil(cache.image(forKey: "avatar"))
    }

    func testDefaultImageTransformerResizesImage() {
        let image = Self.makeImage(size: CGSize(width: 4, height: 2))
        let transformed = SFKDefaultImageTransformer().resize(
            image,
            to: CGSize(width: 2, height: 3),
            quality: 0.8
        )

        XCTAssertEqual(transformed?.size, CGSize(width: 2, height: 3))
    }

    func testRemoteImageLoaderUsesInjectedTransportAndDecodesBytes() async throws {
        let url = URL(string: "https://images.example.com/avatar.png")!
        let transport = LoaderTransport(data: Self.makeImage().pngData()!)
        let loader = SFKRemoteImageLoader(transport: transport)

        let image = try await loader.load(from: url)

        XCTAssertEqual(image.size, CGSize(width: 2, height: 2))
        XCTAssertEqual(transport.requestedURLs, [url])
    }

    private static func makeImage(size: CGSize = CGSize(width: 2, height: 2)) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        return renderer.image { context in
            UIColor.systemBlue.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }
    }
}

private final class LoaderTransport: ImageProcessorTransport, @unchecked Sendable {
    private let imageData: Data
    private let lock = NSLock()
    private var urls: [URL] = []

    var requestedURLs: [URL] {
        lock.lock()
        defer { lock.unlock() }
        return urls
    }

    init(data: Data) {
        self.imageData = data
    }

    func data(from url: URL) async throws -> (Data, HTTPURLResponse) {
        record(url)
        let response = HTTPURLResponse(
            url: url,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!
        return (imageData, response)
    }

    private func record(_ url: URL) {
        lock.lock()
        urls.append(url)
        lock.unlock()
    }
}
#endif
