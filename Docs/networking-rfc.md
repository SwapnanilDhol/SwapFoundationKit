# Networking RFC

## Status

Draft

## Purpose

This document describes the current networking surface in `SwapFoundationKit`, identifies architectural gaps, and proposes a staged refactor toward a clearer, more extensible network stack.

The goal is not to add complexity for its own sake. The goal is to make SFK's networking:

- easier to understand
- easier to test
- easier to extend with auth, retry, and observability
- more consistent across SDK-owned features

## Current State

SFK currently exposes two overlapping networking abstractions:

1. `HTTPClient` in [Sources/SwapFoundationKit/Core/Networking.swift](../Sources/SwapFoundationKit/Core/Networking.swift)
2. `NetworkService` in [Sources/SwapFoundationKit/Core/NetworkService.swift](../Sources/SwapFoundationKit/Core/NetworkService.swift)

### What `HTTPClient` already does well

- Defines `NetworkRequest` for typed endpoint modeling
- Builds `URLRequest` values from request metadata
- Executes requests with `async/await`
- Maps transport and HTTP failures into `NetworkError`
- Supports request/response logging with header redaction
- Accepts custom `URLSessionConfiguration`

### What `NetworkService` already adds

- `NWPathMonitor`-backed connection monitoring
- convenience `get`, `post`, `put`, `delete` methods
- JSON encode/decode helpers
- a `downloadFile` helper

### Where the stack is inconsistent today

Several SDK features still bypass the shared stack and use `URLSession.shared` directly:

- [Sources/SwapFoundationKit/Currency/ExchangeRateManager.swift](../Sources/SwapFoundationKit/Currency/ExchangeRateManager.swift)
- [Sources/SwapFoundationKit/Services/AppStoreSearch/AppStoreSearchResult.swift](../Sources/SwapFoundationKit/Services/AppStoreSearch/AppStoreSearchResult.swift)
- [Sources/SwapFoundationKit/ImageProcessor/ImageProcessor.swift](../Sources/SwapFoundationKit/ImageProcessor/ImageProcessor.swift)

### Current configuration hooks

`SwapFoundationKitConfiguration` already includes:

- `networkTimeout`
- `enableNetworking`
- `networkLogLevel`
- `customHTTPClient`
- `enableCertificatePinning`

Only part of that promise is fully realized today. In particular, certificate pinning is configuration-only at the moment and is not wired into the transport stack yet.

## Problems To Solve

### 1. Two public networking abstractions overlap

`HTTPClient` and `NetworkService` both perform request execution, error mapping, and convenience operations. That overlap makes it unclear which type should be considered the canonical SFK API.

### 2. Errors are duplicated

There is a public `NetworkError` in `Networking.swift` and a separate nested `NetworkService.NetworkError` in `NetworkService.swift`. Their case sets are similar but not identical.

This creates friction for:

- consumers handling errors consistently
- internal code reuse
- documentation and tests

### 3. Reachability is mixed with transport concerns

`NetworkService` uses `NWPathMonitor` and also gates request execution using `isConnected`.

That is convenient for UI, but it is not ideal as a transport policy:

- reachability is advisory, not authoritative
- the network can change between the check and the request
- `URLSession` should remain the source of truth for request success or failure

### 4. Cross-cutting behavior cannot be applied consistently

Because some SDK features bypass `HTTPClient`, the SDK cannot apply the following in one place:

- auth header injection
- token refresh
- retry/backoff
- certificate pinning
- request metrics
- common logging
- request signing

### 5. Test coverage is uneven

`NetworkingTests.swift` covers request building and core `HTTPClient` behavior well enough to give us a base, but there is little or no focused coverage around:

- `NetworkService`
- download behavior
- reachability-driven APIs
- future middleware ordering and retry policy

## Design Principles

The refactor should follow these principles:

### Single transport core

SFK should have one canonical HTTP transport abstraction. Everything else should either compose it or observe it.

### Reachability is informational

Connection state is useful for UI and background behavior, but it should not be the primary gate for whether a request is allowed to attempt.

### Public APIs should scale upward

The base API should support simple use cases without forcing boilerplate, but it should also allow more advanced host apps to layer in auth, signing, observability, and retry.

