# v4 implementation checkpoint

This is the implementation handoff for the [refactoring plan](v4-simplification-refactoring-plan.md), not a declaration that v4 is ready to release.

## Committed baseline

`98ce079` commits the reviewed transport hardening, five-product API inventory, dependency gates, regression tests, and documentation on top of the Pulse/Toast extraction. That checkpoint passed 289 tests, package and catalog builds, the API baseline check, and dependency checks.

Those results apply to that checkpoint only. They do not validate subsequent product moves or UI changes.

## Integrated implementation

Three Luna implementation workstreams have been integrated:

| Workstream | Scope |
|---|---|
| Product boundaries and services | Thirteen products; Networking, Authentication, Sync, Media, Currency, RemoteAI, Firebase, and Legacy extracted; injectable analytics/access policy/media roles; standalone reachability |
| Theme and controls | `SFKTheme` environment tokens; concise button and text-field APIs; themed chips, cards, typography, empty states, progress and secondary presentation |
| Typed settings and pickers | Generic settings sections/rows; typed single/multiple selection; binding-driven color picker; closure/SwiftUI photo-picker integration |

The in-repository host catalog, module references, capability/audit catalogs, and migration guide have been updated to the new product ownership and canonical APIs. Compilation and behavioral fixtures were added without running repeated test suites during implementation, at the maintainer's request.

## Verification of the integrated implementation

Verified on 2026-08-31 with Xcode 26.6 and the iOS 26.5 simulator SDK:

- All package libraries and test targets compile.
- The consolidated five-target suite passes: **303 tests, 0 failures, 0 skipped** (307 executions including parameterized cases), on iPhone 17 Pro.
- The in-repository catalog app builds for a generic iOS Simulator destination.
- The 13-product API inventory is regenerated, and an independent `api-baseline.sh --check` passes. Default public types: 235 → 152; UI: 92 → 102; all products: 262 → 286. The reduction targets remain unmet because canonical and compatibility APIs coexist.
- Dependency-boundary checks, guarded-import fixtures, API-parser fixtures, YAML/source-path/documentation-link checks, and `git diff --check` pass.
- Authentication source comparison against `98ce079` contains only file moves and imports; its existing contract tests run in the consolidated suite.

Local verification artifacts are under `/tmp/sfk-v4-integration.6vRteQ`: `final-tests.xcresult`, `final-tests.log`, `host-build-final.log`, `api-baseline-write.log`, and `api-baseline-check.log`. Temporary paths are evidence from this checkout, not portable release artifacts. UI compile fixtures do not prove visual or accessibility behavior; those require the separate checks below.

## Deliberately retained compatibility

- The opt-in Legacy product retains deprecated bootstrap/configuration and `SFKProGate`.
- Existing large UI initializers, erased settings adapters, picker view models/delegates, and the older watch transport remain deprecated rather than deleted.
- `NetworkService.backendHeadersProvider` remains a deprecated global closure; instance injection is the canonical replacement.
- Explicit product imports are required for moved symbols. Legacy is not an automatic re-export shim for the old default import.

Consequently, product extraction and new APIs are implemented, but the plan's public-type reduction, maximum legacy-initializer size, and zero-static-configuration-closure acceptance criteria are not yet satisfied. Relocation and deprecation must not be counted as deletion.

## Release gates still required

- Expanded accessibility, contrast, Dynamic Type, Reduce Motion, and visual/snapshot verification; catalog examples are not a substitute for automated coverage.
- Repeat the API inventory after compatibility removal and enforce the agreed surface budgets.
- Real-device Authentication and App Group/Watch Connectivity checks where applicable.
- Two named representative host applications migrated and verified. The package plan does not name those repositories; do not infer authorization to alter arbitrary neighboring projects.
- Compatibility-removal approval after consumer migration. Deprecation or relocation is not evidence that a symbol has been safely removed.
- The full acceptance matrix in the primary plan, including public-surface reductions and documentation-count/compatibility-annotation CI gates. The API inventory gate alone does not enforce those budgets.

Preserve authentication wire formats, binding policy, keychain namespaces, pending-enrollment recovery, retries, and cancellation throughout extraction. Do not change backend deployment or enforcement as part of this package refactor.
