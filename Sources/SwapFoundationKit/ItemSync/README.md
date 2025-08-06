# ItemSyncService

A generic, reusable data synchronization service for iOS apps that need to share data between the main app, widgets, and Watch apps.

## Features

- ✅ **Generic & Reusable**: Works with any `Codable` data type
- ✅ **Widget Support**: Automatic data sharing with widgets via App Groups
- ✅ **Watch Support**: Optional Watch connectivity for data sync
- ✅ **Simple API**: Easy to use with minimal setup
- ✅ **Error Handling**: Comprehensive error handling with detailed messages
- ✅ **Combine Support**: Reactive programming with publishers
- ✅ **Protocol-Based**: Highly testable and extensible

## Quick Start

### 1. Define Your Data Model

```swift
struct UserProfile: SyncableData {
    let id: String
    let name: String
    let email: String

    // Required: Unique identifier for this data type
    static let syncIdentifier = "user_profile"

    // Optional: Custom file extension (defaults to .json)
    static let fileExtension = "json"
}

struct AppSettings: SyncableData {
    let theme: String
    let notificationsEnabled: Bool

    static let syncIdentifier = "app_settings"
}
```

### 2. Create the Sync Service

```swift
// Basic setup (widget support only)
let syncService = ItemSyncServiceFactory.create(
    appGroupIdentifier: "group.com.yourapp.widget"
)

// With Watch support (iOS only)
#if os(iOS)
let syncService = ItemSyncServiceFactory.createWithWatch(
    appGroupIdentifier: "group.com.yourapp.widget"
)
#endif
```

### 3. Use the Service

```swift
// Save data (automatically syncs to widgets/extensions)
try await syncService.save(userProfile)

// Read data
let profile = try await syncService.read(UserProfile.self)

// Check if data exists
if syncService.exists(UserProfile.self) {
    // Data is available
}

// Delete data
try await syncService.delete(UserProfile.self)
```

### 4. Listen to Sync Events (Optional)

```swift
syncService.syncPublisher
    .sink { event in
        switch event {
        case .dataSaved(let identifier):
            print("Data saved: \(identifier)")
        case .dataDeleted(let identifier):
            print("Data deleted: \(identifier)")
        case .watchDataSent(let identifier):
            print("Data sent to Watch: \(identifier)")
        case .watchDataReceived(let identifier):
            print("Data received from Watch: \(identifier)")
        case .error(let error):
            print("Sync error: \(error.localizedDescription)")
        }
    }
    .store(in: &cancellables)
```

## Advanced Usage

### Custom Storage Implementation

```swift
class CustomStorageService: FileStorageService {
    func save<T: SyncableData>(_ data: T) throws {
        // Your custom save logic
    }

    func read<T: SyncableData>(_ type: T.Type) throws -> T {
        // Your custom read logic
    }

    func exists<T: SyncableData>(_ type: T.Type) -> Bool {
        // Your custom exists logic
    }

    func delete<T: SyncableData>(_ type: T.Type) throws {
        // Your custom delete logic
    }
}

let syncService = ItemSyncServiceFactory.create(
    storage: CustomStorageService()
)
```

### Manual Configuration

```swift
let storage = AppGroupFileStorageService(
    appGroupIdentifier: "group.com.yourapp.widget"
)

#if os(iOS)
let watchService = WatchConnectivityServiceImpl()
watchService.activate()

let syncService = DataSyncServiceImpl(
    storage: storage,
    watchConnectivity: watchService
)
#else
let syncService = DataSyncServiceImpl(storage: storage)
#endif
```

## Widget Integration

### In Your Widget Extension

```swift
import WidgetKit
import SwapFoundationKit

struct WidgetView: View {
    @State private var userProfile: UserProfile?

    var body: some View {
        VStack {
            if let profile = userProfile {
                Text("Hello, \(profile.name)!")
            } else {
                Text("Loading...")
            }
        }
        .onAppear {
            loadData()
        }
    }

    private func loadData() {
        let syncService = ItemSyncServiceFactory.create(
            appGroupIdentifier: "group.com.yourapp.widget"
        )

        Task {
            do {
                userProfile = try await syncService.read(UserProfile.self)
            } catch {
                print("Failed to load data: \(error)")
            }
        }
    }
}
```

## Watch Integration

### In Your Watch App

```swift
import WatchKit
import SwapFoundationKit

class WatchDataManager: ObservableObject {
    @Published var userProfile: UserProfile?
    private let syncService: DataSyncService

    init() {
        syncService = ItemSyncServiceFactory.create(
            appGroupIdentifier: "group.com.yourapp.widget"
        )

        // Listen for data updates
        syncService.syncPublisher
            .sink { [weak self] event in
                if case .watchDataReceived = event {
                    self?.loadData()
                }
            }
            .store(in: &cancellables)
    }

    func loadData() {
        Task {
            do {
                userProfile = try await syncService.read(UserProfile.self)
            } catch {
                print("Failed to load data: \(error)")
            }
        }
    }
}
```

## Error Handling

The service provides comprehensive error handling:

```swift
do {
    try await syncService.save(userProfile)
} catch let error as DataSyncError {
    switch error {
    case .fileStorageFailed(let fileError):
        print("File storage failed: \(fileError)")
    case .watchConnectivityFailed(let watchError):
        print("Watch connectivity failed: \(watchError)")
    case .dataEncodingFailed(let encodingError):
        print("Data encoding failed: \(encodingError)")
    case .dataDecodingFailed(let decodingError):
        print("Data decoding failed: \(decodingError)")
    case .syncOperationFailed(let message):
        print("Sync operation failed: \(message)")
    }
} catch {
    print("Unexpected error: \(error)")
}
```

## Requirements

- iOS 13.0+ / watchOS 6.0+ / macOS 10.15+
- Swift 5.0+
- App Group capability (for widget support)
- Watch Connectivity capability (for Watch support)

## Installation

Add SwapFoundationKit to your project and import the ItemSync module:

```swift
import SwapFoundationKit.ItemSync
```

## License

This module is part of SwapFoundationKit and follows the same license terms.
