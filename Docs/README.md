# SwapFoundationKit Documentation

Quick links to all documentation.

## Getting Started

| Guide | Description |
|-------|-------------|
| [Quick Start](../README.md#quick-start) | Theme injection and zero-bootstrap usage |
| [Migration Guide](migration/migration-guide.md) | Step-by-step guide for migrating an iOS app to SFK |

## Module Reference

Each module has its own README with full API reference and code examples:

| Module | Description |
|--------|-------------|
| [Core](../Sources/SwapFoundationKit/Core/README.md) | Security/backup and cross-product infrastructure reference |
| [Networking](../Sources/SwapFoundationKitNetworking/README.md) | HTTP client, reachability, contracts, instrumentation |
| [Authentication](../Sources/SwapFoundationKitAuthentication/README.md) | App Attest and authenticated installation sessions |
| [Sync](../Sources/SwapFoundationKitSync/README.md) | App Group storage and Watch Connectivity |
| [Media](../Sources/SwapFoundationKitMedia/README.md) | Image processing and remote loading |
| [Remote AI](../Sources/SwapFoundationKitRemoteAI/README.md) | Host-configured AI requests |
| [Firebase](../Sources/SwapFoundationKitFirebase/README.md) | Explicit host analytics forwarding |
| [Services](../Sources/SwapFoundationKit/Services/README.md) | Haptics, logging, analytics, defaults, deeplinks, toasts, pro gating, notifications |
| [UI](../Sources/SwapFoundationKit/UI/README.md) | Buttons, settings, onboarding, pickers, glass, aura, barcode, alerts, appearance |
| [Extensions](../Sources/SwapFoundationKit/Extensions/README.md) | Date, String, Number, Collection, Bundle, URL, FileManager, Result, JSON, async |
| [Utilities](../Sources/SwapFoundationKit/Utilities/README.md) | Debouncer, Throttler, environment, launch arguments |
| [Currency](../Sources/SwapFoundationKitCurrency/Currency/README.md) | 58 currencies, exchange rate management |
| [ImageProcessor](../Sources/SwapFoundationKitMedia/ImageProcessor/README.md) | Image manipulation, caching, compression |
| [ItemSync](../Sources/SwapFoundationKitSync/ItemSync/README.md) | App Group sync for widgets and extensions |
| [WatchSync](../Sources/SwapFoundationKitSync/WatchSync/README.md) | Type-safe Watch Connectivity |
| [Protocols](../Sources/SwapFoundationKit/Protocols/README.md) | Coordinator, ValueDefaultProvider, AppMetaData |
| [Ads](../Sources/SwapFoundationKit/Ads/README.md) | Google Mobile Ads integration |

## Migration Tools

| Resource | Description |
|----------|-------------|
| [Audit Catalog](migration/catalog.yaml) | Capabilities with tier classifications for auditing host apps |
| [Capabilities Catalog](capabilities.yaml) | Agent-first index for checking SFK before building host-app features |
| [Agent Workflow](development/agents.md) | LLM agent workflow for auditing and migration |
| [Feature Discovery Workflow](development/feature-discovery.md) | How agents should check SFK first during host-app development |

## Refactoring and Migration Planning

| Document | Description |
|----------|-------------|
| [v4 Simplification Refactoring Plan](development/v4-simplification-refactoring-plan.md) | Maintainer-facing architecture, API, sequencing, acceptance criteria, and rollback plan |
| [v4 Simplification Migration Guide](migration/v4-simplification-migration-guide.md) | Staged v3-to-v4 procedure for package maintainers and host applications |
| [v4 API Ledger](development/v4-api-ledger.md) | Final measured API reduction, reviewed retention/budgets, and historical baseline |
| [v4 Implementation Status](development/v4-implementation-status.md) | Completed cleanup, exact verification evidence, and release limitations |

## Agent Files

| File | Purpose |
|------|---------|
| [AGENTS.md](../AGENTS.md) | Package-traveling LLM workflow (at repo root) |
| [SKILL.md](../SKILL.md) | Environment trigger + quick capability lookup |

## Guides

| Guide | Description |
|-------|-------------|
| [Networking RFC](guides/networking-rfc.md) | Proposed refactor for the networking stack |
| [Google Mobile Ads](guides/google-mobile-ads.md) | Optional ads module setup and migration |
| [Onboarding Components](guides/onboarding.md) | Generic onboarding UI components reference |
| [Pulse Integration](guides/pulse-integration.md) | Host-app setup guide for SFK Pulse logging and console access |
| [Settings UI](guides/settings.md) | Build host-app settings screens with SFK components |
| [Settings Patterns](guides/settings-patterns.md) | Architecture patterns and best practices for settings screens |

## Reference

| Document | Description |
|----------|-------------|
| [Trial Audit](reference/trial-audit.md) | Subscription trial audit documentation |
| [Pulse Integration Checklist](reference/pulse-integration-checklist.md) | Audit checklist for host-app Pulse integration |
| [Settings Integration Checklist](reference/settings-integration-checklist.md) | Audit checklist for host-app settings integration |
