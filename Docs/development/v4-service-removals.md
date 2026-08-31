# v4 service API removals

This branch removes the bootstrap compatibility surface and makes service
dependencies explicit. Authentication wire formats, keychain names, migration
decoders, retry policy, and derived storage keys are unchanged.

## Removed products and APIs

- Removed the `SwapFoundationKitLegacy` product and target, including
  `SwapFoundationKit`, `SwapFoundationKitConfiguration`, `ConfigurationService`,
  and `SFKProGate`.
- Removed `SFKSharedDefaultsRuntime` and the implicit
  `SharedUserDefaults(_:,default:)` initializer. The only initializer is now:
  `init(_ key: Key, default defaultValue: Value, appGroupIdentifier: String)`.
  Suite and key names remain unchanged.
- Removed public `WatchConnectivityService`, `WatchConnectivityServiceImpl`,
  and the compatibility Watch factory overloads (`create(storage:watchConnectivity:)`,
  `createWithWatch(appGroupIdentifier:)`, and its options variant).
  WatchConnectivity is an internal adapter used by `WatchSyncServiceImpl`;
  consumers use the public `WatchSyncService` abstraction and
  `ItemSyncServiceFactory.create(storage:watchSyncService:)`.
- Removed all side-effecting `AppMetaData` open/call/email methods. `AppMetaData`
  is data only; use `AppLinkOpener` for URL-opening effects.

## Canonical replacements

- `NetworkService` remains a reachability/convenience façade over the canonical
  `HTTPClient`; it owns no separate transport. Backend headers are supplied by
  an instance closure and are limited to instance `backendOrigins`:
  `init(client:monitor:backendHeadersProvider:backendOrigins:)`.
  The static `backendHeadersProvider` and static origin registry were removed.
- `AnalyticsManager` remains injectable (with `.shared` available for legacy
  convenience), but logger and global-parameter state is synchronized with an
  instance lock. State is snapshotted before invoking callbacks, so reentrant
  logger callbacks cannot deadlock or race mutations.
- `AppMetaData` now has a bounded primary initializer:
  `init(appGroupIdentifier:appID:appName:appShareDescription:links:)`, where
  `Links` owns optional social, website, policy, EULA, developer, and support
  fields. The app-group identifier defaults to an empty string for metadata that
  does not use shared storage.
- `AuthenticatedSessionConfiguration` now has
  `init(baseURL:appIdentifier:environment:options:)`. `Options` groups the eight
  tuning/storage/header/migration inputs while preserving all prior defaults,
  clamping, derived key bytes, and exposed configuration values.
