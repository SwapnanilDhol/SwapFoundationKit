# SwapFoundationKit v4 API Ledger

Status: breaking package cleanup implemented. See [verification status](v4-implementation-status.md).

## Final measured surface — 2026-09-01

The unchanged symbol-graph extractor built all **12** first-party products using
Xcode 26.6, arm64 iOS Simulator. The Legacy product is removed. This is a real
compiler inventory, not a source grep or a count that hides retained APIs.

| Product | Located public declarations | Top-level public types |
|---|---:|---:|
| SwapFoundationKit | 1,304 | 102 |
| Networking | 135 | 16 |
| Authentication | 201 | 34 |
| Sync | 110 | 18 |
| Media | 86 | 13 |
| Currency | 84 | 3 |
| RemoteAI | 18 | 3 |
| Firebase | 7 | 1 |
| Feedback | 82 | 15 |
| GoogleMobileAds | 48 | 10 |
| Pulse | 27 | 6 |
| Toast | 18 | 4 |
| **Total** | **2,120** | **225** |

| Measure | Pre-extraction `55ff7a1` | Compatibility checkpoint `148deb6` | Final | Original design target |
|---|---:|---:|---:|---:|
| Default public types | 235 | 152 | 102 | 60–75 |
| UI public types | 92 | 102 | 52 | <40 |
| All-product public types | 262 | 286 | 225 | ≤157 |
| Default third-party dependency edges | 0 | 0 | 0 | 0 |

Compared with `55ff7a1`, the default has **56.6% fewer** types, UI has **43.5%
fewer**, and the complete package has **14.1% fewer**. Compared with the coexistence
checkpoint, cleanup removes 60 top-level types across products. Default-product
reduction includes relocation; it must not be presented as all-package deletion.

## Reviewed retention and budget decision

The original 75/39/157 ceilings were run against the graph and failed. **Those
design targets are not achieved.** The regression budgets now enforce the measured
102/52/225, with the original targets retained separately in
`v4-api-budgets.json`. The current surface replaces the legacy close-button
wrapper and compatibility alias with the semantic `SFKCompactButtonType`, while
retaining the shared compact control. This is an explicit scope revision, not a
claim that the original acceptance numbers passed.

- The default retains reusable services/utilities, typed settings/pickers,
  barcode/photo presentation, UIKit interoperability, and forward-compatible
  platform wrappers. They are distinct capabilities, not obsolete bootstrap or
  erased settings adapters.
- Authentication retains its 34 top-level contracts and secure lifecycle
  primitives. Simplifying construction is not justification to delete security
  states, storage, proof, backend, or transport contracts.
- Media retains separate transform/cache/storage/loading contracts; Sync retains
  typed envelopes/options/events/errors and item storage. Their lower-level
  WatchConnectivity adapter is internal, not a competing public entry point.
- Optional Feedback, Ads, Pulse, Toast, Currency, Firebase, and RemoteAI APIs remain
  opt-in. Removing whole features solely for a numerical target would contradict
  the plan's capability-preservation requirement.
- Nested component configuration names improve discoverability but are still
  public declarations. Nesting is not claimed as deletion of functionality.

Removed API mappings are in the [control](v4-control-removals.md),
[settings/picker](v4-settings-removals.md), and [service](v4-service-removals.md)
ledgers and the [migration guide](../migration/v4-simplification-migration-guide.md).

## Enforced constraints

- Every located public initializer has at most ten arguments.
- Named common constructors, including controls/settings/pickers and services,
  have at most six.
- Removed compatibility roots and mutable public static closure configuration
  cannot be reintroduced without failing the static gate.
- Catalog IDs, source/example/doc paths, 23 domain / 38 capability counts, owning
  products, and migration metadata are checked.
- The API inventory, dependency, and acceptance checks/scripts remain local/manual;
  the newly added GitHub workflows were removed by maintainer request.
