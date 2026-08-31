# Legacy bootstrap compatibility

Add the `SwapFoundationKitLegacy` product and `import SwapFoundationKitLegacy` only while migrating calls to `SwapFoundationKit.shared`, `SwapFoundationKitConfiguration`, or `ConfigurationService`.

The default SFK product does not depend on this compatibility product. New code constructs Networking and Sync explicitly and supplies host-owned typed configuration. UI does not need a startup call, App Group identifier, or network settings.

This is a transitional boundary, not a new recommended composition container. Preserve existing app metadata and storage identifiers while migrating; remove the legacy product only after its call sites are gone and the host's behavior checks pass.

See the [bootstrap migration recipe](../../Docs/migration/v4-simplification-migration-guide.md#51-bootstrap-and-configuration). Compatibility removal and real-app migration are separate release gates.
