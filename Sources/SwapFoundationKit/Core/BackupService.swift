/*****************************************************************************
 * BackupService.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2025 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import Foundation

/// Service for handling data backup and export operations.
///
/// Backups are stored under the app Documents directory in a subdirectory named by the ``FileType``’s
/// string raw value (e.g. `Documents/data/`).
/// as timestamped `.backup` JSON files. ``listBackupFiles(for:)`` and ``restoreBackup(_:fileType:decoder:)``
/// use the same layout; ``restoreBackup(_:fileType:decoder:)`` reads the **newest** file for that type
/// (same ordering as ``listBackupFiles(for:)``).
public final class BackupService {

    private let fileManager: FileManager
    /// When non-`nil`, all backup paths resolve under this directory instead of the app sandbox `Documents` folder.
    /// Intended for unit tests; host apps should use the default `nil`.
    private let documentsDirectoryOverride: URL?

    public init(
        fileManager: FileManager = .default,
        documentsDirectoryOverride: URL? = nil
    ) {
        self.fileManager = fileManager
        self.documentsDirectoryOverride = documentsDirectoryOverride
    }

    public enum FileType: String, CaseIterable {
        case data = "data"

        /// Timestamp uses second resolution; two backups in the same second use the same name and the later write replaces the earlier file.
        public var fileName: String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyyMMdd_HHmmss"
            let timestamp = dateFormatter.string(from: Date())
            return "\(rawValue)Backup-\(timestamp).backup"
        }
    }

    public enum BackupError: Error, LocalizedError {
        case encodingFailed
        case writeFailed
        case directoryCreationFailed
        case fileNotFound

        public var errorDescription: String? {
            switch self {
            case .encodingFailed:
                return "Failed to encode data for backup"
            case .writeFailed:
                return "Failed to write backup file"
            case .directoryCreationFailed:
                return "Failed to create backup directory"
            case .fileNotFound:
                return "Backup file not found"
            }
        }
    }

    /// Performs backup of encodable data
    /// - Parameters:
    ///   - data: The data to backup
    ///   - fileType: The type of backup file
    /// - Throws: BackupError
    public func performBackup<T: Encodable & Sendable>(_ data: T, fileType: FileType) async throws {
        try self.backup(encodable: data, item: fileType)
    }

    /// Restores data from the **newest** on-device backup for `fileType`.
    ///
    /// This reads the same files produced by ``performBackup(_:fileType:)`` (under `Documents/<fileType>/`,
    /// or under a custom root directory when the service was constructed with a documents override for tests). The newest file is
    /// chosen using the same ordering as ``listBackupFiles(for:)`` (first element = most recently created).
    /// - Parameters:
    ///   - type: Decodable type stored in the backup JSON (often the same type passed to ``performBackup(_:fileType:)``).
    ///   - fileType: Backup category directory name (e.g. `.data`).
    ///   - decoder: JSON decoder (set date strategies etc. to match the encoder used when writing).
    /// - Returns: The decoded value.
    /// - Throws: `BackupError.fileNotFound` if no backup files exist, or decoding / I/O errors from `Data` / `JSONDecoder`.
    public func restoreBackup<T: Decodable>(_ type: T.Type, fileType: FileType, decoder: JSONDecoder = JSONDecoder()) throws -> T {
        guard let fileURL = latestBackupFileURL(for: fileType) else {
            throw BackupError.fileNotFound
        }
        let data = try Data(contentsOf: fileURL)
        return try decoder.decode(type, from: data)
    }

    /// Lists all backup files for a given type
    /// - Parameter fileType: The type of backup files to list
    /// - Returns: Array of backup file URLs
    public func listBackupFiles(for fileType: FileType) -> [URL] {
        guard let documentsDirectory = resolvedDocumentsDirectory() else {
            return []
        }

        let directoryURL = documentsDirectory.appendingPathComponent(fileType.rawValue)

        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: directoryURL, includingPropertiesForKeys: nil)
            return fileURLs.sorted { url1, url2 in
                do {
                    let attributes1 = try fileManager.attributesOfItem(atPath: url1.path)
                    let attributes2 = try fileManager.attributesOfItem(atPath: url2.path)
                    if let date1 = attributes1[.creationDate] as? Date,
                       let date2 = attributes2[.creationDate] as? Date {
                        return date1 > date2
                    }
                } catch {
                    print("Error getting file attributes:", error.localizedDescription)
                }
                return false
            }
        } catch {
            return []
        }
    }

    // MARK: - Private Methods

    private func resolvedDocumentsDirectory() -> URL? {
        if let documentsDirectoryOverride {
            return documentsDirectoryOverride
        }
        return fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
    }

    private func latestBackupFileURL(for fileType: FileType) -> URL? {
        listBackupFiles(for: fileType).first
    }

    private func backup<T: Encodable>(encodable: T, item: FileType) throws {
        let fileName = item.fileName

        guard let documentsDirectory = resolvedDocumentsDirectory() else {
            throw BackupError.directoryCreationFailed
        }

        let directoryURL = documentsDirectory.appendingPathComponent(item.rawValue)

        if !fileManager.fileExists(atPath: directoryURL.path) {
            try fileManager.createDirectory(
                at: directoryURL,
                withIntermediateDirectories: true,
                attributes: nil
            )
        }

        manageFilesInFolder(item: item)
        let fileURL = directoryURL.appendingPathComponent(fileName)
        let data = try JSONEncoder().encode(encodable)
        try data.write(to: fileURL)
    }

    private func manageFilesInFolder(maxFileCount: Int = 10, item: FileType) {
        guard let documentsDirectory = resolvedDocumentsDirectory() else {
            return
        }

        let directoryURL = documentsDirectory.appendingPathComponent(item.rawValue)

        guard fileManager.fileExists(atPath: directoryURL.path) else {
            return
        }

        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: directoryURL, includingPropertiesForKeys: nil)
            if fileURLs.count > maxFileCount {
                let sortedFiles = fileURLs.sorted { (url1, url2) -> Bool in
                    do {
                        let attributes1 = try fileManager.attributesOfItem(atPath: url1.path)
                        let attributes2 = try fileManager.attributesOfItem(atPath: url2.path)
                        if let date1 = attributes1[.creationDate] as? Date,
                           let date2 = attributes2[.creationDate] as? Date {
                            return date1 < date2
                        }
                    } catch {
                        print("Error getting file attributes:", error.localizedDescription)
                    }
                    return false
                }

                for i in 0..<(fileURLs.count - maxFileCount) {
                    try fileManager.removeItem(at: sortedFiles[i])
                    print("Removed the oldest backup for \(item.fileName)")
                }
            }
        } catch {
            print("Failed while trying to manage files in folder")
        }
    }
}
