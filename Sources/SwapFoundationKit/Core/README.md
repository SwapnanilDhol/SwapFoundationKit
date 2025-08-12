# Core Services

The Core folder contains essential services that provide fundamental functionality for the SwapFoundationKit package.

## 🔒 Backup Service

The `BackupService` provides robust data backup and restore capabilities with automatic file management and error handling.

### Features

- **🔄 Automatic Backup** - Easy backup of any `Encodable` data
- **📁 File Management** - Automatic cleanup of old backup files
- **🛡️ Error Handling** - Comprehensive error handling with localized descriptions
- **⚡ Performance** - Asynchronous backup operations with background processing
- **📊 File Listing** - List and manage backup files by type

### Quick Start

```swift
import SwapFoundationKit

// Create backup service
let backupService = BackupService()

// Define your data model
struct UserData: Codable {
    let name: String
    let email: String
    let preferences: [String: String]
}

// Perform backup
let userData = UserData(name: "John Doe", email: "john@example.com", preferences: [:])

do {
    try await backupService.performBackup(userData, fileType: .data)
    print("Backup completed successfully")
} catch {
    print("Backup failed: \(error.localizedDescription)")
}

// Restore from backup
do {
    let restoredData = try backupService.restoreBackup(UserData.self, fileType: .data)
    print("Restored user: \(restoredData.name)")
} catch {
    print("Restore failed: \(error.localizedDescription)")
}

// List backup files
let backupFiles = backupService.listBackupFiles(for: .data)
print("Available backups: \(backupFiles.count)")
```

### File Management

The service automatically manages backup files:

- **Automatic Cleanup** - Keeps only the 10 most recent backups
- **Organized Storage** - Creates separate directories for each file type
- **Timestamped Names** - Files include creation timestamps for easy identification

### Error Handling

Comprehensive error handling with `BackupError`:

```swift
public enum BackupError: Error, LocalizedError {
    case encodingFailed
    case writeFailed
    case directoryCreationFailed
    case fileNotFound
}
```

### Use Cases

- **User Data Backup** - Save user preferences and settings
- **App State Backup** - Backup app state for restoration
- **Data Export** - Export data for external use
- **Migration Support** - Backup before app updates

This core service provides a solid foundation for data persistence and backup operations in your applications.
