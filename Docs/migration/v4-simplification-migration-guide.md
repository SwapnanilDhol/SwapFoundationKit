# SwapFoundationKit v4 Simplification Migration Guide

Status: proposed migration procedure for SFK maintainers and host applications

This guide complements the [v4 simplification refactoring plan](../development/v4-simplification-refactoring-plan.md). It describes how to move from the current v3 package shape to the v4 package architecture in controlled releases. API names and snippets labelled “design target” are proposals, not existing APIs. For current shipped capabilities, use the [migration catalog](catalog.yaml) and the [module documentation](../../Sources/SwapFoundationKit/).

## 1. Migration principles

- Migrate one boundary at a time and keep the app buildable at every checkpoint.
- Preserve behavior, backend contracts, keychain namespaces, proof semantics, and cancellation semantics before simplifying construction.
- Prefer an explicit feature instance over a global bootstrap.
- Keep host-specific identity, authorization, entitlement, analytics, and UI policy in the host.
- Do not remove a deprecated symbol until the declared v4 breaking release and the supported host apps have passed the relevant gate.

The audit baseline is 171 Swift files, 22,198 lines, 1,200 public declarations, and 220 public types in the main target; all Swift sources total 182 files, 23,789 lines, and 1,281 public declarations. These numbers are measurement baselines, not migration targets by themselves. The target is a smaller default dependency graph and a substantially smaller conceptual API surface.

## 2. Release model: v3 compatibility, then v4 breaking

### v3 compatibility phase

The compatibility phase may add new products and design-target APIs while preserving v3 names. It should:

1. publish the API ledger and deprecation map;
2. add opt-in products with forwarding shims from old symbols where possible;
3. make new APIs available without requiring immediate host migration;
4. emit compile-time deprecations with direct replacements and a removal-major version;
5. run old and new implementations against the same contract, accessibility, and snapshot tests;
6. migrate the SFK sample/catalog screens and at least two representative host apps;
7. measure build time, dependency count, binary size, runtime startup behavior, and test duration.

No v3 release should silently change App Attest wire formats, authentication defaults, keychain namespaces, or retry/cancellation semantics.

### v4 breaking phase

The v4 release may remove deprecated aliases, the mandatory global bootstrap, data-erased settings paths, and old product locations only after the compatibility gates pass. Publish a symbol-by-symbol table in the release notes, keep an explicitly named legacy product if a host needs an extended transition, and require an explicit product dependency for specialized capabilities.

The v4 default import should provide core UI, tokens, and small utilities without third-party dependencies. Authentication, Networking, Sync, Media, Pulse, Toast, ads, Firebase, and Remote AI are opt-in according to host needs.

## 3. Old-to-new conceptual mapping

| v3 concept | v4 direction (design target) | Consumer action |
|---|---|---|
| `SwapFoundationKit.shared` | Explicit feature instances; optional composition container | Remove startup ordering from views and utilities. Construct only the features used by the app. |
| `SwapFoundationKitConfiguration` | Feature-specific typed configuration | Split values by owner; delete unrelated flags from app startup. |
| `ConfigurationService` | Host-owned typed environment | Pass URLs, environment, and policy to the feature that needs them. |
| `SFKSettingsTheme` + `SFKTextFieldAppearance` | `SFKTheme` environment (design target) | Define one app theme; keep legacy projections during v3. |
| Large button/text-field initializers | Semantic roles plus modifiers (design target) | Start with defaults, then add only focused overrides. |
| `AnyView` settings rows | Generic settings result builder (design target) | Replace existential row arrays with typed bindings and labels. |
| `HTTPClient` + HTTP methods in `NetworkService` | One injected `HTTPClient`; `NetworkMonitor` for reachability | Route feature requests through the canonical transport. |
| Direct `URLSession.shared` in image/features | Injected transport in Media/Networking | Add a transport adapter and preserve status/retry behavior. |
| `AppMetaData` actions + multiple openers | Pure metadata + one app-link opener | Keep route data in the host and centralize opening. |
| `WatchConnectivityService` + `WatchSyncService` | One Sync service (design target) | Migrate message/transfer calls behind one explicit instance. |
| `ImageProcessor` doing transform/cache/network | Media transform, cache, loader, storage | Inject only the layer required by the host. |
| Global analytics/logging | Injectable actor/instance | Provide providers at the app boundary; no feature reaches global mutable state. |
| Pro-gating static closures | Injected `SFKAccessPolicy` (design target) | Keep entitlement decisions in the host or adapter. |
| App Attest/authenticated sessions in foundation | `SwapFoundationKitAuthentication` | Preserve protocols and storage; simplify wiring only. |

