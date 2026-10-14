# SwapFoundationKitOnboarding

Opt-in layout rules and containers for full-screen onboarding and wizard flows
that hold their shape on iPhone, iPad and iPhone Duo (closed and open). Add the
`SwapFoundationKitOnboarding` product and `import SwapFoundationKitOnboarding`.

- Layout rules: `SFKWindowPaneLayout`, `SFKTwoPaneSplit`, `SFKOnboardingWideWindowMode`,
  `SFKOnboardingLayout`, the `twoPaneSplit` / `isOnboardingPaneColumn` /
  `onboardingWideWindowMode` / `onboardingBrandMark` environment values,
  `SFKVerticalBarProbe`, the fold math (`SFKFoldRegionLayout`, `SFKFoldPose`,
  `SFKFoldColumnPlacement`, `.sfkFoldAwareColumn(maxWidth:)`) and
  `SFKOrientationPolicy.keepOrientationCurrent(in:)`.
- Containers: `SFKOnboardingWindow`, `SFKOnboardingStep`, `SFKOnboardingStepHeadline`,
  `SFKOnboardingFooterContainer`, `SFKOnboardingFooter`, `SFKOnboardingPrimaryButton`.
- Components: `SFKOnboardingBrandMark`, `SFKOnboardingSelectionCard`,
  `SFKOnboardingSelectionStatus`, `SFKOnboardingPressableRowButtonStyle`.

See [the onboarding guide](../../Docs/guides/onboarding.md#swapfoundationkitonboarding-product).
