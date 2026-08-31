# Core

Foundation-level services for networking, security, backup, and configuration.

## Public API

| Type | Kind | Description |
|------|------|-------------|
| `HTTPClient` | class | Async/await HTTP client with logging, default headers, JSON decoding, and file downloads |
| `SFKURLSessionPerforming` | protocol | Abstraction over `URLSession.data(for:)` used to instrument `HTTPClient` requests |
| `SFKInstrumentedSession` | struct | A `URLSession` paired with the performer `HTTPClient` should execute requests through |
| `SFKNetworkInstrumentation` | enum | Registry opt-in products (like `SwapFoundationKitPulse`) use to supply `HTTPClient`'s session; a plain `URLSession` is used when nothing is registered |
| `NetworkRequest` | protocol | Declarative request builder with URL, method, headers, body, explicit URL preservation, and default-header opt-out |
| `NetworkRequest.explicitURL` | property | Optional verbatim URL for presigned, XML, or otherwise non-losslessly-decomposable URLs |
| `NetworkRequest.usesClientDefaultHeaders` | property | Defaults to `true`; set `false` when the request must not merge `HTTPClient.defaultHeaders` |
| `NetworkResponse` | struct | Response wrapper with status code, content type, helpers |
| `NetworkDownloadResponse` | struct | Download result wrapper with file URL, status code, and response metadata |
| `NetworkDownloadProgress` | struct | Rich progress payload with bytes written, expected size, and fractional completion |
| `NetworkError` | enum | Structured errors: invalidURL, httpError, timeout, noInternet, etc. |
| `HTTPMethod` | enum | GET, POST, PUT, DELETE, PATCH, HEAD |
| `NetworkLogLevel` | enum | Request/response logging verbosity (none through debug) |
| `NetworkService` | class | Legacy reachability-aware network service with origin-scoped backend headers |
| `SFKBackendOriginRegistry` | enum | Explicit exact-origin registry controlling where `NetworkService.backendDefaultHeaders` may be sent |
| `SecurityService` | class | AES encryption with persistent Keychain key, keychain CRUD, SHA256 hashing |
| `AppAttestService` | actor | App Attest key, attestation, and assertion client; preserves typed unsupported, transient, and key-invalid failures |
| `AppAttestKeyStore` | protocol | Injectable persistence boundary for the App Attest key identifier |
| `AuthenticatedSessionService` | actor | Configured installation-session lifecycle, enrollment reconciliation, shared refresh and proof-binding coordination |
| `AuthenticatedSessionConfiguration` | struct | Explicit app/environment namespace, backend origin, storage compatibility and timing configuration |
| `AuthenticatedSessionBackend` | protocol | Typed challenge, enrollment, session issuance and binding boundary |
| `AppAttestSessionHTTPBackend` | struct | Adapter for the shared App Attest HTTP backend contract |
| `SessionBindingProof` | struct | In-memory encoded proof, identity and stable binding fingerprint supplied by the host |
| `AuthenticatedHTTPClient` | class | Origin-restricted authenticated requests with strict defaults and bounded pre-execution retry |
| `BackupService` | class | JSON backup/restore with timestamped files and automatic retention |
| `ConfigurationService` | class | Environment-aware key-value config from Info.plist |

## Quick Examples

```swift
// Networking
let client = HTTPClient()
NetworkService.registerBackendOrigin(host: "api.example.com")
let response = try await client.get(baseURL: "api.example.com", path: "/users")
let users: [User] = try await client.executeAndDecode(request)
let download = try await client.download(
    baseURL: "api.example.com",
    path: "/export.csv",
    to: FileManager.default.temporaryDirectory.appendingPathComponent("export.csv"),
    progress: { progress in
        print(progress.fractionCompleted ?? 0)
    }
)

// Security
let encrypted = try SecurityService().encrypt(data)
let decrypted = try SecurityService().decrypt(encrypted)
SecurityService().storeInKeychain(secret, forKey: "api-token")

// App Attest — the server owns the challenge and identity policy.
let appAttest = AppAttestService()
let attestation = try await appAttest.attest(clientData: challenge)
let assertion = try await appAttest.assertion(clientData: challenge)

// A key-invalid result is intentionally stage-dependent. The host must
// reconcile enrollment state before choosing its bounded reset policy.
do {
    _ = try await appAttest.assertion(clientData: challenge)
} catch AppAttestError.keyInvalid {
    // Do not blindly reset a key whose enrollment response may be in flight.
}

// Backup
try await BackupService().performBackup(myData, fileType: .data)
let restored: MyType = try BackupService().restoreBackup(MyType.self, fileType: .data)

// Configuration
let apiURL = try ConfigurationService.shared.getAPIBaseURL()
let isDebug = ConfigurationService.shared.isDebugMode()
```

