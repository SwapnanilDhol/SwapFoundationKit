# Acceptance-check implementation specification

`Scripts/v4-acceptance.py` and the source-only negative fixtures/tests are implemented
for local/manual verification after the source cleanup. The newly added GitHub
workflows were removed by maintainer request; the original existing
`.github/workflows/ci.yml` remains unchanged from `origin/main` and retains its
host-app build. The integrator owns the catalog data and reviewed final budgets.

Implemented in this checkout. The 2026-09-01 budget review measured 103 default,
53 UI, and 226 all-product types after the reviewed compact-button addition and
baseline reconciliation. Those regression limits are enforced; original
75/39/157 design targets remain recorded as unmet in the JSON and API ledger.
The inventory comparison and static acceptance checks are run locally/manually, not
as GitHub Actions jobs.

## Inputs and invariants

- Read `Docs/development/api-baseline.txt`, produced by the unchanged symbol-graph
  methodology. Validate the baseline locally with `api-baseline.sh --check` before
  evaluating budgets. Do not substitute a grep count for the symbol inventory.
- Enforce top-level public-type budgets from a small JSON file
  `Docs/development/v4-api-budgets.json`. Initially use 75 default, 39 UI, and 157
  all-product types as the original design targets; if measured retention requires
  an exception, report it to the integrator, do not silently raise budgets.
- Every located public `init` symbol must have at most ten argument labels. Use
  the symbol graph path's initializer argument-label list, not commas in raw Swift
  source. Configurations can use focused properties after initialization.
- Enforce at most six labels for the explicit canonical/common constructors listed
  in the JSON input. Do not treat every advanced overload as a common constructor.
- Reject obsolete public API roots listed in the JSON input (bootstrap,
  settings-erasure/view-model/delegate/configurator compatibility surfaces).
- Reject mutable **public** static closure properties in Swift sources, including
  declarations in public extensions and multiline declarations. Exclude comments,
  string literal contents, private/internal implementation registries, and immutable
  static lets. Test positive and negative examples; document parser limitations.

## Catalog consistency

- Parse both YAML catalogs; reject duplicate IDs, missing/empty domains or
  capabilities, and nonexistent `source_files`, `docs`, or `examples` paths.
- Record actual domain/capability counts in a machine-readable tracked summary,
  `Docs/development/catalog-counts.json`. Check against catalog lengths. Avoid
  sprinkling hand-maintained numerical claims across READMEs; root will remove them.
- Check removed public symbols are not still advertised in `public_symbols`,
  `public_api`, or `replace_with`. Matching host-search terms and migration removal
  notes must remain allowed. Keep matching exact enough to avoid false positives.
- Curated capability entries need owning product, migration replacement,
  compatibility status, and removal release metadata. Coordinate the chosen schema
  with root; do not rewrite catalogs yourself.

## Tests and local/manual verification

- Write deterministic fixture tests using temporary directories and small synthetic
  baselines/catalogs. Cover over-budget, oversized initializer, forbidden public
  root, multiline/public-extension static closure, stale path/count, duplicate ID,
  and valid private registry cases.
- Make dependencies explicit: if PyYAML is used, install it in an isolated local
  environment rather than assuming a machine-global install.
- Keep the checks/scripts available for local/manual use. The original existing CI
  workflow is unchanged; do not add the removed dependency/API/acceptance workflows.
  For local simulator checks, use simslim and an app-specific clone as required
  by AGENTS.md; do not use another app's simulator.
- Preserve the catalog-app build. Run tests after source integration, not inside the
  implementation agent. Root runs the consolidated checks and fixes genuine defects.
