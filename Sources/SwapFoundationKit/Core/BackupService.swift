import Foundation

/// Service for handling data backup and export operations
public final class BackupService {
    
    public init() {}
    
    public enum FileType: String, CaseIterable {
        case data = "data"
        
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
    
    /// Restores data from backup file
    /// - Parameters:
    ///   - fileType: The type of backup file
    ///   - decoder: JSON decoder to use
    /// - Returns: The restored data
    /// - Throws: BackupError
    public func restoreBackup<T: Decodable>(_ type: T.Type, fileType: FileType, decoder: JSONDecoder = JSONDecoder()) throws -> T {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw BackupError.fileNotFound
        }
        
        let fileURL = documentsDirectory.appendingPathComponent(fileType.fileName)
        let data = try Data(contentsOf: fileURL)
        return try decoder.decode(type, from: data)
    }
    
    /// Lists all backup files for a given type
    /// - Parameter fileType: The type of backup files to list
    /// - Returns: Array of backup file URLs
    public func listBackupFiles(for fileType: FileType) -> [URL] {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return []
        }
        
        let directoryURL = documentsDirectory.appendingPathComponent(fileType.rawValue)
        
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: directoryURL, includingPropertiesForKeys: nil)
            return fileURLs.sorted { url1, url2 in
                do {
                    let attributes1 = try FileManager.default.attributesOfItem(atPath: url1.path)
                    let attributes2 = try FileManager.default.attributesOfItem(atPath: url2.path)
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
    
    private func backup<T: Encodable>(encodable: T, item: FileType) throws {
        let fileName = item.fileName
        
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw BackupError.directoryCreationFailed
        }
        
        let directoryURL = documentsDirectory.appendingPathComponent(item.rawValue)
        
        if !FileManager.default.fileExists(atPath: directoryURL.path) {
            try FileManager.default.createDirectory(
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
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
        
        let directoryURL = documentsDirectory.appendingPathComponent(item.rawValue)
        
        guard FileManager.default.fileExists(atPath: directoryURL.path) else {
            return
        }
        
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: directoryURL, includingPropertiesForKeys: nil)
            if fileURLs.count > maxFileCount {
                let sortedFiles = fileURLs.sorted { (url1, url2) -> Bool in
                    do {
                        let attributes1 = try FileManager.default.attributesOfItem(atPath: url1.path)
                        let attributes2 = try FileManager.default.attributesOfItem(atPath: url2.path)
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
                    try FileManager.default.removeItem(at: sortedFiles[i])
                    print("Removed the oldest backup for \(item.fileName)")
                }
            }
        } catch {
            print("Failed while trying to manage files in folder")
        }
    }
}