`NetworkRequest.explicitURL` preserves the caller's URL at the URL construction
boundary, which matters for signed URLs and XML resources. Set
`usesClientDefaultHeaders` to `false` for requests that must not advertise the
client's JSON defaults. Backend defaults are only merged for an exact registered
scheme/host/port origin; a `nil` registered port resolves to HTTPS 443 or HTTP
80 and never means “any port.” `NetworkService.downloadFile` remains an explicit
legacy bypass and does not apply backend defaults.

For a conformer that already owns a complete URL, keep the protocol witness
optional so ordinary decomposed requests retain their defaults:

```swift
let explicitURL: URL? = signedURL
```

When backend defaults are attached, request redirects are rejected if they would
leave the registered origin. This keeps identity/entitlement headers from being
forwarded cross-origin while preserving ordinary requests' existing behavior.

Custom `SFKURLSessionPerforming` implementations used with origin-scoped backend
headers must implement `data(for:delegate:)` and forward or enforce the supplied
delegate. A performer that cannot honor a non-`nil` delegate fails closed with
`URLError(.unsupportedURL)`, which `HTTPClient` may wrap as `NetworkError`.
Ordinary `data(for:)` requests are unchanged; `URLSession` and Pulse support the
delegate path.

## Source Files

- `Networking.swift` — HTTPClient, NetworkRequest, NetworkResponse, NetworkDownloadResponse, NetworkDownloadProgress, NetworkError
- `SFKNetworkInstrumentation.swift` — SFKURLSessionPerforming, SFKInstrumentedSession, SFKNetworkInstrumentation (opt-in instrumentation seam for `HTTPClient`)
- `NetworkService.swift` — Legacy network service, backend-origin registration, and header policy
- `SecurityService.swift` — Encryption, keychain, hashing
- `AppAttestService.swift` — App Attest key persistence, attestation, and assertions
- `Authentication/` — Shared authenticated-session engine, backend adapter, secure persistence and HTTP client
- `BackupService.swift` — Data backup and restore
- `ConfigurationService.swift` — App configuration from Info.plist

## Authenticated sessions: shared engine, thin host policy

Use `AppAttestService` directly only when a different lifecycle is intentional. Apps using the shared challenge/enroll/session/bind contract should configure `AuthenticatedSessionService` and `AuthenticatedHTTPClient`, rather than copying an enrollment/session state machine into each app.

The session service returns credentials; the HTTP client owns security-header assembly and exact-origin dispatch. These are explicitly configured instances, not global singletons. The package does not read an app's backend URL, purchase state or identity from global app objects, and it does not automatically enroll existing SFK consumers.

The host supplies:

- App/environment/origin configuration and any exact legacy storage-key overrides.
- The current identity source and, where needed, a purchase-proof adapter.
- Product policy: which requests require a bound session and which explicitly permit legacy compatibility behavior.
- Purchase/restore callbacks, analytics and user-facing recovery.

SFK owns shared in-flight session work, per-waiter cancellation, expiry, bounded retries, enrollment reconciliation, generic binding coordination and secure storage. Subscription SDKs and entitlement decisions remain outside SFK. The server independently verifies every proof and decides authorization; neither an identity string nor a client-side binding fingerprint grants access.

### Adoption safeguards

- Configure different storage namespaces for different apps, attestation environments and backend origins, including ports. Supply existing storage keys and migration adapters when adopting in a shipped app; an extraction should not force re-enrollment.
- Keep binding proof payloads in memory only; persist only the binding metadata/fingerprint. Do not log credentials, assertions, attestation payloads or purchase proof bodies.
- Authentication endpoints reject redirects. Protected requests must not forward credentials across origins. Shared authentication must not alter `HTTPClient.shared` or turn on network body logging.
- Strict authentication is the default. Compatibility behavior must be explicitly selected by the host for the request and must retain capability metadata. Identity conflicts and arbitrary server failures do not trigger an unauthenticated replay.
- The HTTP adapter implements a documented common protocol; it is not a universal adapter for arbitrary authentication servers. Other protocols should implement `AuthenticatedSessionBackend`.
- Package and simulator tests establish client behavior, not real-device or production attestation readiness. Deployment and enforcement remain an explicit server-side rollout decision.
