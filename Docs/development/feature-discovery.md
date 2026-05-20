# Feature Discovery Workflow

Use this workflow when an agent is building a feature in a host app and needs to decide whether `SwapFoundationKit` already provides part or all of the solution.

## Goal

Before writing custom host-app UI, utilities, or infrastructure, check SFK first.

The intended order is:

1. Look for an existing SFK capability
2. Use SFK directly when it fits
3. Wrap SFK in host-app code when the app needs domain behavior
4. Build custom only when SFK has no suitable public API or the app intentionally diverges

## Source of truth

Read files in this order:

1. `Docs/capabilities.yaml`
2. `Docs/README.md`
3. Domain-specific guides referenced by the catalog
4. `README.md`
5. Relevant public source files under `Sources/SwapFoundationKit/`

## Hard rule categories

Agents should check SFK first for:

- settings
- buttons
- onboarding
- pickers
- alerts and confirmations
- sync/shared storage
- generic utilities and reusable infrastructure

## Decision model

For every host-app feature request, return one of these decisions internally before implementing:

- **use_sfk_directly**
- **wrap_sfk**
- **keep_custom**

### Use SFK directly

Choose this when:

- the capability is generic
- the host app does not need intentional visual divergence
- the public SFK API already matches the need closely

### Wrap SFK

Choose this when:

- SFK provides the primitive
- the host app still needs domain routing, business logic, analytics tagging, or coordination on top

Example:

- use `SFKSettingsScreen` for the shell
- keep subscription gating or navigation routing in the host app

### Keep custom

Choose this when:

- SFK has no suitable public API
- the app intentionally diverges in design or behavior
- the feature is mostly business/domain logic rather than reusable infrastructure

## Expected implementation behavior

When an agent is asked to build a host-app feature:

1. Read `Docs/capabilities.yaml`
2. Match the feature to one or more domains
3. Open the referenced guide/example files
4. Decide whether SFK should be used directly, wrapped, or skipped
5. Only then implement the host-app change

## Expected output behavior

The agent should state:

- which SFK domain(s) it checked
- which public API it selected
- whether it is using SFK directly or wrapping it
- why custom code was kept if SFK was not used

## Reuse boundary

Use SFK for:

- generic UI
- utilities
- infrastructure
- reusable presentation patterns

Keep in the host app:

- feature-specific flows
- domain models
- business rules
- navigation
- monetization rules
- product-specific orchestration