### Internal SDK traffic should use the same stack

If SFK owns an HTTP call, it should use the same shared transport unless there is a strong documented reason not to.

### Configuration flags should be real

If the public configuration exposes a feature, the transport stack should either implement it or the flag should be deprecated until it is implemented.

## Proposed Target Architecture

### Canonical transport: `HTTPClient`

`HTTPClient` becomes the single public transport core for HTTP work in SFK.

Responsibilities:

- build and execute `URLRequest`
- map transport and HTTP failures into a single public error model
- run request/response pipeline hooks
- provide upload/download helpers
- decode typed responses

### `NetworkService` becomes reachability-focused

`NetworkService` should be narrowed so it is clearly about network state observation, not duplicate transport behavior.

Recommended end-state:

- keep `NWPathMonitor`
- expose `isConnected`, `connectionType`, and possibly richer path state
- optionally expose async observation helpers
- remove or deprecate overlapping request APIs over time

If we still want a convenience facade, it should delegate directly to `HTTPClient` and avoid owning separate error types or transport behavior.

### Request pipeline / middleware layer

Introduce a lightweight, composable pipeline for cross-cutting concerns.

Example responsibilities:

- attach auth tokens
- attach shared headers
- sign requests
- redact and log payloads
- retry selected failures
- record timing and metrics

The pipeline should be ordered and deterministic.

### One public `NetworkError`

SFK should expose one public error model for transport execution.

Suggested near-term shape:

```swift
public enum NetworkError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case requestFailed(Error)
    case httpError(statusCode: Int, data: Data?)
    case decodingError(Error)
    case noInternetConnection
    case timeout
    case cancelled
}
```

This reflects the current implementation more closely and keeps the RFC aligned with Phase 1. A later phase can still refine naming, payload shape, or `Sendable` conformance once the transport API is fully consolidated.

### Internal consumers depend on injected transport

SDK-owned services that fetch remote data should depend on:

- `HTTPClient`
- or a small protocol abstraction backed by `HTTPClient`

Examples:

- `ExchangeRateManager`
- `AppStoreSearchService`
- remote image fetching in `ImageProcessor`

## Host App Adoption Pattern

SFK is not intended to force host apps into a single all-knowing app networking layer. The intended integration pattern is:

1. initialize SFK once at app startup with networking enabled
2. treat `SwapFoundationKit.shared.networkClient` as the canonical shared HTTP transport
3. keep app-level service facades for domain logic, retries, entitlement checks, and UI messaging
4. move those facades to depend on SFK transport instead of creating private `URLSession` stacks where possible

This gives host apps a practical split:

- SFK owns transport primitives and shared behavior
- the host app owns product-specific workflows and error presentation

In practice, a host-app rollout usually looks like:

1. configure SFK networking in the app delegate or app root
2. introduce a tiny app-side adapter or helper that retrieves the shared `HTTPClient`
3. migrate the highest-value HTTP services first
4. leave domain-specific error enums in place initially, but map them from SFK `NetworkError`
5. remove remaining direct `URLSession.shared` usage over time

This pattern is especially useful for apps that already have multiple standalone HTTP services and want to converge on a single transport layer without a risky big-bang rewrite.

## Proposed Public API Direction

The target API should keep simple call sites simple while giving advanced users a better upgrade path.

### Endpoint modeling

The current `NetworkRequest` protocol is a solid start, but we should evolve it to carry more intent.

Potential direction:

```swift
public protocol NetworkRequest: Sendable {
    associatedtype Response

    var request: URLRequest { get throws }
    var decoder: JSONDecoder { get }
    var retryPolicy: RetryPolicy? { get }
    var requiresAuthentication: Bool { get }

    func decode(_ data: Data, response: HTTPURLResponse) throws -> Response
}
```

We do not need to adopt this exact shape immediately. The main point is to move toward typed endpoints that can express:

- how to build the request
- how to decode the response
- whether retry/auth policies apply

### Client execution

Potential direction:

