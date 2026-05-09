# AGENTS.md

## Purpose

This repository ships an LLM-friendly workflow for:
1. Auditing host apps for redundant implementations after adopting `SwapFoundationKit`
2. Migrating host app code to use SFK capabilities
3. Adding or updating capabilities within the SFK package itself

## Source of Truth

Read files in this order:

1. `Docs/host-app-audit-catalog.yaml` — Curated audit catalog with tier classifications
2. `README.md` — Full capability reference (48 numbered items with API, examples, migration steps)
3. `SKILL.md` — Skill file with trigger keywords and quick capability lookup
4. Relevant source files under `Sources/SwapFoundationKit/`

The audit catalog is the primary source of truth for audits because it is curated against
the package's public API and marks each capability as `exact`, `heuristic`, or `manual`.
The README is the primary source of truth for migration and API reference.

## Audit Workflow

When tasked with "audit a host app for overlap with SFK":

### Step 1: Read the Catalog

```
Read Docs/host-app-audit-catalog.yaml
```

### Step 2: Start with Exact Tier

For each capability where `audit_tier: exact`:

1. Search the host app for `host_search_terms`
2. Look for files matching `suspicious_file_patterns`
3. Read the `keep_custom_when` conditions — if any apply, skip or mark as `keep`
4. Classify the finding:
   - **replace**: host app recreated SFK capability verbatim → safe to migrate
   - **review**: overlap exists, but host app may need an app-level wrapper above SFK
   - **keep**: domain-specific code, SFK should stay below it

### Step 3: Cite Evidence

For every finding, provide:
- Host app file path and line numbers
- Matching SFK capability ID and source file
- The specific overlap (e.g., "host has `HapticManager` with `lightImpact()` → replace with `HapticsHelper.lightImpact()`")

### Step 4: Expand Tiers (Optional)

Only run `heuristic` and `manual` tiers if:
- The user explicitly requests broader coverage
- The exact tier does not explain the overlap they suspect

### Step 5: Return Structured Output

```
## Audit Summary
- X exact-tier capabilities checked
- Y findings: A replace, B review, C keep

## Replace (migrate first)
1. [Capability ID] — host file → SFK replacement
2. ...

## Review (evaluate case-by-case)
1. [Capability ID] — host file → SFK replacement (note: keep wrapper if...)
2. ...

## Keep (domain-specific)
1. [Capability ID] — host file (reason: ...)
2. ...

## Suggested Migration Order
1. Start with ...
2. Then ...
3. Finally ...
```

## Migration Workflow

When tasked with "migrate [capability] to SFK":

1. Find the capability in `README.md`'s Capabilities Checklist (numbered 1-48)
2. Read that section's:
   - API reference and code examples
   - Step-by-step migration instructions
   - "Keep custom when" conditions
3. Verify the host app doesn't fall under "keep custom when"
4. Apply the migration steps:
   - Add `import SwapFoundationKit` to affected files
   - Replace local implementations with SFK equivalents
   - Update call sites to match SFK API
   - Delete old local implementation files
5. Build and verify no regressions

## Adding a New Capability

When adding a new component to the library:

1. Place source files under the appropriate `Sources/SwapFoundationKit/` subdirectory
2. Follow conventions:
   - `SFK` prefix for public UI types (e.g., `SFKButton`, `SFKCard`)
   - No prefix for protocols (e.g., `SettingsItem`, `AnalyticsEvent`)
   - `*Service`, `*Manager`, `*Helper` suffix for services
   - `*+Extensions.swift` for type extensions
   - `#Preview` blocks with multiple variants
   - Doc comments with `## Usage` code examples
3. Update `README.md`:
   - Add a new numbered capability in the Capabilities Checklist
   - Include: tier, confidence, description, source path, search terms, suspicious patterns, API, migration steps, "keep custom when"
   - Add to the API Reference section
4. Update `Docs/host-app-audit-catalog.yaml`:
   - Add a new `capabilities` entry with: `id`, `audit_tier`, `confidence`, `replace_with`, `public_symbols`, `host_search_terms`, `suspicious_file_patterns`, `keep_custom_when`, `source_files`
5. Update `SKILL.md`:
   - Add trigger keywords to the `description` field
   - Add entry to the Quick Capability Lookup table

## Updating an Existing Capability

When modifying public API of an existing component:

1. Update the source code
2. Update the capability section in `README.md` (API, examples, migration steps)
3. Update `Docs/host-app-audit-catalog.yaml`:
   - `public_symbols` if method signatures changed
   - `host_search_terms` if new search patterns apply
   - `source_files` if files moved or were added
4. If the API changed significantly, update code examples in README
5. If a renamed capability, update the `replace_with` field in the catalog

## Maintenance Rules

- Update `Docs/host-app-audit-catalog.yaml` whenever a public SFK API is added, removed, renamed, or intentionally deprecated
- Do not advertise internal-only helpers as host-app replacements
- If the README or migration guide drifts from the public API, fix the catalog first, then align the prose docs
- Keep audit guidance focused on replaceable capabilities, not every helper in the package
- Prefer false negatives over noisy false positives in audits
- Audit against public API only — ignore internal implementation details
- Keep app-specific facades when they add domain behavior — SFK should sit underneath

## File Structure Reference

```
SwapFoundationKit/
├── SKILL.md                          ← This skill file (LLM trigger + workflows)
├── AGENTS.md                         ← This file (detailed agent workflows)
├── README.md                         ← Full capability reference (48 items)
├── Docs/
│   ├── host-app-audit-catalog.yaml   ← Audit catalog (source of truth for audits)
│   ├── onboarding-components.md      ← Onboarding UI documentation
│   └── settings-update-banner.md     ← Settings banner integration docs
└── Sources/SwapFoundationKit/        ← All source code
```

## Why SKILL.md and AGENTS.md Coexist

- **`SKILL.md`** is the environment-specific trigger file. It tells LLM agents when to activate
  this skill and provides quick-reference workflows and capability lookup tables.
- **`AGENTS.md`** is the package-traveling workflow document. It provides detailed, structured
  instructions for any agent or human reviewer to follow, regardless of whether the skill
  is installed in their environment.
- **`host-app-audit-catalog.yaml`** is the curated data source. It lists capabilities with
  machine-readable audit metadata (tiers, search terms, file patterns).

The catalog and AGENTS.md travel with the package and are easier for any agent or human
reviewer to consume. SKILL.md is the opt-in activation layer.