- The original existing `.github/workflows/ci.yml` remains unchanged from
  `origin/main` and retains its host-app build.
- The baseline is not a complete ABI/source-compatibility checker. It records
  names, kinds, and locations, not every default argument or semantic behavior.

## Historical checkpoint ledger — `55ff7a1` (including superseded CI proposal)

> The sections below preserve the original five-product inventory, proposed
> dispositions, and validation at `55ff7a1` for comparison. Their "current", "today",
> future-product, and source-path wording is historical, not the current branch API.
> Use the measured implementation above and the current migration guide for adoption.

This was the checkpoint inventory of SwapFoundationKit's public API surface and the
symbol-by-symbol disposition that drives the v4 refactor. It supersedes the counts in
the refactoring plan's section 2 baseline table and in the migration guide's section 1 —
both were correct on the day they were audited, but the surface has grown since. Every
count in this document is reproducible by running `Scripts/api-baseline.sh` (see
"Producing and checking this ledger" below); it is not a one-time manual tally.

Dispositions below apply the plan's [section 6 capability disposition
table](v4-simplification-refactoring-plan.md#6-capability-disposition) and [section 3
ownership rules](v4-simplification-refactoring-plan.md#3-target-package-architecture)
to the actual symbols on disk. Those two sections are the maintainer's decisions; this
ledger does not invent new policy. Where the plan gives no guidance for an area, the row
is marked `unclassified` and listed in "Needs maintainer decision" rather than guessed.

## 1. Producing and checking this ledger

- `bash Scripts/api-baseline.sh` regenerates `Docs/development/api-baseline.txt`, the
  machine-generated, sorted, diffable symbol list this document's counts are drawn from.
- `bash Scripts/api-baseline.sh --check` regenerates it into a temp file, diffs against
  the committed copy, and exits non-zero with the diff printed if they differ. This is
  the same command the CI "API surface gate" (`.github/workflows/api-surface.yml`) runs.
- The script inventories all five first-party library schemes: `SwapFoundationKit`,
  `SwapFoundationKitFeedback`, `SwapFoundationKitGoogleMobileAds`,
  `SwapFoundationKitPulse`, and `SwapFoundationKitToast`. It uses a real Swift symbol graph (`swiftc -emit-symbol-graph`, driven through
  `xcodebuild`), not a grep. Its header comment documents exactly what it does and does
  not count; read it before trusting a number here to more precision than it has.
- Any PR that adds, removes, or moves a public declaration must re-run the script and
  commit the resulting diff to `api-baseline.txt`. That is the mechanism, per Phase 0
  item 5, that makes a new public symbol a deliberate, reviewed act instead of an
  accident of `public` defaulting.

## 2. Baseline: measured today vs. the old audit vs. acceptance targets

The source-file counts below were recounted on this branch on 2026-08-31. The five-target
symbol-graph regeneration was run with Xcode 26.6 arm64 iOS Simulator settings.
"Declarations" = every public/`open` symbol with an explicit source
location (own type + own extension-of-foreign-type declarations); "types" = top-level
`class`/`struct`/`enum`/`protocol`/`typealias` only (no nested types, no compiler-
synthesized conformance witnesses). See `Scripts/api-baseline.sh`'s header for exactly
why those two exclusions matter and what they under/over-count.

**Validation state:** `api-baseline.txt` now records all five products, and an independent
`bash Scripts/api-baseline.sh --check` passed. The full simulator suite passed
(289 tests, 0 failures; 293 parameterized executions). Focused
authentication and production image/XML transport coverage also passed, including
same-origin/cross-origin redirect handling and Pulse's delegate witness. A negative
isolated mutation run reproduced the expected URL/header/timeout regressions, confirming
those tests detect accidental reversions.

| Scope | Swift files | Declarations (symbol graph, located) | Top-level types (symbol graph) | Public decls (grep, task baseline) | Public types (grep, task baseline) |
|---|---:|---:|---:|---:|---:|
| `SwapFoundationKit` (default target) | 170 | 2,279 | 235 | 1,220 | 244 |
| `SwapFoundationKitFeedback` | 8 | 82 | 15 | — | — |
| `SwapFoundationKitGoogleMobileAds` | 3 | 13 | 2 | — | — |
| `SwapFoundationKitPulse` (opt-in) | 2 | 27 | 6 | — | — |
| `SwapFoundationKitToast` (opt-in) | 1 | 18 | 4 | — | — |
| All Swift sources | 184 | — | — | — | — |

**Drift from the plan's section 2 table.** That table records 171 files / 22,198 lines /
1,200 public declarations / 220 public types for the default target, and 182 files /
23,789 lines / 1,281 public declarations for all sources, as the audit baseline. The
grep-level re-measurement done for this Phase-0 pass (see task baseline columns above)
already showed drift to 1,220 public declarations and 244 public types — the surface grew
between the audit and this ledger, it did not shrink. The prior three-target symbol-graph
run reported 2,273 declarations / 235 types for the default target; the five-target run
supersedes those values after the Phase 1 source moves. Symbol-graph counting is per-declaration
(each enum case, each property is its own symbol), while a grep pass is roughly per-
`public`-keyword-line, so the methods are not directly comparable. All future comparisons
should use this ledger's `api-baseline.txt`, produced with the pinned toolchain, rather
than re-deriving a number by hand.

**UI matches exactly.** The task's independently grep-measured "92 public types under
UI" and this ledger's symbol-graph top-level type count for the `UI` domain (92) agree
exactly, which is the strongest evidence the two methodologies are cross-checking the
same reality even though their totals diverge for other reasons (enum-case granularity,
extension attribution).

### Acceptance criteria distance (plan section 8)

| Acceptance criterion | Target | Current | Distance |
|---|---|---:|---|
| Default product public types | ~60–75 | 235 | needs ~-68% to -74% |
| UI public types | below 40 (from ~94) | 92 | needs ~-57% |
| Total public types (all first-party) | ≥40% reduction | 262 (235 + 15 + 2 + 6 + 4) | reduction not yet started |
| Default product third-party dependencies | zero | 0 (as of this commit) — see `Package.swift` | **met on this branch as of this commit.** A concurrent workstream extracted Toast/Pulse/PulseUI/PulseProxy from the default `SwapFoundationKit` target into `SwapFoundationKitToast`/`SwapFoundationKitPulse` while this ledger was being written; verified via `swift package describe --type json` and a repo-wide import grep (see section 7). Treat this as a point-in-time confirmation, not a permanent guarantee — the CI dependency gate is what keeps it true going forward. |

## 3. Per-domain breakdown (default `SwapFoundationKit` target)

From `Docs/development/api-baseline.txt`, generated by `Scripts/api-baseline.sh`:

| Domain (`Sources/SwapFoundationKit/<dir>`) | Files | Declarations | Top-level types | v4 direction (summary; detail in section 4) |
|---|---:|---:|---:|---|
| UI | 64 | 920 | 92 | biggest reduction target — semantic roles + modifiers, internalize view models, drop delegate protocols |
| Core | 34 | 405 | 51 | split: Authentication → own product (keep, unchanged behavior); HTTP/NetworkService → Networking product; `ConfigurationService` → remove |
| Services | 23 | 223 | 36 | mixed — logging/analytics/haptics/deeplinks stay (injectable), Toast leaves, pro-gating becomes an injected policy |
| Extensions | 11 | 208 | 3 | prune broad conveniences per plan section 6; keep small high-value ones |
| ItemSync | 9 | 98 | 14 | move to Sync product; collapse duplicate `WatchConnectivityService` with WatchSync's |
| Currency | 2 | 84 | 3 | plan gives no explicit disposition — unclassified |
| Compatibility | 3 | 79 | 2 | plan gives no explicit disposition — unclassified |
| Protocols | 4 | 60 | 4 | `AppMetaData` keep (pure data); others unclassified |
| WatchSync | 7 | 47 | 7 | move to Sync product; collapse with ItemSync's watch layer into one service |
| ImageProcessor | 2 | 36 | 3 | move to Media product; split transform/cache/loader/storage |
| Utilities | 5 | 36 | 6 | small high-value utilities — keep in default per plan section 3 |
| Ads | 1 | 35 | 8 | move: this is default-target config for an opt-in vendor integration; belongs behind `SwapFoundationKitGoogleMobileAds` |
| (root) | 2 | 30 | 3 | `SwapFoundationKit.shared` + `SwapFoundationKitConfiguration` — deprecate/remove and split, respectively |
| RemoteAI | 4 | 18 | 3 | move to a feature product or host layer |

## 4. Classification table

Disposition values: `keep` (stays as-is, possibly relocated), `merge` (collapses with
another symbol/area), `internalize` (drops from public API), `move` (relocates to a new
product, public surface preserved), `deprecate` (kept with a compile-time warning and a
replacement), `remove` (deleted, no replacement), `unclassified` (plan gives no
disposition; needs a maintainer decision — see section 5).

Rows group by coherent area rather than one row per symbol, per the Phase-0 instruction
not to pad this document with 1,200+ hand-written rows. A grouped row's "replacement"
and "compat release" columns describe the group's typical case; exceptions are called
out under the group where the plan is explicit about them (e.g. Authentication's
security invariants).

| Symbol / group | Current module | Disposition | v4 owner | Replacement | Compat release | Removal major |
|---|---|---|---|---|---|---|
| `SwapFoundationKit` (the `.shared` singleton class), its lifecycle/startup surface | `SwapFoundationKit` (root) | deprecate → remove | none (explicit instances instead) | explicit per-feature service construction at the composition root | next v3.x (deprecation warning added) | v4.0.0 |
| `SwapFoundationKitConfiguration` | `SwapFoundationKit` (root) | deprecate → remove (split) | feature-owning product (Networking/Authentication/Sync/Media typed configs) | per-feature typed configuration structs | next v3.x | v4.0.0 |
| `ConfigurationService` | `Core/ConfigurationService.swift` | remove | host application | host-owned typed environment/config | next v3.x (deprecated) | v4.0.0 |
| `HTTPClient` and the HTTP surface of `NetworkService` | `Core/Networking.swift`, `Core/NetworkService.swift` | move; narrow `NetworkService` to reachability only | `SwapFoundationKitNetworking` | `HTTPClient` (moved, unchanged contract) + `NetworkMonitor` (reachability only) | next v3.x (opt-in Networking product ships, old symbols forward) | v4.0.0 |
| `SFKURLSessionPerforming`, `SFKInstrumentedSession`, `SFKNetworkInstrumentation` | `Core/SFKNetworkInstrumentation.swift` | keep (instrumentation seam) | Networking/Pulse boundary | Optional session performer registration; no registration preserves plain `URLSession` behavior | current branch | n/a |
| `NetworkRequest.explicitURL`, `NetworkRequest.usesClientDefaultHeaders`, `SFKBackendOriginRegistry` | `Core/Networking.swift`, `Core/NetworkService.swift` | keep (compatibility seams) | Networking boundary | Verbatim URL preservation, per-request default-header opt-out, and exact scheme/host/effective-port backend registration | current branch (source-compatible additions) | n/a |
| `AppAttestService`, `AppAttestKeyStore`/`KeychainAppAttestKeyStore`, App Attest attestation/assertion types | `Core/AppAttestService.swift`, `Core/Networking.swift` (App Attest payload types) | keep, move | `SwapFoundationKitAuthentication` | same types, relocated; behavior/wire format frozen per migration guide 5.5 | next v3.x (opt-in Authentication product ships) | v4.0.0 (old import path only) |
| `AuthenticatedSessionService` and the `Core/Authentication/*` family (28 files: backend, transport, storage, clock, sleeper, credential, identity, binding, legacy migration, error types) | `Core/Authentication/` | keep, move | `SwapFoundationKitAuthentication` | same types, relocated; construction simplified only, per migration guide 5.5 invariants (origin restriction, keychain namespaces, proof confidentiality, strict binding, identity binding, key-invalid handling, transient-failure/retry/cancellation semantics, legacy migration) — none of these may change during the move | next v3.x | v4.0.0 |
| `SecurityService`, `BackupService` | `Core/` | unclassified | — | — | — | — |
| Toast presentation surface (`ToastManager`, `SFKToastKind`, `SFKToastStyle`, `SFKToastConfiguration`) | `SwapFoundationKitToast/` | move (implemented, source-breaking, no shim) | `SwapFoundationKitToast` (opt-in) | explicit product dependency and import | current branch checkpoint; not released tag yet | v4.0.0 |
| Pulse/PulseUI/PulseProxy integration points | `SwapFoundationKitPulse/` | move (implemented, source-breaking, no shim) | `SwapFoundationKitPulse` (opt-in) | explicit product dependency and import | current branch checkpoint; not released tag yet | v4.0.0 |
| `AnalyticsProtocol`, `Logger`, `SFKLogSink` | `Services/` | keep (injectable) | Services (stays in default, becomes injected instance/actor, `.shared` only as transitional convenience) | same protocol/type, no forced global reach | none required (behavior-preserving) | n/a unless `.shared` convenience is removed, then v4.0.0 |
| `SFKFirebaseLogger` | `Services/Analytics/` | move (temporary guarded exception) | `SwapFoundationKitFirebase` (planned opt-in) | explicit Firebase product; current default-target adapter is allowed only under `#if canImport(FirebaseAnalytics)` | current branch checkpoint; not permanent | v4.0.0 |
| `SFKProGate` and pro-gating closures | `Services/SFKProGate.swift` | deprecate → move | host layer, via injected `SFKAccessPolicy` (design target) | `SFKAccessPolicy` adapter, host-owned entitlement decisions | next v3.x (new policy type ships alongside) | v4.0.0 |
| `DeeplinkHandler`, `DeeplinkEvent`, `DeeplinkRoute`, `AppLinkOpener` | `Services/DeeplinkHandler/`, `Services/AppLinkOpener.swift` | keep | Services (one opener; `AppMetaData` stays pure data per Protocols row below) | same types; consolidate to one opener if more than one exists today | none required unless a second opener is found and merged | v4.0.0 if a duplicate is merged |
| `HapticsHelper`, `SFKNotificationService`, `PasteboardService`, `DeviceInfo`, `FileExportService`, `FileImportService`, `LocationSearchService`, `ItemDetailSource`/`DefaultItemDetailSource`, `AppStoreSearchResult`, `UserDefault`/`UserDefaults+` | `Services/` | unclassified | — | — | — | — |
| Buttons, Chips, TextField (`UI/Buttons`, `UI/Chips`, `UI/TextField`) | `UI/` | deprecate (initializers) → keep (component identity) | UI (default target) | semantic-role initializers + `SFKTheme` modifiers, per plan sections 4–5; old large-initializer overloads forward then deprecate | next v3.x (new initializers ship, old ones forward) | v4.0.0 (old initializer overloads removed) |
| Settings (`UI/Settings`, 15 files, including `AnyView` row content) | `UI/Settings` | deprecate (erased API) → keep (rebuilt) | UI (default target) | typed result-builder settings API (`SFKSettingsScreen`/`SFKSettingsSection`/etc., design targets); data-driven adapter kept only if a real consumer needs it, per plan section 6 | next v3.x | v4.0.0 |
| Item picker (`UI/ItemPicker`, 10 files) | `UI/ItemPicker` | internalize (view model) | UI (default target) | generic selection API with typed labels/actions; view model becomes internal | next v3.x | v4.0.0 (public view-model types removed) |
| Color picker, photo picker (`UI/ColorPicker`, `UI/PhotoPicker.swift`) | `UI/` | deprecate (delegate protocols) → keep (component identity) | UI (default target) | bindings/closures replace public delegate protocols | next v3.x | v4.0.0 |
| Barcode scanner, empty state, effects, pro banner, onboarding, appearance manager, alert presenter, SwiftUI/UIKit extension helpers (`UI/BarcodeScanner`, `UI/EmptyState`, `UI/Effects`, `UI/ProBanner`, `UI/Onboarding`, `UI/SFKAppearanceManager.swift`, `UI/AlertPresenter.swift`, `UI/SwiftUIExtensions`, `UI/UIKitExtensions`) | `UI/` | unclassified | — | — | — | — |
| `SFKSettingsTheme`, `SFKTextFieldAppearance` (wherever declared under `UI/`) | `UI/` | deprecate (become projections) | UI (default target) | `SFKTheme` environment (design target); these become compatibility projections first, per plan section 4 | next v3.x (SFKTheme ships) | v4.0.0 (projections removed) |
| `WatchSyncService`, `WatchSyncTransport`, `WatchSyncEnvelope`/`Event`/`Options`/`Error` (`WatchSync/`) and `WatchConnectivityService`/`WatchConnectivityServiceImpl` (`ItemSync/Core`, `ItemSync/Implementations`) | `WatchSync/`, `ItemSync/` | merge, move | `SwapFoundationKitSync` | one collapsed Sync watch service, per plan section 6 "Watch connectivity" | next v3.x | v4.0.0 |
| `DataSyncService`/`DataSyncServiceImpl`, `FileStorageService`/`AppGroupFileStorageService`, `SyncableData`, `ItemSyncServiceFactory` | `ItemSync/` | move | `SwapFoundationKitSync` | same types, relocated; App Group storage becomes opt-in only | next v3.x | v4.0.0 |
| `ImageProcessor`, `SFKImageCompressor` | `ImageProcessor/` | move (split) | `SwapFoundationKitMedia` | separate transform/cache/loader/storage roles, per plan section 6 "Image processing" and migration guide 5.7 | next v3.x | v4.0.0 |
| `RemoteAIClient`, `RemoteAIConfiguration`, `RemoteAIError`, `RemoteAIRequest` | `RemoteAI/` | move | feature product or host layer (plan does not name a target) | plan section 6 says "move to a feature product or host layer" without naming which — **needs maintainer decision on target name** | next v3.x | v4.0.0 |
| `AdPlacement`, `AdLifecycleEvent`, `AdsPresentationViewController` typealias, `AdUnitConfiguration` (`Ads/AdsConfiguration.swift`, in the *default* target) | `SwapFoundationKit` (root)/`Ads/` | move | `SwapFoundationKitGoogleMobileAds` | same types, relocated fully behind the opt-in product; today's split (config in default, implementation in `SwapFoundationKitGoogleMobileAds`) is itself the thing that must not survive v4 per section 8's "zero third-party dependencies… the default product must compile without third-party imports," and per section 3 "Ads" is listed only under "Optional integrations" | next v3.x | v4.0.0 |
| `AdsManager`, `AdsProvider`, `GoogleAdsProvider` | `SwapFoundationKitGoogleMobileAds` | keep | `SwapFoundationKitGoogleMobileAds` (already isolated) | no change — already an opt-in product | n/a | n/a |
| `SFKFeedbackClient`, `SFKFeedbackConfiguration`, `SFKFeedbackCoordinator`, `SFKFeedbackInstallationIdentifierStore`, `SFKFeedbackModels`, `SFKFeedbackService`, `SFKFeedbackView`, `SFKFeedbackViewModel` | `SwapFoundationKitFeedback` | keep | `SwapFoundationKitFeedback` (already isolated) | no change — already an opt-in product | n/a | n/a |
| `AppMetaData` | `Protocols/AppMetaData.swift` | keep | Services (app links) | stays pure data; route opening centralizes through one opener, per plan section 3 "App links" row | none required unless a second opener is merged | n/a |
| `Coordinator`, `ValueDefaultProvider`, `PasteboardCopyRepresentable` | `Protocols/` | unclassified | — | — | — | — |
| Extensions on `String`, `Date`, `URL`, `Collection`, `Number`, `Bundle`, `FileManager`, `Result`, `JSON`, `Data` (11 files) | `Extensions/` | unclassified (plan says "prune broad conveniences; move risky/broad ones to an opt-in product" but does not name which extensions are "broad" or "risky") | — | — | — | — |
| `Debouncer`, `Throttler`, `SFKAppEnvironment`, `SFKLaunchArguments`, `PersistentTTLStore` | `Utilities/` | keep | `SwapFoundationKit` (default target) | none — matches plan section 3's default-target bucket "Small, high-value utilities" as-is | n/a | n/a |
| `Currency`, `ExchangeRateManager` (58 currencies + exchange-rate management) | `Currency/` | unclassified | — | — | — | — |
| `CompatibleNavigationSubtitle`, `CompatibleTabBarMinimizeBehavior`, `UIKitTabBarMinimizeBehavior` | `Compatibility/` | unclassified | — | — | — | — |

## 5. Needs maintainer decision

Every `unclassified` row above, collected in one place, because the plan's section 6
table and section 3 ownership rules do not name a disposition for these areas:

1. **Extensions (`Extensions/`, 208 public declarations across 11 files).** Plan section
   6 says "prune broad conveniences; move risky/broad extensions to an opt-in product"
   but does not define "broad" or "risky," or name the opt-in product. This is the
   single largest unclassified group by declaration count.
2. **Currency (`Currency/`, 84 declarations, 2 files, 58 currencies + exchange-rate
   management).** Not mentioned anywhere in plan sections 3 or 6. Candidate for the
   default target's "small, high-value utilities" bucket, but that is a guess, not a
   documented decision.
3. **Compatibility (`Compatibility/`, 79 declarations, 3 files, iOS 26+ forward-
   compatible wrappers).** Not mentioned in plan sections 3 or 6.
4. **Most of `Services/` and `UI/`'s "secondary" components** (barcode scanner, empty
   state, effects, pro banner, onboarding, appearance manager, alert presenter,
   SwiftUI/UIKit extension helpers; and in Services: `SecurityService`, `BackupService`,
   `SFKNetworkInstrumentation`, haptics/notifications/pasteboard/device-info/file-export/
   file-import/location-search/item-detail/app-store-search/user-defaults helpers).
   Plan section 6 covers only the highest-traffic UI components (buttons, chips, text
   fields, settings, item picker, color/photo pickers) by name; everything else in `UI/`
   and most of `Services/` has no named disposition. Phase 3's ordering ("buttons/chips,
   text fields, settings, pickers, then cards/empty states/onboarding/effects") implies
   these come later but does not say keep/merge/internalize/move for each.
