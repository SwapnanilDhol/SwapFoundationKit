# ItemSync

Data synchronization between app, widgets, extensions, and Apple Watch via App Group file storage and Watch Connectivity.

## Public API

| Type | Kind | Description |
|------|------|-------------|
| `SyncableData` | protocol | Codable data with sync identifier and file extension |
| `DataSyncService` | protocol | Save, read, delete, publisher for sync operations |
| `FileStorageService` | protocol | Low-level file read/write in App Group |
| `WatchConnectivityService` | protocol | WCSession wrapper with transport fallback |
| `DataSyncServiceImpl` | class | Orchestrator: file storage + optional watch sync |
| `AppGroupFileStorageService` | class | App Group file storage implementation |
| `WatchConnectivityServiceImpl` | class | iOS-only WCSession delegate implementation |
| `ItemSyncServiceFactory` | class | Factory with multiple configuration overloads |
| `SyncEvent` | enum | `.dataSaved`, `.dataDeleted`, `.watchDataSent`, etc. |

```swift
// Define syncable data
struct MyData: SyncableData {
    static var syncIdentifier: String { "my-data" }
    var name: String
}
extension Array: SyncableData where Element: SyncableData {}

// Create sync service
let sync = ItemSyncServiceFactory.create(appGroupIdentifier: "group.com.app")

// Save and watch for changes
try await sync.save([myData])
sync.syncPublisher.sink { event in
    switch event {
    case .dataSaved: WidgetCenter.shared.reloadAllTimelines()
    case .watchDataSent: print("Synced to watch")
    default: break
    }
}
```

## Source Files

- `Core/SyncableData.swift` — Data protocol
- `Core/DataSyncService.swift` — Service protocol
- `Core/FileStorageService.swift` — Storage protocol
- `Core/WatchConnectivityService.swift` — Watch protocol
- `Implementations/DataSyncServiceImpl.swift` — Concrete orchestrator
- `Implementations/AppGroupFileStorageService.swift` — App Group storage
- `Implementations/WatchConnectivityServiceImpl.swift` — WCSession wrapper
- `ItemSyncServiceFactory.swift` — Factory
