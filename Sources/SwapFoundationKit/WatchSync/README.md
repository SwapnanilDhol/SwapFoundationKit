# WatchSync

Type-safe Watch Connectivity transport with versioned envelopes, transport fallback, and Combine publishers.

## Public API

| Type | Kind | Description |
|------|------|-------------|
| `WatchSyncService` | protocol | Activate, send data, envelope publisher, event publisher |
| `WatchSyncEnvelope` | struct | Versioned, timestamped payload wrapper |
| `WatchSyncTransport` | enum | `.applicationContext`, `.userInfo`, `.messageData`, `.file` |
| `WatchSyncOptions` | struct | Preferred transport, fallback order, max payload bytes |
| `WatchSyncEvent` | enum | `.activated`, `.sent`, `.received`, `.error` |
| `WatchSyncError` | enum | `.identifierMismatch`, `.payloadEncodingFailed`, etc. |
| `WatchSyncServiceImpl` | class | Concrete implementation wrapping WatchConnectivityService |

```swift
let options = WatchSyncOptions(
    preferredTransport: .applicationContext,
    fallbackOrder: [.userInfo, .messageData]
)
let watchSync = WatchSyncServiceImpl(
    connectivityService: WatchConnectivityServiceImpl(session: .default),
    options: options
)
watchSync.activate()
try await watchSync.send(mySyncableData)
```

## Source Files

- `Core/WatchSyncService.swift` — Service protocol
- `Core/WatchSyncEnvelope.swift` — Payload envelope
- `Core/WatchSyncTransport.swift` — Transport enum
- `Core/WatchSyncOptions.swift` — Configuration
- `Core/WatchSyncEvent.swift` — Domain events
- `Core/WatchSyncError.swift` — Error types
- `Implementations/WatchSyncServiceImpl.swift` — Concrete implementation
