# AGENTS.md

## Purpose

This repository ships an LLM-friendly audit workflow for host apps that want to
remove redundant implementations after adopting `SwapFoundationKit`.

## Source Of Truth

Read files in this order when the task is "audit a host app for overlap with SFK":

1. `Docs/host-app-audit-catalog.yaml`
2. `llm-migration-guide.md`
3. `README.md`
4. the relevant files under `Sources/SwapFoundationKit`

The audit catalog is the primary source of truth because it is curated against
the package's public API and marks each capability as `exact`, `heuristic`, or
`manual`.

## Audit Workflow

1. Read the catalog and start with `audit_tier: exact`.
2. Search the host app for the capability's `host_search_terms` and
   `suspicious_file_patterns`.
3. Classify each finding as one of:
   - `replace`: the host app recreated an SFK capability and should migrate.
   - `review`: there is overlap, but the host app may still need an app-level wrapper.
   - `keep`: the code is domain-specific and SFK should stay below it.
4. Cite concrete file references from the host app and point to the matching SFK
   capability or source file.
5. Only run `heuristic` and `manual` tiers if the user wants a broader sweep or
   if the exact tier does not explain the overlap they suspect.

## Maintenance Rules

- Update `Docs/host-app-audit-catalog.yaml` whenever a public SFK API is added,
  removed, renamed, or intentionally replaced.
- Do not advertise internal-only helpers as host-app replacements.
- If the README or migration guide drifts from the public API, fix the catalog
  first, then align the prose docs.
- Keep audit guidance focused on replaceable capabilities, not every helper in
  the package.

## Why Not SKILL.md

`SKILL.md` can be useful later as a Codex-specific wrapper, but it should not be
the package's primary audit artifact. Skills are environment-specific and opt-in.
The catalog and this `AGENTS.md` travel with the package and are easier for any
agent or human reviewer to consume.
