# v4 package finalization and merge brief

The maintainer's current direction is to finish the package refactor and merge it
into `main`. External application migrations are not a prerequisite for this merge.
This supersedes the earlier two-app approval gate; it does not authorize changes in
other repositories, backend deployments, credential resets, or protocol changes.

## Implementation contracts

1. **Settings and pickers:** retain the typed builder/binding API, remove the
   array/existential settings facade and delegate/view-model entry points. Keep
   rendering helpers internal. Prefer a small generic row with native SwiftUI
   controls over separate public wrappers for every settings variant. Host-owned
   navigation/actions replace canned information/developer dispatch tables.
2. **Controls:** remove oversized compatibility initializers/configurators and
   duplicate controls. Preserve customization through theme tokens, focused
   modifiers, and at-most-ten-argument advanced configurations. Common constructors
   remain at most six arguments. Share feedback policy; retain Dynamic Type,
   Reduce Motion, disabled/loading semantics, and semantic contrast overrides.
3. **Services:** remove the Legacy bootstrap product and its hidden prerequisites.
   Shared storage requires an explicit suite. Remove mutable public static
   configuration closures; backend headers and origins are instance-scoped.
   Keep one public watch-sync abstraction and internalize the lower-level adapter
   when still needed by item synchronization. App metadata is data, not an opener.
   Retain useful specialized capabilities and all authentication wire/storage behavior.
4. **Migration:** update every in-repository consumer, public catalog, and API
   mapping. Removed compatibility-only tests may be replaced with equivalent
   canonical-API behavior tests; do not delete failing behavioral coverage to pass.
5. **Measurement:** regenerate the same symbol-graph inventory after cleanup.
   Report actual reductions, including any remaining distance from the original
   numerical targets. Never count moves as all-product reductions or hide surviving
   APIs from the inventory. CI must enforce the reviewed surface and constructor
   constraints, catch stale catalog paths/counts, and reject obsolete compatibility
   APIs and global configuration closures.

## Parallel ownership

- Settings/pickers: `UI/Settings`, `UI/ItemPicker`, `UI/ColorPicker`, `UI/PhotoPicker`,
  `Protocols/Coordinator`, their host examples and directly corresponding tests.
- Controls: all remaining UI except `UIKitExtensions`, their host examples and tests;
  UI module README. Coordinate shared API changes with the settings agent.
- Services: manifest, Networking/Sync/Legacy and default Services/Protocols except
  Coordinator; owning service tests and integration imports. Authentication logic
  is frozen. Do not move products merely to improve a count.
- Integrator: central documentation/catalog reconciliation, static acceptance
  checks and CI, cross-workstream review, consolidated builds/tests, API inventory,
  commit and local merge to `main`.

## Verification and handoff

Implement before running the consolidated suite. Use compiler feedback to fix
integration defects. Add actual rendered UI/accessibility assertions where feasible,
not tests that only construct an unused view. Preserve authentication, networking,
sync, persistence, and optional-integration regression coverage. Build the catalog.
Run the API and dependency gates. Commit the result and merge non-destructively into
local `main`; do not push or delete branches unless separately requested.

Real-device App Attest/Watch/App Group validation remains an honest release limitation,
not a reason to refuse the requested repository merge.
