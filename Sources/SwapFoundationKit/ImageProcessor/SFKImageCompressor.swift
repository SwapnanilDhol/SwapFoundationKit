#if canImport(UIKit) && os(iOS)
import UIKit
import UniformTypeIdentifiers

/// Compresses and resizes images for storage or network transfer.
///
/// Resizes images to fit within a configurable maximum dimension (default 256pt)
/// while maintaining aspect ratio, then outputs JPEG data at the configured quality (default 0.7).
///
/// ## Usage
/// ```swift
/// guard let jpegData = SFKImageCompressor.compress(myImage) else { return }
/// // Store jpegData or upload it
/// ```
public enum SFKImageCompressor {
    public static var maxDimension: CGFloat = 256
    public static var compressionQuality: CGFloat = 0.7

    /// Compresses an image to JPEG data, resizing to fit within `maxDimension`.
    /// - Parameter image: The source image.
    /// - Returns: Compressed JPEG data, or `nil` if compression fails.
    public static func compress(_ image: UIImage) -> Data? {
        let resizedImage = resize(image, maxDimension: maxDimension)
        return resizedImage.jpegData(compressionQuality: compressionQuality)
    }

    /// Compresses an image to a target maximum file size in bytes.
    ///
    /// Iteratively reduces JPEG quality until the output fits within `maxBytes`.
    /// Falls back to the configured `compressionQuality` floor.
    /// - Parameters:
    ///   - image: The source image.
    ///   - maxBytes: The target maximum size in bytes.
    /// - Returns: Compressed JPEG data, or `nil` if compression fails.
    public static func compressToSize(_ image: UIImage, maxBytes: Int) -> Data? {
        compressToSize(
            image,
            maxBytes: maxBytes,
            maxDimension: maxDimension,
            quality: compressionQuality,
            qualityFloor: 0.1
        )
    }

    /// Compresses an image to a target maximum file size using per-call options.
    ///
    /// This overload does not read or mutate the process-wide defaults, which makes
    /// it safe for concurrent callers with different image policies.
    /// - Parameters:
    ///   - image: The source image.
    ///   - maxBytes: The target maximum size in bytes.
    ///   - maxDimension: The maximum width or height after resizing.
    ///   - quality: The initial JPEG quality.
    ///   - qualityFloor: The lowest JPEG quality to try.
    /// - Returns: Compressed JPEG data, or `nil` if compression fails.
    public static func compressToSize(
        _ image: UIImage,
        maxBytes: Int,
        maxDimension: CGFloat,
        quality: CGFloat,
        qualityFloor: CGFloat = 0.1
    ) -> Data? {
        let resizedImage = resize(
            image,
            maxDimension: max(1, maxDimension)
        )
        var quality = min(1, max(0, quality))
        let floor = min(quality, max(0.1, min(1, qualityFloor)))
        var data = resizedImage.jpegData(compressionQuality: quality)
        while let currentData = data, currentData.count > maxBytes, quality > floor {
            quality = max(floor, quality - 0.1)
            data = resizedImage.jpegData(compressionQuality: quality)
        }
        return data
    }

    private static func resize(_ image: UIImage, maxDimension: CGFloat) -> UIImage {
        let originalSize = image.size
        guard originalSize.width > maxDimension || originalSize.height > maxDimension else {
            return image
        }

        let widthRatio = maxDimension / originalSize.width
        let heightRatio = maxDimension / originalSize.height
        let ratio = min(widthRatio, heightRatio)

        let newSize = CGSize(
            width: originalSize.width * ratio,
            height: originalSize.height * ratio
        )

        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}
#endif
