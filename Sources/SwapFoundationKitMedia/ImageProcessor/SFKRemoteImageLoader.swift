import Foundation
import UIKit

/// Fetches and decodes one remote image without requiring cache or app-group configuration.
@MainActor
public final class SFKRemoteImageLoader {
    public enum Error: Swift.Error {
        case invalidImageData
    }

    private let transport: any ImageProcessorTransport

    public init(transport: any ImageProcessorTransport) {
        self.transport = transport
    }

    public func load(from url: URL) async throws -> UIImage {
        let (data, _) = try await transport.data(from: url)
        guard let image = UIImage(data: data) else {
            throw Error.invalidImageData
        }
        return image
    }
}
