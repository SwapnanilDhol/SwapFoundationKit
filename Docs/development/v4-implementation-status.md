# v4 implementation and verification status

The breaking package cleanup shipped as 4.0.0. This record does not approve any change
to backend enforcement.

## Completed

- Eleven explicit products; default UI/utility product has no third-party
  dependency edges. Networking, Authentication, Sync, Media, Currency, RemoteAI,
  Firebase, Ads, Toast, and Onboarding are opt-in. The Pulse and Feedback products
  built during v4 development were removed before release.
- Shared semantic `SFKTheme`; compact controls and focused customization modifiers.
- Compatibility wrapper module removed; platform availability is handled at the
  direct call site where an iOS 26 API is required.
- Typed settings composition and selection bindings; native SwiftUI controls
  replace redundant specialized settings wrappers.
- Legacy bootstrap/configuration product, erased settings adapters, picker
  delegates/view models, oversized control constructors, and duplicate public
  watch adapter removed. Git history retains the removed implementations.
- Instance-scoped backend headers/origins; isolated analytics state with callbacks
  outside locks; pure app metadata and centralized URL opening.
- Explicit App Group suite injection, preserving existing suite/key behavior.
- Authentication remains in scope: isolated product plus smaller configuration
  constructor, with existing lifecycle, wire formats, key derivation, storage,
  cancellation, pending-enrollment recovery, and binding rules preserved.
- In-repository catalog migrated; primary plan, detailed migration guide, module
  references, 24-domain catalog, and 38-capability audit catalog synchronized.
- The compiler API inventory, measured budgets, constructor bounds, obsolete APIs,
  static configuration-closure, catalog, dependency, package-test, and catalog-build
  checks/scripts remain available for local/manual verification. The newly added
  GitHub workflows were removed by maintainer request. The original existing
  `.github/workflows/ci.yml` host-app build remains unchanged from `origin/main`.

## Measured result

| Public top-level types | Before extraction (`55ff7a1`) | Final |
|---|---:|---:|
| Default product | 235 | 100 |
| UI | 92 | 52 |
| All products | 262 | 223 |

The original 75/39/157 numerical design targets were **not achieved**. Distinct
specialized and security contracts are retained; the reviewed regression limits
are 100/52/223 after removing the compatibility wrapper module and replacing the legacy close-button wrapper with the semantic
compact-button type and reconciling the baseline. See
the [API ledger](v4-api-ledger.md) for the explicit scope
revision and retained-capability rationale. Moves and nesting are not claimed as
equivalent to deleting functionality.

## Verification — 2026-08-31

Xcode 26.6; iOS 26.5; iPhone 17 Pro simulator:

- All package library/test targets compile.
- The consolidated run executed **299 tests: 298 passed, one failed, none skipped**
  (303 executions including parameterized cases). The sole failure was a new
  immutable-appearance test asserting against the original rather than the
  customized copy.
- That assertion was corrected. A focused follow-up covering controls,
  NetworkService origin isolation/normalization, and five new authentication
  configuration tests passed **28/28**, zero failures/skips. It also compiled all
  test targets after the additions. Across both runs, all **304 distinct final
  test cases** have passing evidence; this is not a claim of a second complete
  304-test suite run.
- The in-repository catalog app builds for the generic iOS Simulator destination.
- A fresh compiler symbol-graph inventory was generated from all 12 products.
  Every public initializer is at most ten arguments; the named common paths are
  at most six.
- Static acceptance and dependency gates pass, including 7 acceptance fixtures,
  API-parser fixtures, dependency fixtures, and `git diff --check`.

Artifacts from this checkout are under `/tmp/sfk-v4-final.4qRSSM`:
`final-tests.xcresult`, `verified-followup.xcresult`, `host.log`,
`api-write.log`, and associated logs. These temporary local paths are evidence,
not portable release artifacts. An independent remote inventory regeneration has not
been run as part of this local merge; these checks remain local/manual.

## Release/adoption limitations

Before the 4.0.0 tag no external app was migrated and no backend was deployed. Two external apps are **not** a compatibility-removal or merge gate.
Real-device App Attest, Watch/App Group integration, full visual snapshots,
contrast, and Reduce Motion validation remain release/adoption work. Rendered
Dynamic Type checks provide bounded coverage, not a complete accessibility audit.
Existing Swift 6 migration warnings remain; the package uses Swift 5 language mode.

## 4.0.0 release check — 2026-11-16

Xcode 27.2; iPhone 18 Pro simulator. An internal cleanup (dead code, iOS-only guards,
duplicated private helpers, stale docs) landed before the tag with no public API change:
raw symbol graphs for all 11 products were identical before and after, and the full test
run matched the pre-cleanup run (211 XCTest with the same two toolchain-dependent
`SFKButtonColorResolverTests` failures, 133 Swift Testing tests passing). The API baseline
was regenerated with this toolchain. Open follow-ups are in
[refactoring-todo.md](refactoring-todo.md).

## 4.1.0 release check — 2026-11-27

Xcode 27.2; iPhone 17 Pro simulator. 4.1.0 adds to 4.0.0 and removes nothing:

- Remote banners: `SFKRemoteBanner`, `SFKRemoteBannerService`, `SFKRemoteBannerCard` (capability
  `remote-banner` in [capabilities.yaml](../capabilities.yaml)).
- `SFKCompactButtonChrome.corner`, a small surface-free icon button for the corner of a card. A host that
  switches exhaustively over `SFKCompactButtonChrome` needs a case for it.

The type budget rose by the three new top-level types, to 115/67/240 ([v4-api-budgets.json](v4-api-budgets.json)).
`Scripts/v4-acceptance.py` and `Scripts/dependency-gate.sh` pass, and the API baseline was regenerated.
Full test run: 231 XCTest with the same two toolchain-dependent `SFKButtonColorResolverTests` failures as
4.0.0 (they fail identically on the untouched `v4.0.0` tag), 133 Swift Testing tests passing. The 20 new
XCTest cases cover banner decoding, targeting, localization, impressions, dismissal and caching.

Goaley 1.16.1 is the first adopter, pinned to `85716b2`, the commit before this record.
