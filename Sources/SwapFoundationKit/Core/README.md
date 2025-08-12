# Core Services

The Core folder contains essential services that provide fundamental functionality for the SwapFoundationKit package. These services form the foundation for app development and handle critical operations like security, networking, configuration, and data backup.

## 🔐 Security Service

The `SecurityService` provides comprehensive security operations including encryption, keychain access, and secure storage.

### Features

- **🔒 AES Encryption** - 256-bit AES encryption for data security
- **🔑 Keychain Integration** - Secure storage using iOS keychain
- **🛡️ Hash Generation** - SHA256 hashing for data integrity
- **🔐 Secure Storage** - Encrypted data storage with automatic key management

### Quick Start

```swift
import SwapFoundationKit

let securityService = SecurityService()

// Encrypt sensitive data
let sensitiveData = "password123".data(using: .utf8)!
let encryptedData = try securityService.encrypt(sensitiveData)

// Store securely in keychain
try securityService.storeSecurely(encryptedData, forKey: "user_credentials")

// Retrieve and decrypt
let retrievedData = try securityService.retrieveSecurely(forKey: "user_credentials")
let decryptedString = String(data: retrievedData, encoding: .utf8)

// Generate hash
let hash = securityService.sha256Hash("sensitive_string")
```

## 🌐 Network Service

The `NetworkService` provides network operations, reachability monitoring, and HTTP utilities.

### Features

- **📡 Network Monitoring** - Real-time connectivity status
- **🌐 HTTP Operations** - GET, POST, PUT, DELETE requests
- **📱 Connection Types** - WiFi, cellular, ethernet detection
- **📥 File Download** - Progress-based file downloads
- **🔄 JSON Handling** - Automatic JSON encoding/decoding

### Quick Start

```swift
import SwapFoundationKit

let networkService = NetworkService()

// Monitor network status
if networkService.hasInternetConnection {
    print("Connected via: \(networkService.currentConnectionType)")
}

// Perform HTTP requests
let userData = try await networkService.get(
    from: "https://api.example.com/users/123",
    as: User.self
)

// Download file with progress
let destination = FileManager.default.temporaryDirectory.appendingPathComponent("file.pdf")
let downloadedFile = try await networkService.downloadFile(
    from: URL(string: "https://example.com/file.pdf")!,
    to: destination
) { progress in
    print("Download progress: \(progress * 100)%")
}
```

## ⚙️ Configuration Service

The `ConfigurationService` manages app configuration, environment settings, and configuration values.

### Features

- **🌍 Environment Management** - Development, staging, production, testing
- **📱 App Information** - Version, build number, bundle identifier
- **🔧 Configuration Values** - Type-safe configuration access
- **✅ Validation** - Configuration validation and error handling
- **🔄 Dynamic Updates** - Runtime configuration changes

### Quick Start

```swift
import SwapFoundationKit

let configService = ConfigurationService.shared

// Get current environment
let environment = configService.getCurrentEnvironment()
print("Running in: \(environment.displayName)")

// Get configuration values
let apiURL = try configService.getAPIBaseURL()
let apiKey = try configService.getAPIKey()
let maxRetries = configService.getMaxRetryCount(defaultValue: 3)

// Environment-specific configuration
if configService.isEnvironment(.production) {
    // Use production settings
    let timeout = configService.getNetworkTimeout()
}
```

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
