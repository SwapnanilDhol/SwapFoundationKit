# SwapFoundationKit v4 Migration Guide

This guide describes the breaking v4 API in this checkout. It is not a promise
that a v4 tag has been published. Pin your current release until your app's call
sites have been migrated; use a local package reference while validating v4.

The [primary plan](../development/v4-simplification-refactoring-plan.md) explains
the architecture. The [API ledger](../development/v4-api-ledger.md) and
[implementation status](../development/v4-implementation-status.md) record actual
measurements and verification. Older checkpoint documents describe APIs that have
since been removed.

## 1. What changes, and what does not

- UI needs no framework startup, App Group, network client, or authentication setup.
- Specialized features require explicit products and imports.
- Old bootstrap/configuration, erased settings, picker delegates/view models, and
  oversized control initializers are removed, not silently forwarded.
- Customize through `SFKTheme`, bindings, typed composition, focused modifiers,
  and injected service dependencies.
- Existing authentication protocols, keychain namespaces, pending enrollment
  recovery, proof semantics, and cancellation behavior must remain unchanged.
- Removing old API wrappers never requires clearing user data or resetting keys.

The in-repository catalog is the migrated example app. External app pilots and
real-device checks are valuable adoption validation, not a prerequisite for
merging the package.

## 2. Add only the products you use

| Capability | Product / import |
|---|---|
| Tokens, common UI, small utilities, general services | `SwapFoundationKit` |
| HTTP, request contracts, reachability, App Store lookup | `SwapFoundationKitNetworking` |
| App Attest, authenticated sessions and HTTP | `SwapFoundationKitAuthentication` |
| App Group storage and watch synchronization | `SwapFoundationKitSync` |
| Image transformation, compression, cache and remote loading | `SwapFoundationKitMedia` |
| Currency metadata and exchange rates | `SwapFoundationKitCurrency` |
| Backend AI requests | `SwapFoundationKitRemoteAI` |
| Feedback flow | `SwapFoundationKitFeedback` |
| Optional integrations | `SwapFoundationKitPulse`, `SwapFoundationKitToast`, `SwapFoundationKitFirebase`, `SwapFoundationKitGoogleMobileAds` |

There is no `SwapFoundationKitLegacy` product. Optional products are not
automatically re-exported by the default import.

```swift
// Package.swift — adjust this local path for your checkout.
dependencies: [.package(path: "../SwapFoundationKit")],
targets: [
    .target(name: "YourApp", dependencies: [
        .product(name: "SwapFoundationKit", package: "SwapFoundationKit"),
        .product(name: "SwapFoundationKitNetworking", package: "SwapFoundationKit"),
    ])
]
```

Add the product to each consuming app/widget/extension target and import its
module in every file that uses its symbols. A transitive product dependency is
not a replacement for an explicit Swift import.

## 3. Recommended migration order

1. Record the current version, imports, tests, App Group suite names, keychain
   keys, authentication routes, and serialized schemas.
2. Add the required products and update imports. Keep this change separate from
   changes to persisted data or backend policy.
3. Remove SFK bootstrap calls and construct only the services your app uses.
4. Add the application theme; migrate controls, then settings and pickers.
5. Replace global backend headers and watch adapters with injected instances.
6. Compile the app and its extensions; run behavior and accessibility tests.
7. Verify upgrade, cancellation, offline, and authenticated flows before shipping.

Use small consumer commits so a faulty call-site migration can be reverted
independently. Do not assume source compatibility with v3.

## 4. Removal and replacement map

