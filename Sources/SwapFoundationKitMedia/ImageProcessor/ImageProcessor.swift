/*****************************************************************************
 * ImageProcessor.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2025 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

#if canImport(UIKit) && !os(watchOS)
import UIKit
import Foundation
import SwapFoundationKitNetworking

/// Service for image processing, manipulation, and caching
/// Note: This service is only available on iOS, watchOS, and tvOS
@MainActor
public class ImageProcessor {
    public static let shared = ImageProcessor()

    private let cache: any SFKImageCache
    private let fileManager = FileManager.default
    private let remoteImageLoader: SFKRemoteImageLoader
    private let sharedStorage: any SFKImageStorage
    private let transformer: any SFKImageTransforming

    // MARK: - Shared Storage Configuration

    /// Whether to cache images to shared app group storage
    public var shouldCacheToSharedStorage: Bool = false

    /// The app group identifier used for shared storage
    public private(set) var appGroupIdentifier: String?

    /// The cache directory URL for shared storage
    private var sharedCacheDirectoryURL: URL? {
        guard let appGroupIdentifier = appGroupIdentifier,
              let sharedContainerURL = fileManager.containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier) else {
            return nil
        }
        return sharedContainerURL.appendingPathComponent("ImageCache")
    }

    /// - Parameter transport: Fetches remote image bytes. Defaults to the package's canonical
    ///   `HTTPClient` (feature code must not call `URLSession.shared` directly — see the v4
    ///   Media ownership rule). The compatibility facade keeps its transport fixed after
    ///   initialization; callers can inject a transport and the other pipeline seams here.
    public init(
        transport: any ImageProcessorTransport = HTTPClientImageTransport(client: .shared),
        cache: (any SFKImageCache)? = nil,
        sharedStorage: (any SFKImageStorage)? = nil,
        transformer: (any SFKImageTransforming)? = nil
    ) {
        self.remoteImageLoader = SFKRemoteImageLoader(transport: transport)
        // Construct actor-isolated defaults inside the @MainActor initializer rather than in
        // default arguments, so callers from nonisolated contexts can still create the facade.
        self.cache = cache ?? SFKMemoryImageCache()
        self.sharedStorage = sharedStorage ?? SFKAppGroupImageStorage()
        self.transformer = transformer ?? SFKDefaultImageTransformer()
    }

    // MARK: - Configuration

    /// Configures the image processor with shared storage settings
    /// - Parameters:
    ///   - shouldCacheToSharedStorage: Whether to enable caching to app group shared storage
    ///   - appGroupIdentifier: The app group identifier for shared storage (required if shouldCacheToSharedStorage is true)
    public func configure(shouldCacheToSharedStorage: Bool, appGroupIdentifier: String?) {
        self.shouldCacheToSharedStorage = shouldCacheToSharedStorage

        if shouldCacheToSharedStorage {
            guard let appGroupIdentifier = appGroupIdentifier, !appGroupIdentifier.isEmpty else {
                return
            }
            self.appGroupIdentifier = appGroupIdentifier
            sharedStorage.configure(appGroupIdentifier: appGroupIdentifier)

            // Create the shared cache directory if it doesn't exist
            if let cacheURL = sharedCacheDirectoryURL {
                try? fileManager.createDirectory(at: cacheURL, withIntermediateDirectories: true, attributes: nil)
            }
        } else {
            self.appGroupIdentifier = nil
            sharedStorage.configure(appGroupIdentifier: nil)
        }
    }

    // MARK: - Image Processing
    
    /// Resizes an image to the specified size
    /// - Parameters:
    ///   - image: The image to resize
    ///   - size: The target size
    ///   - quality: The quality of the resized image (0.0 to 1.0)
    /// - Returns: The resized image
    public func resize(_ image: UIImage, to size: CGSize, quality: CGFloat = 1.0) -> UIImage? {
        transformer.resize(image, to: size, quality: quality)
    }
    
    /// Rounds the corners of an image
    /// - Parameters:
    ///   - image: The image to round
    ///   - radius: The corner radius
    /// - Returns: The rounded image
    public func roundCorners(_ image: UIImage, radius: CGFloat) -> UIImage? {
        transformer.roundCorners(image, radius: radius)
    }
    
    /// Converts an image to grayscale
    /// - Parameter image: The image to convert
    /// - Returns: The grayscale image
    public func toGrayscale(_ image: UIImage) -> UIImage? {
        transformer.toGrayscale(image)
    }
    
    /// Applies a blur effect to an image
    /// - Parameters:
    ///   - image: The image to blur
    ///   - style: The blur style
    /// - Returns: The blurred image
    public func applyBlur(_ image: UIImage, style: UIBlurEffect.Style = .light) -> UIImage? {
        transformer.applyBlur(image, style: style)
    }
    
    // MARK: - Caching
    
    /// Caches an image with the specified key
    /// - Parameters:
    ///   - image: The image to cache
    ///   - key: The cache key
    public func cacheImage(_ image: UIImage, forKey key: String) {
        cache.insert(image, forKey: key)
    }
    
    /// Retrieves a cached image for the specified key
    /// - Parameter key: The cache key
    /// - Returns: The cached image if available
    public func cachedImage(forKey key: String) -> UIImage? {
        return cache.image(forKey: key)
    }
    
    /// Removes a cached image for the specified key
    /// - Parameter key: The cache key
    public func removeCachedImage(forKey key: String) {
        cache.removeImage(forKey: key)
    }
    
    /// Clears all cached images
    public func clearCache() {
        cache.removeAllImages()
    }

    /// Creates a stable cache key for a remote image URL.
    /// - Parameter url: The remote image URL.
    /// - Returns: A stable cache key derived from the URL.
    public func cacheKey(for url: URL) -> String {
        url.absoluteString
    }

    /// Retrieves a cached image for the specified remote URL.
    ///
    /// This checks both in-memory cache and shared app group storage when configured.
    /// When `targetSize` is provided, the image is resized before being returned and
    /// the size is incorporated into the underlying cache key.
    ///
    /// - Parameters:
    ///   - url: The remote image URL used to derive the cache key.
    ///   - targetSize: Optional target size to look up a resized variant.
    /// - Returns: The cached image if available.
    public func cachedImage(from url: URL, targetSize: CGSize? = nil) -> UIImage? {
        let key = cacheKey(for: url, targetSize: targetSize)

        if let memoryImage = cachedImage(forKey: key) {
            return memoryImage
        }

        return cachedImageFromSharedStorage(forKey: key)
    }

    /// Downloads, processes, and caches a remote image.
    ///
    /// This stores the processed image in memory cache and, when shared storage is
    /// configured, also persists it to the app group container for widgets/extensions.
    ///
    /// Fetches go through `HTTPClient` (via the injected transport), not `URLSession.shared`. A
    /// non-2xx HTTP response is treated as `.downloadFailed`, not `.invalidRemoteImageData`: we
    /// never received usable image bytes, so it's a download failure rather than a decode failure.
    ///
    /// - Parameters:
    ///   - url: The remote image URL to fetch.
    ///   - targetSize: Optional target size to resize the image before caching.
    ///   - quality: JPEG compression quality used for shared storage persistence.
    /// - Returns: The processed image.
    /// - Throws: `ImageProcessorError.downloadFailed` if the transport fails or the response is
    ///   non-2xx; `ImageProcessorError.invalidRemoteImageData` if a 2xx response body cannot be
    ///   decoded as an image.
    @discardableResult
    public func cacheImage(
        from url: URL,
        targetSize: CGSize? = nil,
        quality: CGFloat = 0.8
    ) async throws -> UIImage? {
        if let cached = cachedImage(from: url, targetSize: targetSize) {
            return cached
        }

        let key = cacheKey(for: url, targetSize: targetSize)

        do {
            let image: UIImage
            do {
                image = try await remoteImageLoader.load(from: url)
            } catch SFKRemoteImageLoader.Error.invalidImageData {
                throw ImageProcessorError.invalidRemoteImageData
            }

            let processedImage = targetSize.flatMap { resize(image, to: $0, quality: quality) } ?? image

            cacheImage(processedImage, forKey: key)

            if shouldCacheToSharedStorage {
                try cacheImageToSharedStorage(processedImage, forKey: key, quality: quality)
            }

            return processedImage
        } catch let error as ImageProcessorError {
            throw error
        } catch let error as NetworkError {
            // Routing through `HTTPClient` means a non-2xx response (e.g. a 404 error page)
            // throws `NetworkError.httpError` before we ever see response bytes, instead of
            // falling through to `UIImage(data:)` and failing decode as `.invalidRemoteImageData`
            // the way the old direct `URLSession.shared.data(from:)` call did. We deliberately
            // surface this as `.downloadFailed` (we never received usable image bytes) rather
            // than `.invalidRemoteImageData` (bytes were received but weren't a decodable image),
            // so callers can tell "server refused/failed to serve the image" apart from
            // "server returned garbage".
            throw ImageProcessorError.downloadFailed(error)
        } catch {
            throw ImageProcessorError.downloadFailed(error)
        }
    }

    // MARK: - Shared Storage Caching

    /// Caches an image to shared app group storage
    /// - Parameters:
    ///   - image: The image to cache
    ///   - key: The cache key (used as filename)
    ///   - quality: The compression quality (0.0 to 1.0)
    /// - Throws: Error if caching to shared storage is not configured or fails
    public func cacheImageToSharedStorage(_ image: UIImage, forKey key: String, quality: CGFloat = 0.8) throws {
        guard shouldCacheToSharedStorage else {
            throw ImageProcessorError.sharedStorageNotConfigured
        }

        do {
            try sharedStorage.save(image, forKey: key, quality: quality)
        } catch SFKImageStorageError.notConfigured {
            throw ImageProcessorError.sharedStorageNotConfigured
        } catch SFKImageStorageError.compressionFailed {
            throw ImageProcessorError.compressionFailed
        }
    }

    /// Retrieves a cached image from shared app group storage
    /// - Parameter key: The cache key
    /// - Returns: The cached image if available
    public func cachedImageFromSharedStorage(forKey key: String) -> UIImage? {
        guard shouldCacheToSharedStorage else {
            return nil
        }

        return sharedStorage.image(forKey: key)
    }

    /// Removes a cached image from shared app group storage
    /// - Parameter key: The cache key
    public func removeCachedImageFromSharedStorage(forKey key: String) {
        guard shouldCacheToSharedStorage else {
            return
        }
        sharedStorage.removeImage(forKey: key)
    }

    /// Clears all cached images from shared app group storage
    public func clearSharedStorageCache() {
        guard shouldCacheToSharedStorage else {
            return
        }
        sharedStorage.removeAllImages()
    }

    // MARK: - File Operations
    
    /// Saves an image to the documents directory
    /// - Parameters:
    ///   - image: The image to save
    ///   - filename: The filename
    ///   - quality: The compression quality (0.0 to 1.0)
    /// - Returns: The URL where the image was saved
    public func saveImage(_ image: UIImage, filename: String, quality: CGFloat = 0.8) throws -> URL {
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw ImageProcessorError.documentsDirectoryNotFound
        }
        
        let fileURL = documentsDirectory.appendingPathComponent(filename)
        guard let data = image.jpegData(compressionQuality: quality) else {
            throw ImageProcessorError.compressionFailed
        }
        
        try data.write(to: fileURL)
        return fileURL
    }
    
    /// Loads an image from the documents directory
    /// - Parameter filename: The filename
    /// - Returns: The loaded image
    public func loadImage(filename: String) throws -> UIImage {
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw ImageProcessorError.documentsDirectoryNotFound
        }
        
        let fileURL = documentsDirectory.appendingPathComponent(filename)
        guard let data = try? Data(contentsOf: fileURL),
              let image = UIImage(data: data) else {
            throw ImageProcessorError.loadFailed
        }
        
        return image
    }

    private func cacheKey(for url: URL, targetSize: CGSize?) -> String {
        guard let targetSize else {
            return cacheKey(for: url)
        }

        let width = Int(targetSize.width.rounded())
        let height = Int(targetSize.height.rounded())
        return "\(cacheKey(for: url))::\(width)x\(height)"
    }
}

// MARK: - ImageProcessor Errors
public enum ImageProcessorError: Error, LocalizedError {
    case documentsDirectoryNotFound
    case compressionFailed
    case loadFailed
    case sharedStorageNotConfigured
    case invalidRemoteImageData
    case downloadFailed(Error)

    public var errorDescription: String? {
        switch self {
        case .documentsDirectoryNotFound:
            return "Documents directory not found"
        case .compressionFailed:
            return "Failed to compress image"
        case .loadFailed:
            return "Failed to load image"
        case .sharedStorageNotConfigured:
            return "Shared storage is not configured. Call configure(shouldCacheToSharedStorage:appGroupIdentifier:) first"
        case .invalidRemoteImageData:
            return "Failed to decode remote image data"
        // Also thrown for non-2xx HTTP responses (surfaced as a wrapped `NetworkError`), e.g. a
        // 404 error page — see the doc comment on `cacheImage(from:targetSize:quality:)`.
        case .downloadFailed(let error):
            return "Failed to download remote image: \(error.localizedDescription)"
        }
    }
}

// MARK: - Remote Image Transport

/// Abstraction over the transport used to fetch remote image bytes, so
/// `cacheImage(from:targetSize:quality:)` can be unit-tested with a fake and production code
/// routes through the package's canonical `HTTPClient` instead of `URLSession.shared` (feature
/// code must not call `URLSession.shared` directly; see the v4 Media ownership rule and
/// `SFKNetworkInstrumentation`, which lets opt-in products like `SwapFoundationKitPulse` observe
/// `HTTPClient` traffic).
public protocol ImageProcessorTransport: Sendable {
    func data(from url: URL) async throws -> (Data, HTTPURLResponse)
}

/// Default `ImageProcessorTransport` backed by the package's canonical `HTTPClient`.
public struct HTTPClientImageTransport: ImageProcessorTransport {
    public let client: HTTPClient

    public init(client: HTTPClient) {
        self.client = client
    }

    public func data(from url: URL) async throws -> (Data, HTTPURLResponse) {
        let response = try await client.execute(RemoteImageFetchRequest(url: url))
        return (response.data, response.response)
    }
}

/// Builds a GET `NetworkRequest` from an arbitrary remote image URL.
///
/// `explicitURL` keeps a presigned/token-signed URL byte-faithful; the decomposed properties stay
/// populated for diagnostics.
private struct RemoteImageFetchRequest: NetworkRequest {
    let scheme: String
    let baseURL: String
    let path: String
    let method: HTTPMethod = .get
    let parameters: [String: String]?
    let headers: [String: String]? = nil
    let body: Data? = nil
    /// Preserves the original 60s `URLSession.shared` session default. Without this, the request
    /// would inherit `NetworkRequest`'s 30s default, halving the timeout and burning retry budget
    /// (see `ExchangeRateManager`, which shares this request-building pattern).
    let timeoutInterval: TimeInterval = 60
    let explicitURL: URL?
    /// `false`: an image fetch must not advertise `Content-Type`/`Accept: application/json`
    /// (`HTTPClient.defaultHeaders`). Leaving `headers` `nil` alongside this reproduces
    /// `URLSession.shared`'s original behavior of sending no `Accept` header at all.
    let usesClientDefaultHeaders: Bool = false

    init(url: URL) {
        self.explicitURL = url
        self.scheme = url.scheme ?? "https"
        let host = url.host ?? ""
        if let port = url.port {
            self.baseURL = "\(host):\(port)"
        } else {
            self.baseURL = host
        }
        self.path = url.path.isEmpty ? "/" : url.path
        self.parameters = Self.queryParameters(from: url)
    }

    private static func queryParameters(from url: URL) -> [String: String]? {
        guard let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: true)?.queryItems else {
            return nil
        }

        var parameters: [String: String] = [:]
        for item in queryItems {
            if let value = item.value {
                parameters[item.name] = value
            }
        }
        return parameters.isEmpty ? nil : parameters
    }
}

#endif