```swift
public final class HTTPClient {
    public init(
        session: URLSession = .shared,
        interceptors: [any HTTPClientInterceptor] = [],
        configuration: HTTPClientConfiguration = .default
    )

    public func execute(_ request: URLRequest) async throws -> NetworkResponse

    public func execute<R: NetworkRequest>(_ request: R) async throws -> R.Response

    public func download(
        _ request: URLRequest,
        to destination: URL
    ) async throws -> URL
}
```

Again, this is directional. The key decisions are:

- `HTTPClient` owns transport
- typed request execution is first-class
- download support belongs on the transport layer

### Reachability surface

Potential direction:

```swift
@MainActor
public final class NetworkService: ObservableObject {
    @Published public private(set) var isConnected: Bool
    @Published public private(set) var connectionType: ConnectionType

    public var hasInternetConnection: Bool { get }
    public func waitForConnection(timeout: TimeInterval = 10) async -> Bool
}
```

This keeps `NetworkService` useful without pretending it is the primary HTTP stack.

## Migration Plan

### Phase 1: Clarify the architecture

Goals:

- declare `HTTPClient` as the canonical SFK HTTP abstraction
- document `NetworkService` as reachability-first
- consolidate public error modeling

Work:

1. Merge duplicate `NetworkError` definitions into one shared public type.
2. Refactor `NetworkService` to reuse that shared type.
3. Update README wording so consumers understand when to use each type.
4. Add focused tests around error mapping and `NetworkService` behavior.

### Phase 2: Unify SDK-owned traffic

Goals:

- stop bypassing the shared client for SFK-owned HTTP calls

Work:

1. Move `ExchangeRateManager` onto injected/shared `HTTPClient`.
2. Move `AppStoreSearchService` onto injected/shared `HTTPClient`.
3. Introduce a transport-backed image download path for `ImageProcessor`.
4. Remove direct `URLSession.shared` usage unless explicitly justified.

### Phase 3: Add extensibility hooks

Goals:

- make the stack ready for app-level and SDK-level cross-cutting concerns

Work:

1. Add interceptor or middleware support.
2. Add retry policy primitives.
3. Add structured metrics/logging hooks.
4. Add download/upload support directly on `HTTPClient`.

### Phase 4: Deliver advanced transport capabilities

Goals:

- fulfill the public configuration surface and support more demanding integrations

Work:

1. Implement certificate pinning or deprecate `enableCertificatePinning` until ready.
2. Add request signing hooks.
3. Add auth-refresh support patterns for host apps.
4. Add cache policy and offline behavior guidance.

## Non-Goals

This RFC does not propose:

- replacing `URLSession` with Network.framework for HTTP
- building a full Alamofire-style abstraction layer
- adding WebSocket, TCP, or UDP transport APIs right now
- forcing every host app to use SFK as its only networking layer

Host apps can and should keep app-specific facades where they add domain logic. SFK should provide a strong transport foundation below that layer.

## Testing Plan

The refactor should expand test coverage in stages.

### Phase 1 tests

- shared `NetworkError` mapping
- header merge precedence
- cancellation propagation
- invalid response handling
- `NetworkService` reachability observation behavior

### Phase 2 tests

- internal services using injected transport instead of `URLSession.shared`
- download behavior and destination handling
- consistent logging and request shaping across services

### Phase 3 tests

- interceptor ordering
- retry policy behavior
- auth injection behavior
- metrics hook invocation

## Open Questions

These are the main design decisions still worth discussing before implementation:

1. Should `NetworkRequest` remain URL-component-based, or should it move to `URLRequest`-first construction?
2. Should `NetworkService` stay public as a small reachability helper, or should it eventually be deprecated?
3. Do we want interceptors to mutate `URLRequest`, observe requests, or both?
4. Should certificate pinning be global client policy, per-host policy, or per-request policy?
5. Do we want typed endpoints with associated `Response`, or do we prefer keeping `executeAndDecode` as the main typed API?

## Recommended Next Implementation Slice

The best first code slice is:

1. consolidate `NetworkError`
2. update `NetworkService` to use the shared error type
3. add tests for that shared behavior
4. document `HTTPClient` as the canonical transport in the README

That gives us an immediate architectural win without forcing a large all-at-once rewrite.
