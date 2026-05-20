# Core

Foundation-level services for networking, security, backup, and configuration.

## Public API

| Type | Kind | Description |
|------|------|-------------|
| `HTTPClient` | class | Async/await HTTP client with logging, default headers, and JSON decoding |
| `NetworkRequest` | protocol | Declarative request builder with URL, method, headers, body |
| `NetworkResponse` | struct | Response wrapper with status code, content type, helpers |
| `NetworkError` | enum | Structured errors: invalidURL, httpError, timeout, noInternet, etc. |
| `HTTPMethod` | enum | GET, POST, PUT, DELETE, PATCH, HEAD |
| `NetworkLogLevel` | enum | Request/response logging verbosity (none through debug) |
| `NetworkService` | class | Legacy reachability-aware network service |
| `SecurityService` | class | AES encryption with persistent Keychain key, keychain CRUD, SHA256 hashing |
| `BackupService` | class | JSON backup/restore with timestamped files and automatic retention |
| `ConfigurationService` | class | Environment-aware key-value config from Info.plist |

## Quick Examples

```swift
// Networking
let client = HTTPClient()
let response = try await client.get(baseURL: "api.example.com", path: "/users")
let users: [User] = try await client.executeAndDecode(request)

// Security
let encrypted = try SecurityService().encrypt(data)
let decrypted = try SecurityService().decrypt(encrypted)
SecurityService().storeInKeychain(secret, forKey: "api-token")

// Backup
try await BackupService().performBackup(myData, fileType: .data)
let restored: MyType = try BackupService().restoreBackup(MyType.self, fileType: .data)

// Configuration
let apiURL = try ConfigurationService.shared.getAPIBaseURL()
let isDebug = ConfigurationService.shared.isDebugMode()
```

## Source Files

- `Networking.swift` — HTTPClient, NetworkRequest, NetworkResponse, NetworkError
- `NetworkService.swift` — Legacy network service
- `SecurityService.swift` — Encryption, keychain, hashing
- `BackupService.swift` — Data backup and restore
- `ConfigurationService.swift` — App configuration from Info.plist
