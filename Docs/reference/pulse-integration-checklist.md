# Pulse Integration Checklist

Use this checklist to audit whether a host app has integrated `SFKPulseService` clearly and safely.

## Launch setup

- `SFKPulseService.configure(_:)` is called once during app launch
- The host app has intentionally chosen `SFKPulseNetworkCaptureMode`
- The host app has explicitly decided whether remote logging is enabled
- The host app has intentionally chosen `.shared` or `.custom(URL)` store location

## Console access

- `SFKPulseConsoleView` is surfaced from a host-app-owned debug or developer entry point
- The console is not accidentally visible in user-facing production flows unless intentionally allowed
- The host app has a clear decision for `.all`, `.logs`, or `.network` console mode per entry point

## Networking

- `.sfkHTTPClientOnly` is used unless the app truly needs broader debug capture
- `.debugProxyAllURLSessions` is only used when the team accepts its debug-oriented tradeoffs
- The team has verified that important `HTTPClient` requests appear in the console

## Redaction

- Sensitive headers are redacted
- Sensitive query items are redacted
- Sensitive JSON/body fields are redacted
- The team has reviewed app-specific secrets and PII before sharing builds with QA or testers

## Ownership boundaries

- SFK owns Pulse setup and reusable console UI
- The host app owns presentation, access control, privacy policy, and build gating
- App-specific routing stays in the host app instead of being pushed into SFK

## Verification

- `Logger.info(...)` entries appear in the logs console
- `HTTPClient` requests appear in the network console
- The chosen developer entry point works on device or simulator
- The team has documented any intentional deviations from the recommended default integration
