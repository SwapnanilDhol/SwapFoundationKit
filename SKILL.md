---
name: swap-foundation-kit
description: >
  Use when the user mentions SwapFoundationKit, SFK, or wants to audit, migrate,
  or build with SwapFoundationKit components. Also triggers on: haptics, logger,
  analytics, UserDefaults, networking, security, backup, currency, image
  processor, debouncer, settings screen, onboarding, alerts, item picker,
  toast, file export/import, deeplink, ItemSync, WatchSync, SFKButton,
  glass compatibility, UIKit extensions, ads manager, configuration service.
---

# SwapFoundationKit

A comprehensive Swift package providing essential utilities, extensions, UI components, and services for iOS development.

## Source of Truth

Read files in this order:

1. `README.md` — Full capability reference with 48 numbered migration items, API summaries, and code examples
2. `Docs/host-app-audit-catalog.yaml` — Curated audit catalog with tier classifications (exact/heuristic/manual)
3. `Docs/onboarding-components.md` — Onboarding UI component documentation
4. `Docs/settings-update-banner.md` — Update banner integration for settings screens
5. `Docs/AGENTS.md` — LLM agent workflow for host app audits
6. Relevant source files under `Sources/SwapFoundationKit/`

## Workflows

### Audit a Host App for Redundant Implementations

When the user wants to find overlapping code in their app that SFK already provides:

1. Read `Docs/host-app-audit-catalog.yaml` first
2. Start with `audit_tier: exact` capabilities only
3. For each exact-tier capability:
   - Search the host app for `host_search_terms`
   - Look for `suspicious_file_patterns`
   - Check `keep_custom_when` conditions before flagging
4. Classify findings as:
   - **replace**: host app recreated SFK capability → migrate
   - **review**: overlap exists but host may need app-level wrapper
   - **keep**: domain-specific code, SFK should stay below it
5. Cite concrete file paths from both repos
6. Only expand to heuristic/manual tiers if the user requests broader coverage

### Migrate a Specific Capability

When the user wants to replace their implementation with SFK's:

1. Find the capability in `README.md`'s Capabilities Checklist (numbered 1-48)
2. Read that section's:
   - API reference and code examples
   - Step-by-step migration instructions
   - "Keep custom when" conditions
3. Verify the host app doesn't fall under "keep custom when"
4. Apply the migration steps
5. Delete the old local implementation
6. Build and verify

### Add a New SFK Component

When adding a new component to the library:

1. Place source files under the appropriate `Sources/SwapFoundationKit/` subdirectory
2. Follow the `SFK` prefix naming convention for public types
3. Add `#Preview` blocks with multiple variants
4. Update `README.md`:
   - Add a new numbered capability in the Capabilities Checklist
   - Add to the API Reference section
   - Include in the Quick Navigation table if significant
5. Update `Docs/host-app-audit-catalog.yaml` with a new capability entry
6. Update this `SKILL.md` trigger description if new keywords apply

### Update an Existing Capability

When modifying public API of an existing component:

1. Update the source code
2. Update the capability section in `README.md`
3. Update `Docs/host-app-audit-catalog.yaml` (public_symbols, search terms, source_files)
4. If the API changed significantly, update code examples in README
5. If a new capability emerged, add it to the catalog and README

## Rules

- **Always reference the README** for API details — never guess method signatures
- **Start audits with exact tier** before heuristic/manual to avoid noise
- **Never suggest internal-only helpers** as host-app replacements
- **Keep app-specific facades** when they add domain behavior — SFK should sit underneath
- **Prefer false negatives** over noisy false positives in audits
- **Audit against public API only** — ignore internal implementation details
- **Cite file paths** from both the host app and SFK source tree for every finding

## Quick Capability Lookup

| Keyword | README Section |
|---------|---------------|
| haptics, feedback | #1 Haptics Manager |
| logger, logging | #2 Logger |
| analytics, tracking | #3 Analytics Manager |
| userdefaults, preferences | #4 UserDefaults |
| networking, api, http | #5 Network Client |
| security, encryption, keychain | #6 Security Service |
| backup, export | #7 Backup Service |
| currency, exchange rate | #8 Currency Converter |
| image, resize, cache | #9 Image Processor |
| debounce, throttle | #10 Debouncer |
| date, formatter | #11 Date Utilities |
| string, validation | #12 String Utilities |
| number, formatting | #13 Number Formatting |
| hash, md5, sha | #14 Data Crypto |
| bundle, infoplist | #15 Bundle Extensions |
| collection, array, safe | #16 Collection Utilities |
| url, query | #17 URL Extensions |
| filemanager, directory | #18 FileManager Extensions |
| result, getOrElse | #19 Result Extensions |
| json, codable, encode | #20 JSON Codable |
| sync, widget, watch | #21 ItemSync + WatchSync |
| link, open, appstore | #22 App Link Opener |
| deeplink, route | #23 Deeplink Handler |
| toast, notification | #24 Toast Notifications |
| file export, import, document picker | #25 File Export/Import |
| device info, model | #26 Device Info |
| pasteboard, clipboard | #27 Pasteboard Service |
| location, search, mapkit | #28 Location Search |
| update, version check | #29 Update Availability |
| app store search | #30 App Store Search |
| photo picker, photos | #31 Photo Picker |
| barcode, scanner | #32 Barcode Scanner |
| pro banner, upgrade | #33 Pro Banner |
| aura, glow, background | #34 Aura Glow |
| button, SFKButton | #35 SFKButton |
| glass, liquid glass | #36 Glass Compatibility |
| alert, dialog, confirmation | #37 AlertPresenter |
| picker, item picker | #38 SFKItemPickerView |
| settings, settings screen | #39 Settings Screen UI |
| onboarding, chip, progress | #40 Onboarding UI |
| update banner | #41 Update Available Banner |
| uikit, uiview, uicolor | #42 UIKit Extensions |
| compatibility, ios version | #43 Compatibility Wrappers |
| configuration, config | #44 Configuration Service |
| ads, admob, google ads | #45 Ads Manager |
| protocols, coordinator | #46 Protocols |
| settings screen builder | #47 SFKSettingsScreen |
| item detail, source | #48 ItemDetailSource |
