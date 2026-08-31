# Remote AI

Add the `SwapFoundationKitRemoteAI` product and `import SwapFoundationKitRemoteAI` for `RemoteAIClient`, `RemoteAIConfiguration`, and typed errors. Import Networking when constructing a custom `HTTPClient` for injection.

The host supplies its endpoint, request data, and access policy. This product does not own API credentials, vendor SDK initialization, entitlement state, or an authentication bootstrap. Its implementation uses the Networking product; the default SFK UI product has no Remote AI dependency.

See the [migration guide](../../Docs/migration/v4-simplification-migration-guide.md). Post-extraction compile and transport verification remain pending.
