---
name: swap-foundation-kit
description: >
  Use when the user mentions SwapFoundationKit, SFK, or wants to audit, migrate,
  or build with SwapFoundationKit components. Also triggers on: haptics, logger,
  analytics, UserDefaults, networking, security, backup, currency, image
  processor, debouncer, throttler, settings screen, onboarding, alerts, item
  picker, toast, file export/import, deeplink, ItemSync, WatchSync, SFKButton,
  glass materials, UIKit extensions, ads manager, configuration service,
  environment, launch arguments, pro gate, notifications, Pulse, PulseUI,
  network inspector, debug console, appearance, rounded font, hosting
  controller, JSON codable, device info, async collections.
---

# SwapFoundationKit

A comprehensive Swift package providing essential utilities, extensions, UI components, and services for iOS development.

## Source of Truth

Read files in this order:

1. `Docs/capabilities.yaml` — Agent-first discovery catalog (13 domains)
2. `README.md` — Parent index with links to all 12 module READMEs
3. Module READMEs under `Sources/SwapFoundationKit/` — Per-module API references
4. `Docs/migration/catalog.yaml` — Curated audit catalog (60+ capabilities with tiers)
5. `AGENTS.md` — LLM workflow document
6. `Docs/migration/migration-guide.md` — Full migration guide

## Workflows

### Build a Host-App Feature

1. Read `Docs/capabilities.yaml` first
2. Match the request to one or more domains
3. Read the linked module README for that domain
4. Decide: **use_sfk_directly** / **wrap_sfk** / **keep_custom**
5. Only implement custom code if no documented SFK public API fits

### Audit a Host App for Redundant Implementations

1. Read `Docs/migration/catalog.yaml`
2. Start with `audit_tier: exact` capabilities
3. Search for `host_search_terms` and `suspicious_file_patterns`
4. Classify: **replace** / **review** / **keep**
5. Cite file paths from both repos
6. Only expand to heuristic/manual tiers if requested

### Migrate a Specific Capability

1. Find the capability in `Docs/migration/catalog.yaml`
2. Read the relevant module README for API details
3. Verify the host app doesn't fall under "keep custom when"
4. Replace local implementations with SFK equivalents
5. Delete old local implementations
6. Build and verify

### Add a New SFK Component

1. Place source files under the appropriate `Sources/SwapFoundationKit/` subdirectory
2. Follow conventions: `SFK` prefix for UI types, `*Service`/`*Manager`/`*Helper` for services
3. Create or update the module README
4. Update `Docs/migration/catalog.yaml` and `Docs/capabilities.yaml`
5. Add trigger keywords to this SKILL.md description

## Rules

- **Check `Docs/capabilities.yaml` first** before building reusable UI, utilities, or infrastructure
- **Start audits with exact tier** to avoid noise
- **Never suggest internal-only helpers** as host-app replacements
- **Keep app-specific facades** when they add domain behavior
- **Prefer false negatives** over false positives in audits
- **Cite file paths** for every finding

## Module Index

| Module | README | Key Types |
|--------|--------|-----------|
| Core | [Core/README.md](Sources/SwapFoundationKit/Core/README.md) | HTTPClient, SecurityService, BackupService, ConfigurationService |
| Services | [Services/README.md](Sources/SwapFoundationKit/Services/README.md) | HapticsHelper, Logger, AnalyticsManager, UserDefault, DeeplinkHandler, ToastManager, SFKProGate, SFKNotificationService |
| UI | [UI/README.md](Sources/SwapFoundationKit/UI/README.md) | SFKButton, SFKSettingsScreen, SFKSegmentedProgress, SFKItemPickerView, BarcodeScannerScreen, SFKAppearanceManager |
| Extensions | [Extensions/README.md](Sources/SwapFoundationKit/Extensions/README.md) | Date, String, Number, Collection, Bundle, URL, FileManager, Result, JSONCodable, async collections |
| Utilities | [Utilities/README.md](Sources/SwapFoundationKit/Utilities/README.md) | Debouncer, Throttler, SFKAppEnvironment, SFKLaunchArguments |
| Currency | [Currency/README.md](Sources/SwapFoundationKit/Currency/README.md) | Currency, ExchangeRateManager |
| ImageProcessor | [ImageProcessor/README.md](Sources/SwapFoundationKit/ImageProcessor/README.md) | ImageProcessor, SFKImageCompressor |
| ItemSync | [ItemSync/README.md](Sources/SwapFoundationKit/ItemSync/README.md) | SyncableData, DataSyncService, ItemSyncServiceFactory |
| WatchSync | [WatchSync/README.md](Sources/SwapFoundationKit/WatchSync/README.md) | WatchSyncService, WatchSyncEnvelope, WatchSyncTransport |
| Protocols | [Protocols/README.md](Sources/SwapFoundationKit/Protocols/README.md) | Coordinator, ValueDefaultProvider, AppMetaData |
| Compatibility | [Compatibility/README.md](Sources/SwapFoundationKit/Compatibility/README.md) | iOS 26+ forward-compatible wrappers |
| Ads | [Ads/README.md](Sources/SwapFoundationKit/Ads/README.md) | AdsConfiguration, AdUnitConfiguration |