5. **`RemoteAI/`'s target product name.** Disposition is clear ("move to a feature
   product or host layer") but no product name is chosen, unlike Authentication/Sync/
   Media/Pulse/Toast/Ads/Feedback which all have named products in plan section 3.
6. **`Protocols/Coordinator.swift`, `Protocols/ValueDefaultProvider.swift`,
   `Protocols/PasteboardCopyRepresentable.swift`.** Not mentioned in plan sections 3 or
   6; unclear whether these count as "core UI primitives," "small utilities," or should
   move with the feature they most support.

## 6. Known gaps in this ledger

- **No line-of-code measurement.** This ledger reports declaration/type counts from the
  symbol graph; it does not re-measure lines of code or build time, dependency graph
  size, binary size, or test duration, all of which Phase 0 item 4 also calls for. Those
  are out of scope for this ledger and should be tracked separately (or as a follow-up
  to this document) before Phase 0 is declared fully complete.
- **`SwapFoundationKitHost` and other consumer apps are not inventoried.** This ledger
  only covers the five first-party library schemes (`SwapFoundationKit`,
  `SwapFoundationKitFeedback`, `SwapFoundationKitGoogleMobileAds`,
  `SwapFoundationKitPulse`, and `SwapFoundationKitToast`). It does not include
  the host sample app's own public surface (it has none relevant here) or any real
  downstream consumer's call-site inventory, which migration guide section 4 step 1
  ("Inventory") calls for per-host-app, not per-package.
