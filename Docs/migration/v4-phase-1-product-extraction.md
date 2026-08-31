# v4 Phase 1: Pulse and Toast product extraction

Status: implemented on `refactor/v4-phase-0-1` (Workstream A); this is an
in-progress phase checkpoint, not the completed v4 release.

This is a host-facing migration note for one specific Phase 1 change described in the
[v4 simplification refactoring plan](../development/v4-simplification-refactoring-plan.md#7-phased-implementation-order)
and the [migration guide's integrations section](v4-simplification-migration-guide.md#58-links-logging-analytics-pro-gating-and-integrations):
Pulse and Toast are no longer dependencies of the default `SwapFoundationKit` product.

The general v3 guidance in the primary refactoring plan and migration guide says to
add forwarding shims where feasible. This phase is the deliberate exception: forwarding
Pulse/Toast from the default module would restore their vendor dependencies, so this
source-breaking move has no shim.

## This is a deliberate source break, not a deprecation

Per maintainer decision, this move ships **without a forwarding shim**. A shim that re-exports
`SFKPulseService`, `SFKPulseConsoleView`, `ToastManager`, `SFKToastKind`, and
`SFKToastConfiguration` from the default target would keep Pulse and Toast linked into every host
that adopts SFK — which is exactly the dependency the extraction exists to remove. Acceptance
criterion in the v4 plan is unconditional: "the default product has zero third-party
dependencies." A shim defeats that criterion even if it compiles.

If your app uses `SFKPulseService`, `SFKPulseConsoleView`, `ToastManager`, `SFKToastKind`, or
`SFKToastConfiguration`, this upgrade **will not compile** until you add the relevant product and
update your imports. The fix is mechanical — see below — but it is not automatic.

## What moved

| Symbol | Was available from | Now available from |
|---|---|---|
| `SFKPulseService` | `SwapFoundationKit` | `SwapFoundationKitPulse` |
| `SFKPulseConfiguration` | `SwapFoundationKit` | `SwapFoundationKitPulse` |
| `SFKPulseNetworkCaptureMode` | `SwapFoundationKit` | `SwapFoundationKitPulse` |
| `SFKPulseStoreLocation` | `SwapFoundationKit` | `SwapFoundationKitPulse` |
| `SFKPulseConsoleView` | `SwapFoundationKit` | `SwapFoundationKitPulse` |
| `SFKPulseConsoleMode` | `SwapFoundationKit` | `SwapFoundationKitPulse` |
| `ToastManager` | `SwapFoundationKit` | `SwapFoundationKitToast` |
| `SFKToastKind` | `SwapFoundationKit` | `SwapFoundationKitToast` |
| `SFKToastStyle` | `SwapFoundationKit` | `SwapFoundationKitToast` |
| `SFKToastConfiguration` | `SwapFoundationKit` | `SwapFoundationKitToast` |

None of these symbols changed shape. `SFKPulseService.configure(_:)`, the console view's
initializer, and `ToastManager.show(kind:config:)` are source-identical to before. Only the module
that declares them changed.

## What did not move

`HTTPClient`, `Logger`, and `LogLevel` remain in the default `SwapFoundationKit` target and
require no import change. Two new public seams were added to the default target so the Pulse
product can still instrument them without the default target depending on Pulse:

- `SFKURLSessionPerforming` / `SFKInstrumentedSession` / `SFKNetworkInstrumentation` (in
  `Core/SFKNetworkInstrumentation.swift`) — lets an opt-in product supply the `URLSession`
  `HTTPClient` uses. With nothing registered, `HTTPClient` behaves exactly as it always has: a
  plain `URLSession(configuration:)`.
- `SFKLogSink` / `SFKLogSinkRegistry` (in `Services/SFKLogSink.swift`) — lets an opt-in product
  receive every `Logger.log` message. With nothing registered, broadcasting is a no-op.

`SwapFoundationKitPulse`'s `SFKPulseService.configure(_:)` registers into both seams, so importing
it and calling `configure(_:)` restores the exact previous behavior: `HTTPClient` requests are
captured by Pulse per `SFKPulseNetworkCaptureMode`, and `Logger` messages are forwarded into
Pulse's `LoggerStore`.

Configure Pulse before constructing any `HTTPClient` instances or touching
`SwapFoundationKit.shared`, so the registered performer is used by clients created by the host.
If a host supplies another `SFKURLSessionPerforming` implementation while using origin-scoped
backend headers, it must implement `data(for:delegate:)` and forward or enforce the delegate.
The default protocol implementation fails closed with `URLError(.unsupportedURL)` for a
non-`nil` delegate (possibly wrapped as `NetworkError` by `HTTPClient`); ordinary `data(for:)`
requests remain source-compatible.

## Before / after `Package.swift`

Before (Pulse and Toast came bundled with the default product):

```swift
.target(
    name: "YourApp",
    dependencies: [
        .product(name: "SwapFoundationKit", package: "SwapFoundationKit"),
    ]
)
```

After (opt in explicitly to what you use):

```swift
.target(
    name: "YourApp",
    dependencies: [
        .product(name: "SwapFoundationKit", package: "SwapFoundationKit"),
        .product(name: "SwapFoundationKitPulse", package: "SwapFoundationKit"), // only if you use Pulse
        .product(name: "SwapFoundationKitToast", package: "SwapFoundationKit"), // only if you use Toast
    ]
)
```

If your app does not use Pulse or Toast today, no `Package.swift` change is required — the
default product simply stops linking those vendors.

## Import-change table

| If your code has... | Change it to... |
|---|---|
| `import SwapFoundationKit` and uses `SFKPulseService`, `SFKPulseConfiguration`, `SFKPulseConsoleView`, `SFKPulseConsoleMode`, `SFKPulseNetworkCaptureMode`, or `SFKPulseStoreLocation` | Add `import SwapFoundationKitPulse` alongside your existing `import SwapFoundationKit` |
| `import SwapFoundationKit` and uses `ToastManager`, `SFKToastKind`, `SFKToastStyle`, or `SFKToastConfiguration` | Add `import SwapFoundationKitToast` alongside your existing `import SwapFoundationKit` |
| `import SwapFoundationKit` and uses neither | No change |

## Verifying the extraction

- The default `SwapFoundationKit` target now declares no dependencies in `Package.swift`.
- `Tests/SwapFoundationKitPulseTests` carries the Pulse-specific test coverage previously in
  `Tests/SwapFoundationKitTests`.
- `Tests/SwapFoundationKitTests` no longer depends on the `Pulse` product; it instead tests the
  two seams (`SFKNetworkInstrumentation`, `SFKLogSinkRegistry`) directly, asserting both the
  no-registration default path and that a registered fake is invoked.

Remaining work belongs to later phases: Swift 6 `Sendable` and shared-client construction,
the future `SwapFoundationKitFirebase` opt-in product, and the planned token/UI redesign.
`NetworkService.downloadFile` intentionally remains a vendor/header bypass path.