## 4. Host-app sequencing

Perform the migration in this order:

1. **Inventory:** record package version, imports, SFK startup calls, public symbols, App Group identifiers, keychain keys, and authentication/backend routes.
2. **Pin and baseline:** pin the v3 version, run unit/UI/accessibility tests, capture a simulator smoke test, and record network/auth traces for representative flows.
3. **Add opt-in products:** add only the v4 products needed by the app; keep the existing product until every call site has a replacement.
4. **Move configuration:** construct explicit Networking, Authentication, Sync, or Media instances at the composition root. Do not put service construction in leaf views.
5. **Adopt theme/tokens:** configure the app theme, then migrate components from raw visual arguments to semantic roles.
6. **Migrate high-traffic UI:** buttons/chips, text fields, settings, pickers, and then secondary components.
7. **Migrate service boundaries:** HTTP, links, images, watch sync, storage, logging, and analytics.
8. **Run gates:** build all targets, run contract and accessibility tests, verify keychain/App Group continuity, and run offline/online/cancellation scenarios.
9. **Remove v3 shims:** only after two release cycles or the team’s documented compatibility window, and only in v4.

Keep each step in a separately reviewable commit. If a step fails, revert the host call-site commit while retaining the additive package product or shim.

## 5. Per-capability migration recipes

### 5.1 Bootstrap and configuration

Before:

```swift
try await SwapFoundationKit.shared.start(with: appConfiguration)
```

After (design target; proposed shape):

```swift
let networking = SFKNetworkingClient(configuration: networkingConfiguration)
let auth = AuthenticatedSessionService(configuration: authConfiguration, /* injected adapters */)
```

Move only the values used by each feature. UI-only screens must not require an App Group identifier, networking URL, analytics provider, or startup call. During v3, leave the facade in place as a deprecated adapter and compare service construction in tests.

### 5.2 Theme, buttons, chips, and text fields

1. Define semantic roles for primary, secondary, destructive, toolbar, field, card, and control states.
2. Configure `SFKTheme` at the app root (design target).
3. Replace raw font/color/padding/radius arguments with roles and focused modifiers.
4. Verify Dynamic Type, contrast, Reduce Motion, disabled state, VoiceOver labels, and dark mode.
5. Keep old initializers forwarding to the new renderer until all call sites migrate.

Design-target example:

```swift
SFKButton("Continue", role: .primary) { continueFlow() }
    .sfkLoading(isLoading) // design target
```

Do not copy this snippet into production until the v4 symbol exists; it documents the intended end state.

### 5.3 Settings

Replace existential row arrays and `AnyView` content with a typed builder (design target):

```swift
SFKSettingsScreen {
    SFKSettingsSection("Preferences") {
        SFKSettingsToggle(
            "Notifications",
            systemImage: "bell",
            isOn: $notificationsEnabled
        )

        SFKSettingsPicker(
            "Currency",
            selection: $currency,
            options: Currency.allCases
        )
    }
}
```

Migrate one section at a time. Preserve row identifiers, accessibility labels, deep links, destructive confirmation, and analytics event names. If a host generates rows remotely, retain a separate advanced data-driven adapter rather than forcing remote data through an erased common API.

### 5.4 Networking and retries

Move request execution to the canonical injected HTTP client. Keep reachability observation in `NetworkMonitor`; it must not become a second request layer. Add request interceptors/middleware for auth headers, logging, retry, and certificate policy. Verify that merged headers are actually applied to the outgoing request.

For each endpoint, test status mapping, timeout, cancellation, retry count/backoff, and offline behavior. Feature code must not call `URLSession.shared` directly after the migration. Preserve backend URLs and auth headers during the compatibility phase.

### 5.5 App Attestation and authenticated sessions

App Attest is part of this refactor, but it is not a candidate for protocol simplification or a rewrite. Retain it as a cohesive, opt-in `SwapFoundationKitAuthentication` product (design target name) and preserve the existing `AppAttestService`, `AuthenticatedSessionService`, backend contract, and tests while simplifying construction and wiring.

Required invariants:

- **Origin restriction:** backend routes remain same-origin with the configured base URL; reject cross-origin challenge, enrollment, session, or binding routes.
- **Keychain namespaces:** preserve derived namespaces that include app identifier, environment, scheme, host, and port. Use a dual-read/one-write migration only when a key name must change, and never delete the old key before successful decoding and persistence of the new record.
- **Proof confidentiality:** persist binding metadata/fingerprint only; never store replayable proof payloads or attestation/assertion bytes as a convenience cache.
- **Strict binding defaults:** `requireBinding` and proof binding remain explicit and strict by default for flows that need them. Do not weaken binding to make a migration compile.
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