| Removed surface | Replacement |
|---|---|
| `SwapFoundationKit.shared.configure/start`, `SwapFoundationKitConfiguration` | Construct the required feature instances directly |
| `ConfigurationService` | Host-owned typed environment/configuration |
| `SFKProGate` and its static closures | `SFKAccessGate(policy:)` with a host `SFKAccessPolicy` |
| Large `SFKButton` initializers, `SFKButtonConfigurator`, `SFKSecondaryButton` | `SFKButton(_:role:action:)` plus modifiers |
| Large `SFKTextField` initializer | Compact field plus focused input/appearance/status/focus modifiers |
| Parallel button/chip haptic configuration | Theme feedback policy |
| `SettingsItem`, array-based screen/section configs, erased trailing builders | Typed `SFKSettingsScreen` / `SFKSettingsSection` and direct rows |
| Information/developer enums and action handlers | Host-owned labels/navigation; `AppLinkOpener` for external links |
| Specialized date/time/slider/stepper/color settings wrappers | Native SwiftUI controls inside `SFKSettingsSection` |
| `SFKSettingsPickerRow` / option wrappers | `SFKSettingsPicker<Value>` |
| `SFKSettingsToggleRow` | `SFKSettingsToggle` with a binding |
| `SFKItemPickerViewModel`, delegate and existential overloads | Typed `SFKItemPickerView<Item>` and binding selection |
| `SFKColorPickerDelegate` | `SFKColorPickerSheet(selection:configuration:onApply:)` |
| `PhotoPickerDelegate` | Closure `PhotoPicker` or binding `SFKPhotoPicker` |
| Global backend-header provider / origin registry | Instance `NetworkService` provider and `backendOrigins` |
| Public lower-level `WatchConnectivityService` adapter | Public `WatchSyncService` abstraction |
| AppMetaData opening actions | `AppLinkOpener`; metadata remains data |
| Implicit-suite `SharedUserDefaults` | Explicit `appGroupIdentifier` |

Exact workstream mappings are retained in the
[settings/picker removal map](../development/v4-settings-removals.md),
[control removal map](../development/v4-control-removals.md), and
[service removal map](../development/v4-service-removals.md). These describe source
API removals, not deletion of persisted records.

## 5. Recipes

### 5.1 Bootstrap and configuration

Remove:

```swift
try await SwapFoundationKit.shared.start(with: appConfiguration)
```

Construct only needed services, at the composition root:

```swift
import SwapFoundationKit
import SwapFoundationKitNetworking

let client = HTTPClient()
let analytics = AnalyticsManager()
// Inject client/analytics into the feature that uses them.
```

A UI-only app can start directly with:

```swift
ContentView()
    .sfkTheme(.system.accent(.indigo))
```

App metadata does not open URLs or configure other services. Group optional
metadata links in its focused configuration, and keep environment URLs/secrets
in your host's own configuration.

```swift
let metadata = AppMetaData(
    appName: "My App",
    links: .init(
        websiteURL: URL(string: "https://example.com"),
        supportEmail: "support@example.com"
    )
)
```

Previously top-level link initializer arguments now belong in `AppMetaData.Links`.

### 5.2 Tokens and controls

```swift
SFKButton("Continue", role: .primary) { continueFlow() }
    .sfkIcon("arrow.right")
    .sfkLoading(isSaving)

SFKButton("Delete", role: .destructive) { confirmDelete() }

SFKTextField("Email", text: $email, prompt: "you@example.com")
    .sfkInput(.email)
    .sfkStatus(isEmailValid ? .normal : .error("Enter a valid email."))
```

Set application-wide colors, typography, spacing, radii, motion, and feedback
through the theme. Set `colors.onAccent` and `colors.onDestructive` when your
filled-action colors need different foreground contrast. Use focused modifiers
for one-off differences; do not reconstruct the old long initializer in a wrapper.

Advanced field configuration still supports keyboard/content type, multiline
input, secure reveal, focus binding, submit actions, supporting copy, validation,
and trailing actions. See the [UI reference](../../Sources/SwapFoundationKit/UI/README.md)
and migrated catalog for exact signatures.

### 5.3 Settings

```swift
SFKSettingsScreen {
    SFKSettingsSection("Preferences") {
        SFKSettingsToggle("Notifications", systemImage: "bell", isOn: $enabled)
        SFKSettingsPicker("Currency", selection: $currency, options: Currency.allCases)
        DatePicker("Reminder", selection: $reminderDate)
        Slider(value: $volume, in: 0...1) { Text("Volume") }
        SFKSettingsRow("About", systemImage: "info.circle") { showAbout() }
    }
}
```

