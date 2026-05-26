# Pulse Integration

Guide for integrating `SFKPulseService` and `SFKPulseConsoleView` into host apps that use SwapFoundationKit.

## What SFK provides

The Pulse capability lives in the `services` domain and uses a **use_sfk_directly** reuse strategy for host apps.

SFK provides:

- `SFKPulseService.configure(_:)` for one-time Pulse setup at app launch
- `SFKPulseConfiguration` for store location, redaction, remote logging, and capture-mode settings
- `SFKPulseNetworkCaptureMode` for choosing how much networking Pulse captures
- `SFKPulseConsoleView` for a ready-made SwiftUI log and network console screen
- automatic forwarding of `Logger.info/debug/warning/error` messages into Pulse
- automatic Pulse-backed capture for requests sent through `HTTPClient`

## Recommended host-app structure

Configure Pulse once during app launch, then expose `SFKPulseConsoleView` from a host-app-owned debug or developer entry point.

```swift
import SwiftUI
import SwapFoundationKit

@main
struct ExampleApp: App {
    init() {
        SFKPulseService.configure(
            SFKPulseConfiguration(
                networkCaptureMode: .sfkHTTPClientOnly,
                enableRemoteLogging: true,
                sensitiveQueryItems: ["token", "auth"],
                sensitiveBodyFields: ["accessToken", "refreshToken"]
            )
        )
    }

    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}
```

## Where to surface the console

The host app should own how the console is presented.

Recommended patterns:

- a developer/debug row inside a settings or about screen
- a hidden debug menu owned by the host app
- a `NavigationLink` in internal builds
- a sheet presented from a host-app coordinator or router

Example:

```swift
import SwiftUI
import SwapFoundationKit

struct DeveloperToolsView: View {
    var body: some View {
        List {
            NavigationLink("Pulse Console") {
                SFKPulseConsoleView(mode: .all)
            }

            NavigationLink("Network Requests") {
                SFKPulseConsoleView(mode: .network)
            }

            NavigationLink("App Logs") {
                SFKPulseConsoleView(mode: .logs)
            }
        }
        .navigationTitle("Developer Tools")
    }
}
```

## Capture mode selection

### `.disabled`

Use when the app wants the types available but does not want active Pulse capture.

### `.sfkHTTPClientOnly`

Recommended default for host apps.

Use when:

- the app already routes generic API work through `HTTPClient`
- the team wants predictable, explicit network capture
- the app should avoid global `URLSession` interception

### `.debugProxyAllURLSessions`

Use only for debug-focused host apps that want wider capture coverage.

Use when:

- the app still has direct `URLSession` usage outside SFK
- the team wants quicker short-term observability during migration

Notes:

- this mode is intended for debug builds
- it relies on PulseProxy, so the host app should treat it as a developer aid rather than the long-term default

## Redaction policy

Host apps should decide what must always be redacted before enabling the console for QA or internal testers.

Recommended defaults:

- keep `Authorization`, `Cookie`, `Set-Cookie`, `X-API-Key`, and `Proxy-Authorization` redacted
- add app-specific query items such as `token`, `session`, `key`, or `signature`
- add app-specific JSON fields such as `password`, `refreshToken`, `accessToken`, or `email`

Example:

```swift
SFKPulseService.configure(
    SFKPulseConfiguration(
        networkCaptureMode: .sfkHTTPClientOnly,
        sensitiveHeaders: ["Authorization", "Cookie", "X-API-Key"],
        sensitiveQueryItems: ["token", "signature"],
        sensitiveBodyFields: ["password", "refreshToken", "accessToken"]
    )
)
```

## Remote logging

Set `enableRemoteLogging: true` for internal or QA-oriented builds when the team wants to connect the app to Pulse on another device.

```swift
#if DEBUG
SFKPulseService.configure(
    SFKPulseConfiguration(
        networkCaptureMode: .sfkHTTPClientOnly,
        enableRemoteLogging: true
    )
)
#endif
```

Use host-app build configuration rules to decide whether this is enabled in debug, beta, or internal release builds.

## Custom store location

Use `.shared` unless the host app has a strong reason to isolate stores.

Choose `.custom(URL)` when:

- the app wants a dedicated store per product flavor
- the app wants a predictable file location for app-specific export or support workflows

```swift
let storeURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
    .appendingPathComponent("MyAppPulseStore", isDirectory: true)

SFKPulseService.configure(
    SFKPulseConfiguration(
        storeLocation: .custom(storeURL),
        networkCaptureMode: .sfkHTTPClientOnly
    )
)
```

## Responsibilities split

Keep these in SFK:

- Pulse dependency wiring
- log forwarding from `Logger`
- network capture for `HTTPClient`
- the reusable console screen

Keep these in the host app:

- when the console is visible
- who is allowed to access it
- whether it appears in production, QA, or debug builds
- app-specific privacy and redaction policy
- app-specific routing and developer menu presentation

## Recommended implementation order

1. Configure `SFKPulseService` at app launch with `.sfkHTTPClientOnly`.
2. Add a host-app-owned developer entry point that presents `SFKPulseConsoleView`.
3. Define redaction fields before sharing the console with QA or internal testers.
4. Enable remote logging only for the builds that need it.
5. Expand to `.debugProxyAllURLSessions` only if the host app still has important networking outside `HTTPClient`.

## Verification

After wiring a host app:

- trigger `Logger.info(...)` from the app and confirm it appears in `SFKPulseConsoleView(mode: .logs)`
- perform an `HTTPClient` request and confirm it appears in `SFKPulseConsoleView(mode: .network)`
- verify sensitive headers and fields are redacted
- verify the chosen developer entry point is reachable
- verify the app’s release/debug visibility rules for the console are correct

## Integration audit

Use the checklist in [Pulse Integration Checklist](../reference/pulse-integration-checklist.md) after integration.