Move App Group storage and Watch Connectivity to the opt-in Sync product. Construct it only in targets that have the relevant entitlements. Preserve suite names, Codable schemas, transfer semantics, reachability handling, and background behavior. Use one public sync service in the v4 design target, with host-owned domain models and conflict policy.

Gate the migration with widget/extension tests, watch send/receive tests, upgrade tests, and an entitlement-enabled device run. A UI-only target should not import Sync.

### 5.7 Images and media

Split image work into transform, cache, loader, and storage roles. Keep compression dimensions/quality and cache key behavior stable first. Inject Networking transport for remote loads and preserve cancellation and HTTP status handling. Only then consider cache policy or format changes as a separate migration.

### 5.8 Links, logging, analytics, pro gating, and integrations

- Keep `AppMetaData` as data and route opening through one opener. Test universal links, custom schemes, invalid URLs, and fallback behavior.
- Convert logging/analytics to injected instances or actors. Keep event names and payload schemas stable; validate no feature creates a hidden global provider.
- Replace mutable pro-gating closures with an injected access policy (design target), while leaving product/entitlement decisions in the host.
- Move Pulse, Toast, Firebase, ads, feedback, and Remote AI to explicit opt-in products. Preserve vendor initialization order and host-owned credentials. Verify that removing any integration product does not break the default target.

## 6. Test and verification gates

Every capability migration must pass the following applicable gates:

- **Compile gate:** package, app, widget, extension, watch, and test targets build with warnings treated according to the release policy.
- **API gate:** symbol graph confirms deprecated symbols have replacements and no unplanned public declarations were added.
- **Dependency gate:** default product has no optional vendor dependency; imports match the target ownership table.
- **Behavior gate:** existing unit/contract tests pass, including wire-format fixtures and error mapping.
- **Concurrency gate:** cancellation, timeout, actor isolation, and concurrent caller tests pass for stateful services.
- **Persistence gate:** keychain, App Group, cache, and legacy record upgrade tests pass on a real device or faithful test harness.
- **Accessibility gate:** Dynamic Type, VoiceOver, contrast, Reduce Motion, disabled state, and localization checks pass for UI changes.
- **Visual gate:** catalog/snapshot examples show no unintended color, spacing, typography, or animation regression.
- **Smoke gate:** first launch, returning launch, offline launch, sign-out/sign-in, and representative authenticated flows work in the host app.

Capture evidence in the pull request: commands, target names, test results, dependency diff, API diff, and any compatibility fallback enabled.

## 7. Deprecation and removal policy

Deprecations must include a direct replacement, a migration note, and the planned removal major. Prefer one full compatibility release plus the team’s documented minimum adoption window. Deprecation messages should explain behavior changes and storage/protocol constraints, not merely rename a symbol.

Rules:

- add new API/product first;
- migrate SFK examples and real host apps;
- keep shims source-compatible and behaviorally equivalent;
- stop adding features to deprecated surfaces;
- remove aliases only in v4 and only when the API ledger marks the gate complete;
- if a host needs more time, move the shim to an explicitly named legacy product rather than restoring unrelated APIs to the default target.

## 8. Rollback and incident response

If a migration causes a build, visual, persistence, network, or security regression, revert the host call-site commit and leave the additive package boundary in place. For storage changes, restore dual-read behavior and the old namespace before investigating. For authentication failures, halt removal immediately, keep the old facade, and compare protocol traces; never “fix” a failed migration by weakening origin restriction, proof binding, key handling, or cancellation semantics.

Release tags should identify each migration phase. Keep a tested feature flag or compatibility adapter for one release where the risk warrants it, with an owner and removal date. Record the rollback decision and evidence in the migration ledger.

## 9. Completion checklist

- [ ] Inventory and baseline captured.
- [ ] Required opt-in products added and dependency graph verified.
- [ ] Global bootstrap removed from unrelated code paths.
- [ ] Theme/tokens adopted by migrated UI.
- [ ] Buttons, text fields, settings, and pickers pass compile/accessibility/visual gates.
- [ ] Canonical HTTP transport and service boundaries verified.
- [ ] App Attest/authenticated sessions pass all security and lifecycle invariants.
- [ ] Keychain/App Group migration tests pass on upgrade scenarios.
- [ ] At least two representative host apps complete the new path.
- [ ] Deprecation map and release notes published.
- [ ] v4 removal gate approved by maintainers and owners.
