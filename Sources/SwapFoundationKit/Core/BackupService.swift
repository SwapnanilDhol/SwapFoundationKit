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

/// Stores timestamped JSON backups under `Documents/<file type>/`.
///
/// Operations are serialized so simultaneous lifecycle and user-initiated backups cannot race.
/// Writes are atomic, ten completed files are retained, and restore walks newest-to-oldest so a
/// partially damaged newest file does not make every older backup unusable.
public final class BackupService: @unchecked Sendable {

    private static let maximumBackupCount = 10

    private let fileManager: FileManager
    private let documentsDirectoryOverride: URL?
    private let queue = DispatchQueue(label: "com.swapfoundationkit.backup-service")

    public init(
        fileManager: FileManager = .default,
        documentsDirectoryOverride: URL? = nil
    ) {
        self.fileManager = fileManager
        self.documentsDirectoryOverride = documentsDirectoryOverride
    }

    public enum FileType: String, CaseIterable, Sendable {
        case data

        public var fileName: String {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            let timestamp = formatter.string(from: Date())
                .replacingOccurrences(of: ":", with: "-")
            return "\(rawValue)Backup-\(timestamp)-\(UUID().uuidString).backup"
        }
    }

    public enum BackupError: Error, LocalizedError {
        case encodingFailed
        case writeFailed
        case directoryCreationFailed
        case fileNotFound
        case noValidBackup(underlying: Error)

        public var errorDescription: String? {
            switch self {
            case .encodingFailed:
                return "Failed to encode data for backup."
            case .writeFailed:
                return "Failed to write the backup file."
            case .directoryCreationFailed:
                return "Failed to resolve the backup directory."
            case .fileNotFound:
                return "No backup file was found."
            case .noValidBackup(let error):
                return "No valid backup could be decoded: \(error.localizedDescription)"
            }
        }
    }

    public func performBackup<T: Encodable & Sendable>(
        _ data: T,
        fileType: FileType
    ) async throws {
        try await withCheckedThrowingContinuation { continuation in
            queue.async { [self] in
                do {
                    try backup(encodable: data, item: fileType)
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    /// Restores the newest decodable backup. Corrupt files are skipped without being deleted.
    public func restoreBackup<T: Decodable>(
        _ type: T.Type,
        fileType: FileType,
        decoder: JSONDecoder = JSONDecoder()
    ) throws -> T {
        try queue.sync { try restoreBackupLocked(type, fileType: fileType, decoder: decoder) }
    }

    /// Async restore variant for UI and actor-isolated callers.
    public func restoreBackupAsync<T: Decodable & Sendable>(
        _ type: T.Type,
        fileType: FileType,
        decoder: JSONDecoder = JSONDecoder()
    ) async throws -> T {
        try await withCheckedThrowingContinuation { continuation in
            queue.async { [self] in
                do {
                    continuation.resume(
                        returning: try restoreBackupLocked(
                            type,
                            fileType: fileType,
                            decoder: decoder
                        )
                    )
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    public func listBackupFiles(for fileType: FileType) -> [URL] {
        queue.sync {
            (try? listBackupFilesLocked(for: fileType)) ?? []
        }
    }

    private func resolvedDocumentsDirectory() -> URL? {
        documentsDirectoryOverride
            ?? fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
    }

    private func directoryURL(for fileType: FileType) throws -> URL {
        guard let documentsDirectory = resolvedDocumentsDirectory() else {
            throw BackupError.directoryCreationFailed
        }
        return documentsDirectory.appendingPathComponent(fileType.rawValue, isDirectory: true)
    }

    private func backup<T: Encodable>(encodable: T, item: FileType) throws {
        let directoryURL = try directoryURL(for: item)
        try fileManager.createDirectory(
            at: directoryURL,
            withIntermediateDirectories: true,
            attributes: nil
        )

        let fileURL = directoryURL.appendingPathComponent(item.fileName)
        let encoded = try JSONEncoder().encode(encodable)
        try encoded.write(
            to: fileURL,
            options: [.atomic, .completeFileProtectionUntilFirstUserAuthentication]
        )
        try pruneBackupsLocked(for: item)
    }

    private func restoreBackupLocked<T: Decodable>(
        _ type: T.Type,
        fileType: FileType,
        decoder: JSONDecoder
    ) throws -> T {
        let files = try listBackupFilesLocked(for: fileType)
        guard !files.isEmpty else { throw BackupError.fileNotFound }

        var lastError: Error?
        for fileURL in files {
            do {
                return try decoder.decode(type, from: Data(contentsOf: fileURL))
            } catch {
                lastError = error
            }
        }

        throw BackupError.noValidBackup(
            underlying: lastError ?? BackupError.fileNotFound
        )
    }

    private func listBackupFilesLocked(for fileType: FileType) throws -> [URL] {
        let directoryURL = try directoryURL(for: fileType)
        guard fileManager.fileExists(atPath: directoryURL.path) else { return [] }

        let keys: Set<URLResourceKey> = [.contentModificationDateKey, .isRegularFileKey]
        return try fileManager
            .contentsOfDirectory(
                at: directoryURL,
                includingPropertiesForKeys: Array(keys),
                options: [.skipsHiddenFiles]
            )
            .filter { url in
                guard url.pathExtension == "backup" else { return false }
                return (try? url.resourceValues(forKeys: keys).isRegularFile) == true
            }
            .sorted { lhs, rhs in
                let lhsDate = try? lhs.resourceValues(forKeys: keys).contentModificationDate
                let rhsDate = try? rhs.resourceValues(forKeys: keys).contentModificationDate
                if lhsDate == rhsDate { return lhs.lastPathComponent > rhs.lastPathComponent }
                return (lhsDate ?? .distantPast) > (rhsDate ?? .distantPast)
            }
    }

    private func pruneBackupsLocked(for fileType: FileType) throws {
        let files = try listBackupFilesLocked(for: fileType)
        for fileURL in files.dropFirst(Self.maximumBackupCount) {
            try fileManager.removeItem(at: fileURL)
        }
    }
}
