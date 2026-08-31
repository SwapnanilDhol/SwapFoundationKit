# Networking

Add the `SwapFoundationKitNetworking` product and `import SwapFoundationKitNetworking`.

This product owns `HTTPClient`, `NetworkRequest`, typed responses/errors, networking instrumentation, backend-origin policy, and App Store lookup. It does not require the legacy SFK bootstrap or install authentication automatically.

```swift
import SwapFoundationKitNetworking

let client = HTTPClient()
let response = try await client.get(baseURL: "api.example.com", path: "/status")
```

Use `NetworkRequest.explicitURL: URL?` for a complete URL that must retain its encoding and query order. Set `usesClientDefaultHeaders` to `false` for binary/XML requests that must not inherit JSON defaults. Configure backend origins explicitly before using the legacy `NetworkService` backend-header provider. It matches scheme, host, and effective port and rejects cross-origin redirects carrying those headers.

See the [infrastructure reference](../SwapFoundationKit/Core/README.md) and [migration guide](../../Docs/migration/v4-simplification-migration-guide.md). This branch's product extraction is not yet release-verified.
