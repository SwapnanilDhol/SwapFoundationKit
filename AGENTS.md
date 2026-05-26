# AGENTS.md

## Purpose

This repository ships an LLM-friendly workflow for:
1. Discovering whether SFK already covers a host-app feature before implementation
2. Auditing host apps for redundant implementations after adopting `SwapFoundationKit`
3. Migrating host app code to use SFK capabilities
4. Adding or updating capabilities within the SFK package itself

## Source of Truth

Read files in this order:

1. `Docs/capabilities.yaml` — Agent-first capability catalog (13 domains)
2. `Docs/migration/catalog.yaml` — Curated audit catalog (60+ capabilities with tiers)
3. Module READMEs under `Sources/SwapFoundationKit/` — Per-module API references
4. `README.md` — Quick reference with module index
5. `SKILL.md` — Trigger keywords and quick capability lookup

## Feature Discovery Workflow

When tasked with "build a feature in a host app" or "check whether SFK already has this":

### Step 1: Read the Capabilities Catalog
```
Read Docs/capabilities.yaml
```

### Step 2: Match the Request to a Domain
Check whether the request falls into a documented reusable domain:

| Domain | Docs |
|--------|------|
| settings | `Sources/SwapFoundationKit/UI/README.md` |
| buttons | `Sources/SwapFoundationKit/UI/README.md` — Buttons section |
| onboarding | `Sources/SwapFoundationKit/UI/README.md` — Onboarding section |
| pickers | `Sources/SwapFoundationKit/UI/README.md` — Pickers section |
| alerts / confirmations | `Sources/SwapFoundationKit/UI/README.md` — Alerts section |
| sync / shared storage | `Sources/SwapFoundationKit/ItemSync/README.md` |
| watch sync | `Sources/SwapFoundationKit/WatchSync/README.md` |
| haptics, logging, analytics | `Sources/SwapFoundationKit/Services/README.md` |
| networking, security, backup | `Sources/SwapFoundationKit/Core/README.md` |
| currency, exchange rates | `Sources/SwapFoundationKit/Currency/README.md` |
| image processing | `Sources/SwapFoundationKit/ImageProcessor/README.md` |
| notifications | `Sources/SwapFoundationKit/Services/README.md` — SFKNotificationService |
| pro gating | `Sources/SwapFoundationKit/Services/README.md` — SFKProGate |
| environment / launch args | `Sources/SwapFoundationKit/Utilities/README.md` |
| appearance / typography | `Sources/SwapFoundationKit/UI/README.md` — Appearance section |
| debounce / throttle | `Sources/SwapFoundationKit/Utilities/README.md` |
| extensions | `Sources/SwapFoundationKit/Extensions/README.md` |
| protocols | `Sources/SwapFoundationKit/Protocols/README.md` |

### Step 3: Decide the Reuse Strategy

- **use_sfk_directly**: the public SFK API already fits
- **wrap_sfk**: SFK provides the primitive, but the host app needs domain logic on top
- **keep_custom**: SFK does not fit or the host app intentionally diverges

### Step 4-5: Implement and State Decision
Only implement custom host-app code if no documented SFK public API fits. State which domain(s) were checked, which API was selected, and the reuse strategy.

## Audit Workflow

When tasked with "audit a host app for overlap with SFK":

1. Read `Docs/migration/catalog.yaml`
2. Start with `audit_tier: exact` capabilities only
3. For each: search host app for `host_search_terms`, check `suspicious_file_patterns`, respect `keep_custom_when`
4. Classify: **replace** / **review** / **keep**
5. Cite file paths from both repos
6. Only expand to `heuristic`/`manual` tiers if requested

### Structured Output
```
## Audit Summary
- X exact-tier capabilities checked
- Y findings: A replace, B review, C keep

## Replace (migrate first)
1. [Capability ID] — host file → SFK replacement

## Review (evaluate case-by-case)
1. [Capability ID] — host file → SFK replacement (note: keep wrapper if...)

## Keep (domain-specific)
1. [Capability ID] — host file (reason: ...)
```

## Migration Workflow

When tasked with "migrate [capability] to SFK":

1. Find the capability in `Docs/migration/catalog.yaml`
2. Read the relevant module README for API details
3. Verify the host app doesn't fall under "keep custom when"
4. Replace local implementations with SFK equivalents
5. Delete old local implementation files
6. Build and verify

## Adding a New Capability

1. Place source files under the appropriate `Sources/SwapFoundationKit/` subdirectory
2. Follow conventions:
   - `SFK` prefix for public UI types
   - No prefix for protocols
   - `*Service`, `*Manager`, `*Helper` suffix for services
   - `*+Extensions.swift` for type extensions
   - Doc comments with `## Usage` code examples
3. Create or update the module README under the subdirectory
4. Update `Docs/migration/catalog.yaml` with new capability entry
5. Update `Docs/capabilities.yaml` with new domain (if applicable)
6. Update `SKILL.md` trigger keywords and lookup table

## Maintenance Rules

- Update `Docs/migration/catalog.yaml` whenever public API is added, removed, or renamed
- Do not advertise internal-only helpers as host-app replacements
- Keep module READMEs in sync with source files
- Prefer false negatives over noisy false positives in audits
- Audit against public API only
- For SwiftUI UI, prefer semantic Dynamic Type text styles such as `.body`, `.subheadline`, `.footnote`, and `.caption` over hardcoded font sizes for titles, subtitles, and values.

## File Structure Reference

```
SwapFoundationKit/
├── README.md                             ← Parent index linking to modules
├── AGENTS.md                             ← This file — LLM workflow document
├── SKILL.md                              ← Environment trigger + quick lookup
├── Package.swift
├── Docs/
│   ├── README.md                         ← Documentation index
│   ├── capabilities.yaml                ← Feature discovery catalog (13 domains)
│   ├── migration/
│   │   ├── catalog.yaml                 ← Audit catalog (60+ capabilities)
│   │   └── migration-guide.md
│   ├── guides/                           ← In-depth guides
│   ├── reference/                        ← Audit checklists
│   └── development/
│       ├── agents.md                     ← (Legacy) agent workflows
│       ├── feature-discovery.md
│       └── refactoring-todo.md
└── Sources/SwapFoundationKit/
    ├── Core/README.md                    ← Networking, security, backup
    ├── Services/README.md                ← Haptics, logging, analytics, etc.
    ├── UI/README.md                      ← Buttons, settings, onboarding, etc.
    ├── Extensions/README.md              ← Date, String, Collection, etc.
    ├── Utilities/README.md               ← Debouncer, Throttler, environment
    ├── Currency/README.md                ← Currency + exchange rates
    ├── ImageProcessor/README.md          ← Image processing + compression
    ├── ItemSync/README.md                ← App Group sync
    ├── WatchSync/README.md               ← Watch Connectivity
    ├── Protocols/README.md               ← Coordinator, AppMetaData
    ├── Compatibility/README.md           ← iOS 26+ wrappers
    └── Ads/README.md                     ← Google Mobile Ads
```
