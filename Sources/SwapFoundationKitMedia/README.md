# Media

Add the `SwapFoundationKitMedia` product and `import SwapFoundationKitMedia` for image processing and compression. It uses the Networking product for remote image requests instead of direct feature-level `URLSession.shared` calls.

See the [image processing reference](ImageProcessor/README.md) and [migration recipe](../../Docs/migration/v4-simplification-migration-guide.md#57-images-and-media). Keep compression dimensions, quality, cache keys, and storage paths unchanged when moving imports. Host-owned App Group storage is configured only when that feature is needed.

Post-extraction compilation and injected image/cache/transform/transport tests pass in the consolidated package suite. Real App Group persistence validation remains a device-level release gate; see the [implementation checkpoint](../../Docs/development/v4-implementation-status.md).
