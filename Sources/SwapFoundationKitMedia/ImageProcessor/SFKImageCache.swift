import UIKit

/// In-memory image cache seam used by `ImageProcessor`.
@MainActor
public protocol SFKImageCache: AnyObject {
    func image(forKey key: String) -> UIImage?
    func insert(_ image: UIImage, forKey key: String)
    func removeImage(forKey key: String)
    func removeAllImages()
}

/// Bounded `NSCache` implementation used by the default media pipeline.
@MainActor
public final class SFKMemoryImageCache: SFKImageCache {
    private let cache = NSCache<NSString, UIImage>()

    public init(countLimit: Int = 100, totalCostLimit: Int = 50 * 1024 * 1024) {
        cache.countLimit = countLimit
        cache.totalCostLimit = totalCostLimit
    }

    public func image(forKey key: String) -> UIImage? {
        cache.object(forKey: key as NSString)
    }

    public func insert(_ image: UIImage, forKey key: String) {
        cache.setObject(image, forKey: key as NSString)
    }

    public func removeImage(forKey key: String) {
        cache.removeObject(forKey: key as NSString)
    }

    public func removeAllImages() {
        cache.removeAllObjects()
    }
}
