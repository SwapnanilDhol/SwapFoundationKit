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

/// Service for image processing, manipulation, and caching
/// Note: This service is only available on iOS, watchOS, and tvOS
@MainActor
public class ImageProcessor {
    public static let shared = ImageProcessor()

    private let cache = NSCache<NSString, UIImage>()
    private let fileManager = FileManager.default

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

    private init() {
        setupCache()
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

            // Create the shared cache directory if it doesn't exist
            if let cacheURL = sharedCacheDirectoryURL {
                try? fileManager.createDirectory(at: cacheURL, withIntermediateDirectories: true, attributes: nil)
            }
        } else {
            self.appGroupIdentifier = nil
        }
    }

    private func setupCache() {
        cache.countLimit = 100
        cache.totalCostLimit = 50 * 1024 * 1024 // 50MB
    }
    
    // MARK: - Image Processing
    
    /// Resizes an image to the specified size
    /// - Parameters:
    ///   - image: The image to resize
    ///   - size: The target size
    ///   - quality: The quality of the resized image (0.0 to 1.0)
    /// - Returns: The resized image
    public func resize(_ image: UIImage, to size: CGSize, quality: CGFloat = 1.0) -> UIImage? {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1.0
        
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        return renderer.image { context in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
    }
    
    /// Rounds the corners of an image
    /// - Parameters:
    ///   - image: The image to round
    ///   - radius: The corner radius
    /// - Returns: The rounded image
    public func roundCorners(_ image: UIImage, radius: CGFloat) -> UIImage? {
        let format = UIGraphicsImageRendererFormat()
        format.scale = image.scale
        
        let renderer = UIGraphicsImageRenderer(size: image.size, format: format)
        return renderer.image { context in
            let rect = CGRect(origin: .zero, size: image.size)
            let path = UIBezierPath(roundedRect: rect, cornerRadius: radius)
            path.addClip()
            image.draw(in: rect)
        }
    }
    
    /// Converts an image to grayscale
    /// - Parameter image: The image to convert
    /// - Returns: The grayscale image
    public func toGrayscale(_ image: UIImage) -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }
        
        let colorSpace = CGColorSpaceCreateDeviceGray()
        let context = CGContext(data: nil, width: cgImage.width, height: cgImage.height, bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: CGImageAlphaInfo.none.rawValue)
        
        context?.draw(cgImage, in: CGRect(x: 0, y: 0, width: cgImage.width, height: cgImage.height))
        guard let grayscaleImage = context?.makeImage() else { return nil }
        
        return UIImage(cgImage: grayscaleImage)
    }
    
    /// Applies a blur effect to an image
    /// - Parameters:
    ///   - image: The image to blur
    ///   - style: The blur style
    /// - Returns: The blurred image
    public func applyBlur(_ image: UIImage, style: UIBlurEffect.Style = .light) -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }
        
        let ciImage = CIImage(cgImage: cgImage)
        let filter = CIFilter(name: "CIGaussianBlur")
        filter?.setValue(ciImage, forKey: kCIInputImageKey)
        filter?.setValue(10.0, forKey: kCIInputRadiusKey)
        
        guard let outputImage = filter?.outputImage else { return nil }
        
        let context = CIContext(options: nil)
        guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else { return nil }
        
        return UIImage(cgImage: cgImage)
    }
    
    // MARK: - Caching
    
    /// Caches an image with the specified key
    /// - Parameters:
    ///   - image: The image to cache
    ///   - key: The cache key
    public func cacheImage(_ image: UIImage, forKey key: String) {
        cache.setObject(image, forKey: key as NSString)
    }
    
    /// Retrieves a cached image for the specified key
    /// - Parameter key: The cache key
    /// - Returns: The cached image if available
    public func cachedImage(forKey key: String) -> UIImage? {
        return cache.object(forKey: key as NSString)
    }
    
    /// Removes a cached image for the specified key
    /// - Parameter key: The cache key
    public func removeCachedImage(forKey key: String) {
        cache.removeObject(forKey: key as NSString)
    }
    
    /// Clears all cached images
    public func clearCache() {
        cache.removeAllObjects()
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
    /// - Parameters:
    ///   - url: The remote image URL to fetch.
    ///   - targetSize: Optional target size to resize the image before caching.
    ///   - quality: JPEG compression quality used for shared storage persistence.
    /// - Returns: The processed image.
    /// - Throws: `ImageProcessorError` if downloading or decoding fails.
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
            let (data, _) = try await URLSession.shared.data(from: url)

            guard let image = UIImage(data: data) else {
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

        guard let cacheDirectoryURL = sharedCacheDirectoryURL else {
            throw ImageProcessorError.sharedStorageNotConfigured
        }

        // Create a safe filename from the key
        let safeFileName = key.replacingOccurrences(of: "/", with: "-")
        let fileURL = cacheDirectoryURL.appendingPathComponent(safeFileName)

        guard let data = image.jpegData(compressionQuality: quality) else {
            throw ImageProcessorError.compressionFailed
        }

        try data.write(to: fileURL)
    }

    /// Retrieves a cached image from shared app group storage
    /// - Parameter key: The cache key
    /// - Returns: The cached image if available
    public func cachedImageFromSharedStorage(forKey key: String) -> UIImage? {
        guard shouldCacheToSharedStorage else {
            return nil
        }

        guard let cacheDirectoryURL = sharedCacheDirectoryURL else {
            return nil
        }

        let safeFileName = key.replacingOccurrences(of: "/", with: "-")
        let fileURL = cacheDirectoryURL.appendingPathComponent(safeFileName)

        guard let data = try? Data(contentsOf: fileURL),
              let image = UIImage(data: data) else {
            return nil
        }

        return image
    }

    /// Removes a cached image from shared app group storage
    /// - Parameter key: The cache key
    public func removeCachedImageFromSharedStorage(forKey key: String) {
        guard shouldCacheToSharedStorage,
              let cacheDirectoryURL = sharedCacheDirectoryURL else {
            return
        }

        let safeFileName = key.replacingOccurrences(of: "/", with: "-")
        let fileURL = cacheDirectoryURL.appendingPathComponent(safeFileName)

        try? fileManager.removeItem(at: fileURL)
    }

    /// Clears all cached images from shared app group storage
    public func clearSharedStorageCache() {
        guard shouldCacheToSharedStorage,
              let cacheDirectoryURL = sharedCacheDirectoryURL else {
            return
        }

        try? fileManager.removeItem(at: cacheDirectoryURL)
        try? fileManager.createDirectory(at: cacheDirectoryURL, withIntermediateDirectories: true, attributes: nil)
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
        case .downloadFailed(let error):
            return "Failed to download remote image: \(error.localizedDescription)"
        }
    }
}

#endif