- **Grouped rows, not symbol-level rows.** Per the Phase-0 instruction to avoid a
  1,200+-row document, most classification-table rows represent a directory or a small
  cluster of files, not one row per symbol. A handful of areas (Authentication, Ads,
  root) call out specific type names because the plan is specific about them. Anyone
  needing a literal symbol-by-symbol disposition should cross-reference
  `Docs/development/api-baseline.txt` (every located public declaration, one per line)
  against this table's groupings.
- **Access-level nuance not captured.** The symbol graph and this ledger do not
  distinguish `public` from `open`, or flag `@_spi`/underscored/`@available(*,
  deprecated)` attributes. A symbol already marked deprecated in source is not called
  out separately here.
- **No dependency-graph or import-level audit.** This ledger counts declarations, not
  which public types actually leak third-party vendor types (e.g. a public API whose
  parameter type is a Pulse or Toast type) into the default target's signature surface.
  The CI dependency gate (section 7 below) checks *imports*, not *signature leakage*,
  which is a narrower and more mechanical check.
- **`api-baseline.txt` lists the five first-party library schemes' own declarations**,
  not their transitive re-exports or `@_exported import` surface (none are currently
  present, but the script does not specifically verify their absence). The report's
  rows contain symbol path/kind/file:line only; it does not capture declaration
  signatures, defaults, availability, or ABI. `--check` therefore detects inventory
  drift, not every source/API compatibility change.

