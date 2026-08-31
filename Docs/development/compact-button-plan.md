# Compact button implementation plan

## Intent

Promote the reusable compact toolbar/overlay control behind `SFKCloseButton` to
`SFKCompactButton`. Keep close-specific convenience calls working. Outside a
toolbar, the visible control must be at least 35 by 35 points with breathing room
around its content. A labeled control becomes a capsule, not a forced circle.

## Public API

- Add `SFKCompactButton` and `SFKCompactButtonChrome` (`toolbar`, `glass`).
- Icon-only initializer: `init(systemImage:accessibilityLabel:chrome:foreground:action:)`.
  Require both the symbol and accessible label; never default a generic action to
  an X or “Close”.
- Text initializer: `init(_:systemImage:chrome:foreground:action:)`, with optional
  `systemImage = nil`. This supports text alone and text plus an icon. Accessible
  naming comes from the visible title.
- Default the new component to `.glass`, making standalone calls self-contained.
  Toolbar callers explicitly choose `.toolbar`.
- Keep `SFKCloseButton` as a thin wrapper with both existing initializers and
  `.toolbar` default. Forward the X/Close semantics through the new component.
  Preserve custom symbols and accessibility labels in the existing icon overload.
- Preserve `SFKCloseButtonChrome` source compatibility with a typealias to the
  new enum, rather than duplicating rendering or conversion logic.
- Do not introduce loading, async actions, haptics, destructive roles, arbitrary
  view builders, or unrelated changes to `SFKButton`.

## Layout and behavior

- `.toolbar` adds no enclosing surface, padding, or forced 35-point frame; the
  system toolbar owns sizing and styling as before.
- Standalone `.glass` icons get at least 8 points of content padding and a
  minimum 35-point square circular surface. Use a simple Dynamic Type-aware
  sizing approach so larger symbols are not locked into a clipping fixed frame.
- Standalone text and icon/text labels use at least 12 points horizontal and
  8 points vertical padding, with a minimum width and height of 35 points.
  Allow the capsule to grow for title length and Dynamic Type.
- Apply sizing to the button label/surface, not only an invisible exterior frame.
  Keep circle/capsule hit regions consistent with their visual surfaces.
- Retain native iOS 26 glass button styling and the existing older-iOS fallback.
  Avoid accidentally adding custom padding on top of large native style insets.
- Use semantic theme typography, spacing, and foreground colors. A minimum is
  allowed to grow, and no truncation or fixed 35-point height should constrain text.

## Discovery and examples

Update the UI README, capabilities catalog, migration catalog, and root SKILL.md
with the new API. Explain `SFKButton` for semantic CTAs/loading versus
`SFKCompactButton` for lightweight toolbar/overlay controls, and keep the close
wrapper discoverable. Add host catalog examples for icon-only, text-only,
icon/text glass buttons and toolbar use; update searchable API names. Prefer
focused edits over unrelated playground cleanup.

## Verification

- Review compatibility calls, label/accessibility semantics, and both OS branches.
- Add focused rendered layout coverage to the existing control test suite for
  minimum standalone dimensions, capsule width/padding, and Dynamic Type growth.
  Include only tests that exercise behavior, rather than mirroring declarations.
- Parent agent builds the catalog and runs focused control tests on the existing
  SFK-specific simulator clone using simslim, with parallel test clones disabled.
- Stop after more than two failed test attempts; do not fix unrelated failures.
- Preserve the pre-existing edits to `Docs/README.md` and the untracked
  `Docs/development/review-request-plan.md`. Do not commit or publish.
