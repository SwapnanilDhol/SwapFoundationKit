# SwapFoundationKit Documentation

Quick links to all documentation.

## Getting Started

| Guide | Description |
|-------|-------------|
| [Quick Start](../README.md#quick-start) | Framework initialization and basic usage |
| [Migration Guide](migration/migration-guide.md) | Step-by-step guide for migrating an iOS app to SFK |

## Module Reference

Each module has its own README with full API reference and code examples:

| Module | Description |
|--------|-------------|
| [Core](../Sources/SwapFoundationKit/Core/README.md) | Networking, security, backup, configuration |
| [Services](../Sources/SwapFoundationKit/Services/README.md) | Haptics, logging, analytics, defaults, deeplinks, toasts, pro gating, notifications |
| [UI](../Sources/SwapFoundationKit/UI/README.md) | Buttons, settings, onboarding, pickers, glass, aura, barcode, alerts, appearance |
| [Extensions](../Sources/SwapFoundationKit/Extensions/README.md) | Date, String, Number, Collection, Bundle, URL, FileManager, Result, JSON, async |
| [Utilities](../Sources/SwapFoundationKit/Utilities/README.md) | Debouncer, Throttler, environment, launch arguments |
| [Currency](../Sources/SwapFoundationKit/Currency/README.md) | 35 currencies, exchange rate management |
| [ImageProcessor](../Sources/SwapFoundationKit/ImageProcessor/README.md) | Image manipulation, caching, compression |
| [ItemSync](../Sources/SwapFoundationKit/ItemSync/README.md) | App Group sync for widgets and extensions |
| [WatchSync](../Sources/SwapFoundationKit/WatchSync/README.md) | Type-safe Watch Connectivity |
| [Protocols](../Sources/SwapFoundationKit/Protocols/README.md) | Coordinator, ValueDefaultProvider, AppMetaData |
| [Compatibility](../Sources/SwapFoundationKit/Compatibility/README.md) | iOS 26+ forward-compatible wrappers |
| [Ads](../Sources/SwapFoundationKit/Ads/README.md) | Google Mobile Ads integration |

## Migration Tools

| Resource | Description |
|----------|-------------|
| [Audit Catalog](migration/catalog.yaml) | 60+ capabilities with tier classifications for auditing host apps |
| [Capabilities Catalog](capabilities.yaml) | Agent-first index (13 domains) for checking SFK before building host-app features |
| [Agent Workflow](development/agents.md) | LLM agent workflow for auditing and migration |
| [Feature Discovery Workflow](development/feature-discovery.md) | How agents should check SFK first during host-app development |

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
