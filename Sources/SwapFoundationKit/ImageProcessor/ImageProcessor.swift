import UIKit
import Foundation

/// Service for image processing, manipulation, and caching
public class ImageProcessor {
    public static let shared = ImageProcessor()
    
    private let cache = NSCache<NSString, UIImage>()
    private let fileManager = FileManager.default
    
    private init() {
        setupCache()
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
}

// MARK: - ImageProcessor Errors
public enum ImageProcessorError: Error, LocalizedError {
    case documentsDirectoryNotFound
    case compressionFailed
    case loadFailed
    
    public var errorDescription: String? {
        switch self {
        case .documentsDirectoryNotFound:
            return "Documents directory not found"
        case .compressionFailed:
            return "Failed to compress image"
        case .loadFailed:
            return "Failed to load image"
        }
    }
}