The host owns state and navigation. Native controls remain usable alongside SFK
rows. Replace erased trailing views with typed composition or a binding row; use
`.settingsRowValue(...)` and `.settingsRowChevron(...)` for simple row overrides.
Use native `.confirmationDialog` for destructive confirmation, preserving the
existing user-visible confirmation step.

### Pickers, colors, and photos

```swift
SFKItemPickerView(
    "Accounts",
    items: accounts,
    selection: $selectedAccount,
    label: { $0.name },
    onSelect: { recordSelection($0) }
)

SFKColorPickerSheet(selection: $accountColor)
SFKPhotoPicker(selection: $avatar, onPick: { saveAvatar($0) })
```

Use a concrete `SFKPickableItem` model with stable `pickableItemId`. Optional
single, non-optional single, and set-based multiple bindings have distinct
semantics. Domain filtering/ranking remains host-owned. Advanced typed picker
configuration retains action, toolbar, empty-state, and presentation options.
Replace view-model/delegate ownership with caller-owned bindings; UIKit callers
can use the typed coordinator overloads.

### 5.4 Networking

```swift
let backend = NetworkService(
    client: client,
    backendHeadersProvider: { ["X-App-User-ID": currentUserID] },
    backendOrigins: [URL(string: "https://api.example.com")!]
)
```

Providers and allowed origins belong to this instance; configuring one service
must not affect another. Matching includes scheme, host, and effective port.
Backend-header redirects remain same-origin. Never use the identity header
itself as authorization.

`HTTPClient` owns execution and `NetworkMonitor` owns reachability.
`NetworkService` is a convenience facade over those owners. Preserve
`NetworkRequest.explicitURL` for signed/exact URLs and
`usesClientDefaultHeaders = false` for binary/XML requests that must not inherit
JSON defaults. Remote images/currency/AI use injected canonical transports.

### 5.5 App Attestation and authenticated sessions

Construction now groups advanced settings in `Options`; default behavior is unchanged:

```swift
import SwapFoundationKitAuthentication

let configuration = AuthenticatedSessionConfiguration(
    baseURL: backendURL,
    appIdentifier: bundleIdentifier,
    environment: "production",
    options: .init(operationTimeout: 15, sessionFreshness: 30)
)
```

Move existing `storageKeys`, `appAttestEnabled`, timeout/freshness, header names,
auth version, and `legacyMigration` arguments into `options: .init(...)` without
changing their values. Omit options entirely when using the defaults. This is
constructor grouping, not an authentication-state migration.

App Attest is part of this refactor, but it is not a candidate for protocol simplification or a rewrite. Retain it as the cohesive, opt-in `SwapFoundationKitAuthentication` product present on this branch, and preserve the existing `AppAttestService`, `AuthenticatedSessionService`, backend contract, and tests while simplifying construction and wiring.

Required invariants:

- **Origin restriction:** backend routes remain same-origin with the configured base URL; reject cross-origin challenge, enrollment, session, or binding routes.
- **Keychain namespaces:** preserve derived namespaces that include app identifier, environment, scheme, host, and port. Use a dual-read/one-write migration only when a key name must change, and never delete the old key before successful decoding and persistence of the new record.
- **Proof confidentiality:** persist purchase-binding metadata/fingerprints, not replayable purchase proofs. Preserve the existing secure, expiry-bounded pending-enrollment artifact used to recover an unknown server enrollment outcome; do not turn it into a general attestation/assertion cache or log its contents.
- **Binding policy:** preserve the existing `requireBinding: false` default and the host's explicit binding requirements. Strict compatibility policy does not implicitly require purchase binding. Do not weaken an explicitly binding-required flow or silently enable binding during a module move.
- **Identity binding:** reject empty or changed identities and invalidate stale session/binding records as the current service does.
- **Key-invalid handling:** preserve stage-dependent recovery. Do not blindly reset a key for every `keyInvalid`; distinguish enrollment/assertion stages and retain bounded recovery behavior.
- **Transient failures:** retry transient Apple/backend failures only within the existing bounded policy and deadline. Do not rotate keys for transient Apple failures.
- **Retry and cancellation:** one shared authentication operation may serve multiple waiters, but cancellation of one waiter must not cancel the shared operation. Deadlines, stale-operation checks, and `CancellationError` propagation remain intact.
- **Legacy migration:** support existing authenticated-session record decoding through the explicit legacy migration adapter before writing the new namespace.

