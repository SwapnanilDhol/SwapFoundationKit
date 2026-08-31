# SwapFoundationKit v4 Simplification Refactoring Plan

Status: breaking package cleanup implemented; final verification is recorded in the implementation status

Maintainer amendment: the newly added API/dependency/acceptance GitHub workflows
have been removed, and the existing CI workflow is unchanged. The checks remain
local/manual scripts; references below to adding automated CI gates describe the
original plan, not the current automation configuration.

The maintainer has explicitly requested completion and merge without an external-app
pilot prerequisite. The [finalization brief](v4-finalization-brief.md) supersedes the
earlier two-app approval gate. Historical rationale is retained; other repositories
and backend deployment are not part of this task.

This document turns the SFK architecture audit into an implementation brief for package maintainers. Names and code snippets prefixed with “design target” describe the intended v4 shape; they are not promises that those APIs exist today. For the consumer-facing sequence, see the [v4 simplification migration guide](../migration/v4-simplification-migration-guide.md).

## 1. Outcomes and non-goals

The v4 refactor should make the default SFK product small, discoverable, and safe to adopt. A host application should be able to import UI primitives without also importing networking, authentication, watch connectivity, remote AI, or third-party telemetry. The common path should use semantic configuration and explicit dependencies rather than a mandatory global bootstrap.

