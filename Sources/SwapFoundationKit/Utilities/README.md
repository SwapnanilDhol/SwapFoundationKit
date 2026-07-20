# Utilities

Persistent TTL storage, throttling, debouncing, environment detection, and launch argument parsing.

## Public API

| Type | Kind | Description |
|------|------|-------------|
| `Debouncer` | class | Debounces actions — only the last call within the delay executes |
| `Throttler` | class | Throttles execution — first call runs immediately, subsequent calls blocked until interval elapses |
| `AsyncThrottler` | class | Async/await throttler with configurable interval and force-throttle override |
| `PersistentTTLStore<Value>` | actor | Bounded, UserDefaults-backed Codable value store with automatic expiration |
| `SFKAppEnvironment` | enum | Compile-time environment detection: `.debug`, `.release`, `.testing` |
| `SFKLaunchArguments` | enum | CLI flag and environment variable parsing for test automation |

## Quick Examples

```swift
// Debouncer — wait for typing to stop
let debouncer = Debouncer(delay: 0.3)
searchField.onChange { query in
    debouncer.call { performSearch(query) }
}

// Throttler — limit button taps
let throttler = Throttler(interval: 1.0)
button.onTap {
    throttler.throttle { saveData() }
}

// AsyncThrottler
let asyncThrottler = AsyncThrottler(interval: 5.0)
if let result = try await asyncThrottler.throttle({ try await fetchData() }) {
    // Executed
}

// Persistent cooldown/cache metadata
let cooldowns = PersistentTTLStore<String>(
    storageKey: "api-retry-cooldowns",
    maximumEntryCount: 500
)
await cooldowns.set("unavailable", forKey: "resource-id", ttl: 12 * 60 * 60)
let status = await cooldowns.value(forKey: "resource-id")

// Environment
if SFKAppEnvironment.current.isDebug {
    enableDebugTools()
}

// Launch Arguments
if SFKLaunchArguments.hasFlag("-force-pro") {
    ProManager.shared.isProEnabled = true
}
if SFKLaunchArguments.isAutomationMode {
    skipOnboarding = true
}
```

## Source Files

- `Debouncer.swift` — Action debouncing
- `Throttler.swift` — Sync and async throttling
- `PersistentTTLStore.swift` — Actor-isolated expiring Codable value persistence
- `SFKAppEnvironment.swift` — Environment detection
- `SFKLaunchArguments.swift` — Launch argument parsing