Migration recipe:

1. Add the opt-in Authentication product.
2. Construct `AuthenticatedSessionService` at the composition root with the existing App Attest provider, identity provider, proof provider, storage, backend, clock, and sleeper adapters.
3. Compare old and new enrollment/session/binding traces against the same test fixtures.
4. Run device tests for first install, upgrade, restored keychain, key invalidation, unsupported devices, identity changes, transient failures, cancellation, timeout, and concurrent callers.
5. Switch authenticated HTTP requests to the injected authenticated client only after the contract gate passes.

Host code may continue to own authorization policy, identity/proof sources, RevenueCat or entitlement adapters, route policy, analytics, and UI. SFK owns generic session lifecycle and transport coordination; it must not acquire a vendor singleton or entitlement dependency.


### 5.6 Shared storage, sync, and watch connectivity

```swift
import SwapFoundationKitSync

@SharedUserDefaults(AppKeys.hasOnboarded, default: false,
                    appGroupIdentifier: "group.com.example.app")
var hasOnboarded
```

Keep the exact suite and key names. Do not substitute standard defaults, rename
keys, or delete shared data as part of the API change. Apps and extensions pass
their suite explicitly; no bootstrap is required.

Use `WatchSyncService` and its implementation for public watch synchronization.
The lower-level WatchConnectivity adapter is an implementation detail. Preserve
Codable envelopes, transfer semantics, reachability, and background behavior.

### 5.7 Images and media

Inject transformation, cache, storage, and remote-loading roles independently.
Keep compression dimensions/quality, cache keys, and storage paths unchanged.
Only enable App Group persistence where its entitlement exists. Validate HTTP
status errors and cancellation as well as successful image decoding.

### 5.8 Analytics, links, and integrations

Inject an `AnalyticsManager` and host-owned loggers; preserve event names and
payload schemas. `SFKFirebaseLogger` requires forwarding handlers supplied by
the host's Firebase installation. It is not an automatic Firebase SDK dependency.

Use `AppLinkOpener` for external URLs and a host router for navigation. Pass
entitlement policy into `SFKAccessGate`. Pulse, Toast, ads, feedback and RemoteAI
remain optional; preserve each integration's documented initialization order.

## 6. Verification and rollback

Before shipping your migrated app, verify:

- Compilation of app, widget, extension, watch and test targets you actually ship.
- Stored-data continuity, including exact App Group suites and authentication keys.
- Origin restrictions, expired sessions, binding policy, retries and cancellation.
- Dynamic Type, contrast, VoiceOver labels, disabled/loading states and Reduce Motion.
- First launch, returning launch, offline behavior and representative feature flows.

Package checks are `Scripts/api-baseline.sh --check`,
`Scripts/dependency-gate.sh`, and `Scripts/v4-acceptance.py`, plus the simulator
suite and catalog build described in the implementation status.

The package's simulator tests do not certify real-device App Attest, production
backend enforcement, watch delivery or entitlement-enabled App Group access.
Those remain release verification for the consuming app, not excuses to skip
package cleanup.

If a consumer migration fails, revert its call-site commit and pin the previous
package revision. Preserve data and credentials while diagnosing. Never resolve
an authentication regression by weakening origin/binding checks or resetting keys
indiscriminately. Git history retains removed compatibility code; no legacy
product is shipped in v4.
