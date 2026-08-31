# Authentication

Add the `SwapFoundationKitAuthentication` product and `import SwapFoundationKitAuthentication`. Files that independently use `NetworkRequest` or other Networking types also import `SwapFoundationKitNetworking`.

This product owns `AppAttestService`, `AppAttestProviding`, authenticated installation sessions, backend adapters, secure session storage, and authenticated HTTP dispatch. The extraction preserves existing wire formats, keychain namespaces, retry/cancellation semantics, and pending-enrollment recovery.

Construct `AuthenticatedSessionService` with the existing host configuration and adapters. The host still owns identity, purchase-proof sources, binding requirements, authorization policy, and UI. `.strict` does not imply purchase binding; preserve explicit `requireBinding` choices.

Do not reset keys, change storage namespaces, alter server enforcement, or replace pending-enrollment artifacts simply because the module import changes. No Worker deployment or RevenueCat configuration is part of this move.

See the [authentication migration recipe](../../Docs/migration/v4-simplification-migration-guide.md#55-app-attestation-and-authenticated-sessions). The post-extraction contract suite passes as part of the [consolidated package tests](../../Docs/development/v4-implementation-status.md); real-device App Attest validation remains a release gate.