## 7. Historical CI gates proposal (superseded; checks remain local/manual)

The following two new CI checks were proposed at this historical checkpoint. They
were removed by maintainer request; the scripts remain available for local/manual
verification. The original existing `ci.yml` host-app build remains unchanged.

- **`api-surface.yml`** — runs `bash Scripts/api-baseline.sh --check`. Fails, printing
  the diff, if `Docs/development/api-baseline.txt` does not match a fresh symbol-graph
  extraction. This is the mechanism that makes a new public symbol a deliberate,
  reviewed act (Phase 0 item 5).
- **`dependency-gate.yml`** — runs the reusable `Scripts/dependency-gate.sh`, which fails
  if `Sources/SwapFoundationKit/` (the *default* target only) contains a vendor import
  (including import attributes/access modifiers/selective imports), with the sole
  exact-path exception for the guarded `SFKFirebaseLogger` FirebaseAnalytics adapter;
  and fails if `swift package describe` reports a third-party product reachable through
  any local target dependency. **This gate is written against the target v4 state described
  in plan section 8** ("the default product has zero third-party dependencies"). At the
  start of this Phase-0 workstream, `Package.swift` still declared Toast/Pulse/PulseUI/
  PulseProxy as dependencies of the default `SwapFoundationKit` target; a concurrent
  workstream on this same branch extracted them into `SwapFoundationKitToast`/
  `SwapFoundationKitPulse` while this ledger was being authored, and the gate now passes
  against this branch as committed (verified locally — see section 2's acceptance table).
  The gate remains written defensively (it does not assume the extraction is permanent)
  because further Sources/Package.swift changes from other concurrent workstreams could
  still reintroduce a vendor import or dependency before this branch merges; that is
  exactly the regression this gate exists to catch.

Both workflows only add new jobs; the existing host-app build job in `ci.yml` is
unchanged.
