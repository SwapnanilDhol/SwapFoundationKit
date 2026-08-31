import Foundation
import UIKit

/// Persistent image-store seam. Implementations own the container and filename policy;
/// `ImageProcessor` keeps the public cache key and compression behavior unchanged.
@MainActor
public protocol SFKImageStorage: AnyObject {
    func configure(appGroupIdentifier: String?)
    func save(_ image: UIImage, forKey key: String, quality: CGFloat) throws
    func image(forKey key: String) -> UIImage?
    func removeImage(forKey key: String)
    func removeAllImages()
}

public enum SFKImageStorageError: Error {
    case notConfigured
    case compressionFailed
}

/// App-group-backed image store matching the legacy `ImageProcessor` key layout.
@MainActor
public final class SFKAppGroupImageStorage: SFKImageStorage {
    private let fileManager: FileManager
    private var appGroupIdentifier: String?

    public init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }

    public func configure(appGroupIdentifier: String?) {
        self.appGroupIdentifier = appGroupIdentifier
        if let directoryURL {
            try? fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)
        }
    }

    public func save(_ image: UIImage, forKey key: String, quality: CGFloat) throws {
        guard let directoryURL else { throw SFKImageStorageError.notConfigured }
        guard let data = image.jpegData(compressionQuality: quality) else {
            throw SFKImageStorageError.compressionFailed
        }
        try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)
        try data.write(to: fileURL(forKey: key))
    }

    public func image(forKey key: String) -> UIImage? {
        guard directoryURL != nil,
              let data = try? Data(contentsOf: fileURL(forKey: key)) else { return nil }
        return UIImage(data: data)
    }

    public func removeImage(forKey key: String) {
        guard directoryURL != nil else { return }
        try? fileManager.removeItem(at: fileURL(forKey: key))
    }

    public func removeAllImages() {
        guard let directoryURL else { return }
        try? fileManager.removeItem(at: directoryURL)
        try? fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)
    }

    private var directoryURL: URL? {
        guard let appGroupIdentifier,
              let containerURL = fileManager.containerURL(
                forSecurityApplicationGroupIdentifier: appGroupIdentifier
              ) else { return nil }
        return containerURL.appendingPathComponent("ImageCache")
    }

    private func fileURL(forKey key: String) -> URL {
        directoryURL!.appendingPathComponent(key.replacingOccurrences(of: "/", with: "-"))
    }
}
