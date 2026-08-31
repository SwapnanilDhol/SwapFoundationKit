# Sync

Add the `SwapFoundationKitSync` product and `import SwapFoundationKitSync` only in targets that use App Group storage or Watch Connectivity.

- [ItemSync](ItemSync/README.md): shared-file storage, data synchronization, and factory construction.
- [WatchSync](WatchSync/README.md): typed envelopes, transfer behavior, and watch transport.

Pass App Group identifiers explicitly. Ordinary `UserDefault` preferences remain in the default product; `SharedUserDefaults` belongs here. Preserve the exact suite name and key names used by the host and its extensions. Never fall back to `.standard` when a shared suite is misconfigured.

See the [migration guide](../../Docs/migration/v4-simplification-migration-guide.md#56-shared-storage-sync-and-watch-connectivity). App Group and watch device validation remain release gates.