The work is not a rewrite of every implementation. Existing behavior that is correct and well-tested should be moved behind clearer boundaries. In particular, App Attest and authenticated sessions are security-sensitive infrastructure: preserve their protocol and lifecycle guarantees, isolate them in an opt-in product, and simplify only construction and wiring. The detailed security rules are in the [App Attestation migration section](../migration/v4-simplification-migration-guide.md#55-app-attestation-and-authenticated-sessions).

Non-goals:

- changing backend wire contracts, App Attest challenge semantics, or proof formats;
- forcing every host application to adopt the new UI APIs in one release;
- removing useful specialized capabilities merely to reduce file count;
- making the default product responsible for application-specific policy, identity, entitlements, or analytics.

## 2. Baseline and audit evidence

The baseline must be recorded before moving symbols so later measurements are comparable.

| Scope | Swift files | Lines of code | Public declarations | Public types |
|---|---:|---:|---:|---:|
| Main `SwapFoundationKit` target | 171 | 22,198 | 1,200 | 220 |
| All Swift sources | 182 | 23,789 | 1,281 | not separately reported |

Additional audit observations:

- The default product contains almost every domain in one target and namespace. Pulse and Toast are unconditional dependencies in [`Package.swift`](../../Package.swift).
- UI alone contributes approximately 94 public types. `SFKButton` and `SFKTextField` expose 21 and 24 initializer parameters respectively.
- `SwapFoundationKit.shared` stores mutable lifecycle state and makes unrelated services appear to require startup. Some configuration flags are exposed even though startup currently initializes only networking and deeplinks.
- Settings store heterogeneous rows and `AnyView` content, requiring host-side casts. Styling is split among `SFKSettingsTheme`, text-field appearance, per-component arguments, and hardcoded metrics.
- HTTP, environment, app-link, image, watch-sync, logging, and analytics concerns have competing owners. `NetworkService` currently builds merged headers without applying them to the request; `ImageProcessor` makes direct `URLSession.shared` calls.
- Documentation catalogs and root workflow files disagree about the number of domains and capabilities. The v4 ledger must become the source of truth.

These are architectural findings, not a claim that every existing implementation is incorrect. Migrations must preserve observable behavior while reducing the number of concepts a consumer has to understand.

## 3. Target package architecture

The proposed product graph is:

```text
SwapFoundationKit
├── Design tokens and SwiftUI environment
├── Core UI primitives
├── Small, high-value utilities
└── No third-party dependencies

SwapFoundationKitNetworking
├── HTTPClient
├── NetworkMonitor
└── Typed request/response contracts

SwapFoundationKitAuthentication
├── App Attest primitives
├── Authenticated sessions
└── Authenticated transport

SwapFoundationKitSync
├── App Group storage
└── Watch sync

SwapFoundationKitMedia
├── Image transforms
├── Image cache
└── Remote image loader

Optional integrations
├── SwapFoundationKitPulse
├── SwapFoundationKitToast
├── SwapFoundationKitFirebase
├── SwapFoundationKitFeedback
└── SwapFoundationKitGoogleMobileAds
```

The exact target names are design targets. During the compatibility phase, existing products and symbols may forward to these boundaries. The default target must not depend on Pulse, Toast, Firebase, Google Mobile Ads, or other optional vendors. Module READMEs should be excluded explicitly in the package manifest so SwiftPM does not treat documentation as source.

### Ownership rules

Each concern gets one canonical owner:

| Concern | v4 owner | Boundary rule |
|---|---|---|
| HTTP | `HTTPClient` in Networking | Other features receive an injected client; no ad hoc `URLSession.shared` in feature code. |
| Reachability | `NetworkMonitor` | It reports state; it does not own request execution. |
| App Attest/session | Authentication | Host supplies identity, proof, policy, and backend adapter. |
| Shared storage | Sync | App Group identifiers are required only by consumers that use the feature. |
| Styling | `SFKTheme` | Components consume semantic tokens; legacy appearance types become projections. |
| App links | one opener/router | `AppMetaData` remains pure data. |
| Images | Media | Transform, cache, loading, and persistence are separately testable. |
| Logging/analytics | injected instances | No feature silently reaches a mutable global service. |

## 4. Unified design-token strategy

Introduce one environment-driven design system (design target):

```swift
struct SFKTheme {
    var colors: Colors
    var typography: Typography
    var spacing: Spacing
    var radii: Radii
    var motion: Motion
    var feedback: Feedback
}
```

The host configures it once at an application boundary:

```swift
ContentView()
    .sfkTheme(.system.accent(.indigo)) // design target, not an existing API
```

Components request semantic roles such as `colors.accent`, `spacing.control`, `radii.card`, and `typography.body`; they do not duplicate raw values. The customization hierarchy is:

1. zero-configuration defaults;
2. semantic role or preset;
3. application-wide theme;
4. focused per-instance modifiers;
5. injected behavior only where the behavior truly varies.

Existing `SFKSettingsTheme` and `SFKTextFieldAppearance` should first become compatibility projections of the new theme. Do not make the migration depend on simultaneous removal of all old appearance symbols. Add previews and tests for Dynamic Type, contrast, Reduce Motion, disabled controls, and light/dark schemes before deleting legacy projections.

## 5. API design rules

The following are v4 design constraints, not current API guarantees:

- A common-path initializer has at most six arguments; no public initializer has more than ten.
- A control with a semantic role should work without passing fonts, padding, colors, corner radii, or animation values.
- Prefer bindings, generic result builders, and closures over existential arrays, `AnyView`, and public delegates when the operation is local to a view.
- Keep advanced configuration available through small focused configuration values or modifiers, not a parameter list that grows with every feature.
- Make stateful services explicit instances. Stateless utilities require no bootstrap.
- Use `Sendable` and actor isolation for shared state; do not expose mutable static configuration closures.
- Keep `SFK` prefixes for public UI types, and use protocol names without a redundant prefix only where that is already the package convention.
- Mark every proposed snippet in docs as a design target until the symbol ships.

Design-target example:

```swift
SFKButton("Continue", role: .primary) { // design target, not an existing API
    continueFlow()
}
```

Loading, icons, and exceptional overrides should be modifiers or small role-specific options. Buttons, action chips, selectable chips, and close controls should share one feedback policy rather than parallel haptic enums.

## 6. Capability disposition

| Current area | Decision |
|---|---|
| `SwapFoundationKit.shared` | Deprecate and remove; retain only a clearly temporary compatibility facade. |
| `SwapFoundationKitConfiguration` | Split into feature-specific typed configurations. |
| `ConfigurationService` | Remove from the foundation; host owns typed environment configuration. |
| `HTTPClient` / `NetworkService` | Keep one HTTP transport; narrow `NetworkService` to `NetworkMonitor`. |
| Pulse and Toast | Move to opt-in integrations or a small internal presenter. |
| Settings | Rebuild around a typed result-builder API; keep a data-driven escape hatch only if real consumers need it. |
| Buttons, chips, text fields | Consume `SFKTheme`; replace oversized initializers with semantic roles and modifiers. |
| Item picker | Internalize its view model; prefer generic selection and typed labels/actions. |
| Color/photo pickers | Prefer bindings or closures over public delegate protocols. |
| Image processing | Split transform, cache, loader, and storage responsibilities. |
| Watch connectivity | Collapse the two public protocol layers into one service in Sync. |
| App links | Keep one opener; make `AppMetaData` pure data. |
| Analytics/logging | Injectable instance or actor; retain `.shared` only as transitional convenience. |
| Pro gating | Inject an `SFKAccessPolicy` (design target) or move to host layer. |
| Extensions | Prune broad conveniences; move risky/broad extensions to an opt-in product. |
| Remote AI | Move to a feature product or host layer. |
| Authentication/App Attest | Keep behavior, isolate in Authentication, simplify construction only. |

## 7. Phased implementation order

### Phase 0 — Freeze, inventory, and measure

1. Freeze new public symbols except critical fixes.
2. Generate a symbol-graph/API baseline and classify every symbol as `keep`, `merge`, `internalize`, `move`, `deprecate`, or `remove`.
3. Add owner, replacement, compatibility release, and removal-major fields to the migration catalog.
4. Reconcile catalog/documentation counts and record build time, dependency graph, binary size, and test duration.
5. Add API-surface and dependency-graph checks to CI.

Deliverable: an authoritative v4 API ledger.

### Phase 1 — Establish boundaries without behavior changes

Create the new products and move code behind them with forwarding/deprecated shims where feasible. Start with optional vendors and the largest dependency edges: Pulse, Toast, Firebase, ads, Authentication, Sync, and Media. Keep behavior and wire formats unchanged. The default target must compile without third-party imports.

Deliverable: same behavior, smaller default dependency graph.

### Phase 2 — Build the token system

Define semantic colors, typography, spacing, radii, motion, and feedback. Add an environment entry point, adapt legacy appearance types, and migrate the catalog to use the theme. Add accessibility and snapshot coverage before moving component call sites.

Deliverable: one application-wide customization seam.

### Phase 3 — Redesign high-traffic UI APIs

Migrate in this order: buttons/chips, text fields, settings, pickers, then cards/empty states/onboarding/effects. For each component, provide a concise design-target happy path, an advanced example, compile fixtures, accessibility tests, and a deprecation message for the old API. Internalize view models and helper types once consumers are migrated.

Deliverable: common screens composed with concise, type-safe APIs.

### Phase 4 — Collapse service duplication

Make the canonical HTTP client injectable everywhere and fix request interceptor/header application. Consolidate links, watch sync, image loading, logging, and analytics. Replace runtime global prerequisites with explicit feature construction. Preserve Authentication’s protocol behavior and test suite while moving it to its own product.

Deliverable: one owner per concern and no hidden bootstrap requirement.

### Phase 5 — Migrate, measure, and remove

Update the in-repository host catalog. Publish symbol-by-symbol mappings, compare
baselines, and remove the obsolete compatibility surface in this declared v4
breaking cleanup. External host-app pilots are optional follow-up validation, not
a prerequisite to completing or merging this repository.

## 8. Acceptance criteria and reviewed scope

The package cleanup and merge use the following implementation criteria. The
original numerical goals remain visible below; they are not misreported as achieved.

- the default product has zero third-party dependencies;
- public compatibility facades are removed and the unchanged symbol-graph inventory records the actual reduction;
- CI enforces the reviewed, measured no-growth budgets in `v4-api-budgets.json`;
- no common-path initializer exceeds six arguments and no public initializer exceeds ten;
- no mutable public static configuration closures remain;
- missing SFK startup cannot cause a runtime precondition for unrelated APIs;
- there is one canonical abstraction for networking, environment, linking, image loading, and watch sync;
- the common settings API contains no `AnyView` or existential dispatch;
- canonical controls, settings, and pickers have minimal/advanced migration recipes and in-repository catalog examples;
- CI checks documentation counts, API surface, dependency boundaries, and compatibility annotations;
- Authentication, networking, sync, storage, and UI behavior remain covered by tests;
- the in-repository catalog completes the migration guide before merging the breaking cleanup.

### Numerical goals reviewed during finalization

The initial design aimed for at least 40% fewer all-product public types, fewer
than 40 UI types, and roughly 60–75 default-product types. These were planning
estimates, not measurements of the minimum useful API. The final ledger records
the actual counts and any gap. Retained authentication contracts, typed service
models, barcode/photo integration, UIKit interoperability, and customization
types have distinct uses; deleting them solely to hit a count conflicts with the
non-goal of removing useful capabilities. Moving or nesting symbols is not
claimed as equivalent to deleting functionality. The reviewed regression budgets
are explicitly distinguished from these original, unmet design targets.

### Release validation, separate from this repository merge

Real-device App Attest, App Group and Watch checks, external consumer adoption,
full visual snapshots, contrast and Reduce Motion review remain release/adoption
checks. The simulator suite and rendered Dynamic Type checks provide bounded
evidence, not proof of all device and accessibility behavior. No release tag or
production deployment is included in this task.

## 9. Risks, rollback, and operational safeguards

| Risk | Prevention | Rollback trigger and action |
|---|---|---|
| Dependency boundary breaks a host import | Add compile fixtures and retain forwarding products during v3 | Any release-blocking import failure: restore the shim/product mapping; do not re-add vendors to default. |
| UI redesign changes visual or accessibility behavior | Snapshot, Dynamic Type, contrast, and Reduce Motion tests | Material regression: keep old component behind a compatibility flag and revert call sites while tokens are corrected. |
| Service split changes retry/cancellation behavior | Contract tests around transports and actors | Any changed request semantics: route through the old implementation behind the facade and compare traces. |
| Authentication regression | Preserve existing App Attest/authenticated-session tests and wire-format fixtures | Any security or enrollment failure: halt removal, ship the old Authentication facade, and investigate without changing protocol defaults. |
| Keychain or App Group data becomes inaccessible | Namespace migration table, dual-read/one-write period, device tests | Read failure or data loss signal: restore old key names and preserve old decoding before attempting another migration. |
| Public surface reduction blocks an important consumer | API ledger review, catalog compilation, migration recipes, and optional real-app pilots | Review the missing capability and restore the smallest focused API if needed. |

Use a feature branch and non-destructive merge for this cleanup. Git history retains
removed compatibility implementations. Removing API wrappers does not authorize
deleting stored data, changing storage keys, or resetting credentials. A release
tag and optional external-app/device verification remain separate from this merge.

## 10. Documentation and ownership

This plan is the maintainer-facing primary design. The [migration guide](../migration/v4-simplification-migration-guide.md) is the consumer-facing procedure and must be updated whenever a target API, compatibility window, or removal rule changes. The existing [audit catalog](../migration/catalog.yaml), [capabilities catalog](../capabilities.yaml), and module READMEs remain the operational references until v4 products ship; proposed APIs in this plan must not be added to those catalogs as existing replacements prematurely.
