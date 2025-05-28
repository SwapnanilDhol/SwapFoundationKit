import Foundation

/// A generic backup service for saving Encodable data to disk with file retention management.
///
/// - Supports backing up any Encodable type to a specified directory.
/// - Manages a maximum number of backup files, deleting the oldest when the limit is exceeded.
/// - Allows custom file naming and backup directory.
/// - Supports listing and restoring backups.
public final class GenericBackupService<T: Codable> {
    public typealias FileNameProvider = (T) -> String

    private let directoryName: String
    private let maxFileCount: Int
    private let fileNameProvider: FileNameProvider
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    /// Initializes the backup service.
    /// - Parameters:
    ///   - directoryName: The name of the directory to store backups in (within the user's documents directory).
    ///   - maxFileCount: The maximum number of backup files to retain.
    ///   - fileNameProvider: A closure to generate a file name for each backup.
    ///   - encoder: The JSONEncoder to use (default: .init()).
    ///   - decoder: The JSONDecoder to use (default: .init()).
    public init(
        directoryName: String,
        maxFileCount: Int = 10,
        fileNameProvider: @escaping FileNameProvider,
        encoder: JSONEncoder = .init(),
        decoder: JSONDecoder = .init()
    ) {
        self.directoryName = directoryName
        self.maxFileCount = maxFileCount
        self.fileNameProvider = fileNameProvider
        self.encoder = encoder
        self.decoder = decoder
    }

    /// Performs a backup of the provided value asynchronously.
    /// - Parameter value: The value to backup.
    public func performBackup(_ value: T) async {
        await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    try self.backup(value)
                    continuation.resume()
                } catch {
                    Logger.error("[BackupService] Backup failed: \(error)")
                    continuation.resume()
                }
            }
        }
    }

    /// Performs a backup of the provided value synchronously.
    /// - Parameter value: The value to backup.
    /// - Throws: Any error encountered during encoding or file writing.
    public func backup(_ value: T) throws {
        let fileName = fileNameProvider(value)
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw NSError(domain: "GenericBackupService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Could not find documents directory."])
        }
        let directoryURL = documentsDirectory.appendingPathComponent(directoryName)
        if !FileManager.default.fileExists(atPath: directoryURL.path) {
            try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true, attributes: nil)
        }
        try manageFilesInFolder(directoryURL: directoryURL)
        let fileURL = directoryURL.appendingPathComponent(fileName)
        let data = try encoder.encode(value)
        try data.write(to: fileURL)
    }

    /// Lists all backup file URLs in the backup directory, sorted by creation date (newest first).
    public func listBackups() -> [URL] {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return []
        }
        let directoryURL = documentsDirectory.appendingPathComponent(directoryName)
        guard FileManager.default.fileExists(atPath: directoryURL.path) else { return [] }
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: directoryURL, includingPropertiesForKeys: [.creationDateKey])
            return fileURLs.sorted { (url1, url2) -> Bool in
                let date1 = (try? url1.resourceValues(forKeys: [.creationDateKey]).creationDate) ?? .distantPast
                let date2 = (try? url2.resourceValues(forKeys: [.creationDateKey]).creationDate) ?? .distantPast
                return date1 > date2 // Newest first
            }
        } catch {
            Logger.error("[BackupService] Failed to list backups: \(error)")
            return []
        }
    }

    /// Returns the most recent backup file URL, or nil if none exist.
    public func latestBackup() -> URL? {
        listBackups().first
    }

    /// Restores a backup from the given file URL.
    /// - Parameter url: The URL of the backup file.
    /// - Returns: The decoded value of type T.
    /// - Throws: Any error encountered during decoding or file reading.
    public func restore(from url: URL) throws -> T {
        let data = try Data(contentsOf: url)
        return try decoder.decode(T.self, from: data)
    }

    /// Manages the number of files in the backup directory, deleting the oldest if the limit is exceeded.
    /// - Parameter directoryURL: The URL of the backup directory.
    private func manageFilesInFolder(directoryURL: URL) throws {
        let fileURLs = try FileManager.default.contentsOfDirectory(at: directoryURL, includingPropertiesForKeys: [.creationDateKey])
        if fileURLs.count > maxFileCount {
            let sortedFiles = fileURLs.sorted { (url1, url2) -> Bool in
                let date1 = (try? url1.resourceValues(forKeys: [.creationDateKey]).creationDate) ?? .distantPast
                let date2 = (try? url2.resourceValues(forKeys: [.creationDateKey]).creationDate) ?? .distantPast
                return date1 < date2
            }
            for i in 0..<(fileURLs.count - maxFileCount) {
                try FileManager.default.removeItem(at: sortedFiles[i])
                Logger.info("[BackupService] Removed oldest backup: \(sortedFiles[i].lastPathComponent)")
            }
        }
    }
}

// MARK: - Example FileNameProvider
public extension GenericBackupService {
    /// Returns a timestamped file name for the backup, with the given prefix and extension.
    static func timestampedFileName(prefix: String, ext: String = "json") -> (T) -> String {
        return { _ in
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyyMMdd_HHmmss"
            let timestamp = dateFormatter.string(from: Date())
            return "\(prefix)-\(timestamp).\(ext)"
        }
    }
} 
