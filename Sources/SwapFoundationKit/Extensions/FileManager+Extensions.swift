import Foundation

// MARK: - FileManager+Extensions

extension FileManager {
    /// Returns the URL for the app's Documents directory
    var documentsDirectory: URL {
        urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    /// Returns the URL for the app's Caches directory
    var cachesDirectory: URL {
        urls(for: .cachesDirectory, in: .userDomainMask)[0]
    }

    /// Returns the URL for the app's Temporary directory
    var temporaryDirectory: URL {
        URL(fileURLWithPath: NSTemporaryDirectory())
    }

    /// Returns the file size in bytes at the given path
    func fileSize(at path: String) -> Int64 {
        guard let attributes = try? attributesOfItem(atPath: path),
              let size = attributes[.size] as? Int64 else {
            return 0
        }
        return size
    }

    /// Returns the formatted file size string (e.g., "1.5 MB")
    func fileSizeFormatted(at path: String) -> String {
        let size = fileSize(at: path)
        return ByteCountFormatter.string(fromByteCount: size, countStyle: .file)
    }

    /// Returns the total size of all files in a directory
    func directorySize(at url: URL) -> Int64 {
        guard let enumerator = enumerator(at: url, includingPropertiesForKeys: [.fileSizeKey]) else {
            return 0
        }

        var totalSize: Int64 = 0
        for case let fileURL as URL in enumerator {
            guard let resourceValues = try? fileURL.resourceValues(forKeys: [.fileSizeKey]),
                  let fileSize = resourceValues.fileSize else {
                continue
            }
            totalSize += Int64(fileSize)
        }
        return totalSize
    }

    /// Creates a directory at the given URL if it doesn't exist
    func createDirectoryIfNeeded(at url: URL) throws {
        if !fileExists(atPath: url.path) {
            try createDirectory(at: url, withIntermediateDirectories: true)
        }
    }

    /// Removes an item at the given URL safely, ignoring errors
    @discardableResult
    func removeItemSafely(at url: URL) -> Bool {
        return (try? removeItem(at: url)) != nil
    }

    /// Checks if a file exists at the given URL
    func fileExists(at url: URL) -> Bool {
        fileExists(atPath: url.path)
    }

    /// Moves a file from source to destination
    func moveFile(from source: URL, to destination: URL) throws {
        if fileExists(at: destination) {
            try removeItem(at: destination)
        }
        try moveItem(at: source, to: destination)
    }

    /// Copies a file from source to destination
    func copyFile(from source: URL, to destination: URL) throws {
        if fileExists(at: destination) {
            try removeItem(at: destination)
        }
        try copyItem(at: source, to: destination)
    }
}
