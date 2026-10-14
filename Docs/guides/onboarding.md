# Onboarding UI Components

Generic, reusable SwiftUI components extracted from multi-step onboarding flows. All components live under `Sources/SwapFoundationKit/UI/Onboarding/` and are designed to be app-agnostic so any host app can assemble a consistent onboarding experience.

---

## Component Index

| Component | File | Purpose |
|-----------|------|---------|
| `SFKChip` | `UI/Chips/SFKChip.swift` | Primary or secondary capsule-shaped action |
| `SFKChipFlowLayout` | `SFKChipFlowLayout.swift` | Flex-wrap `Layout` for chips/tags |
| `SFKSegmentedProgress` | `SFKSegmentedProgress.swift` | Story-style segmented progress bar |
| `SFKSelectableChip` | `SFKSelectableChip.swift` | Selectable capsule button with icon support |
| `SFKButton` | `Buttons/SFKButton.swift` | Semantic primary, secondary, borderless, and destructive actions |
| `AppFooterView` | `AppFooterView.swift` | Safe-area-aware footer for caller-supplied actions |
| `SFKTypography` | `SFKTypography.swift` | Six View-extension typography modifiers |
| `SFKCard` | `SFKCard.swift` | Rounded-rectangle card container with optional icon |

Full-screen flow layout (one column, two panes on iPad and iPhone Duo, fold-aware
centred column) lives in the opt-in `SwapFoundationKitOnboarding` product; see
[SwapFoundationKitOnboarding product](#swapfoundationkitonboarding-product).

---

## SFKChipFlowLayout

A custom `Layout` that places subviews left-to-right and wraps to the next line when the row exceeds the available width. Equivalent to a CSS flex-wrap container.

### Usage

```swift
import SwapFoundationKit

SFKChipFlowLayout(spacing: 8) {
    ForEach(items, id: \.self) { item in
        Text(item)
            .padding(12)
            .background(Capsule().fill(Color.blue.opacity(0.2)))
    }
}
```

### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `spacing` | `CGFloat` | `8` | Gap between items both horizontally and vertically |

### Notes

- Items are measured with `.unspecified` proposals, so they size to their intrinsic content.
- The layout does not cache; it is fast enough for typical chip counts (< 50 items).
- Works inside `ScrollView` — the layout reports its full intrinsic height.

---

## SFKSegmentedProgress

A compact segmented step indicator for guided flows. It uses a compact 128-point footprint, thin capsule segments, an expanded current segment, the environment accent color, and a critically damped spring when the active step changes.

### Usage

```swift
import SwapFoundationKit

@State private var step = 0
let totalSteps = 5

SFKSegmentedProgress(currentStep: step, totalSteps: totalSteps)
```

### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `currentStep` | `Int` | — | Index of the current step (0-based) |
| `totalSteps` | `Int` | — | Total number of steps |
| `activeColor` | `Color` | `.accentColor` | Color for completed/active segments |
| `inactiveColor` | `Color` | `.secondary.opacity(0.18)` | Color for remaining segments |
| `height` | `CGFloat` | `4` | Height of each segment capsule |
| `spacing` | `CGFloat` | `5` | Gap between segments |
| `currentSegmentWidthMultiplier` | `CGFloat` | `1.75` | Current segment width relative to every other segment |
| `width` | `CGFloat?` | `128` | Total indicator width; pass `nil` to fill the proposal |

### Animation

Transitions use a critically damped spring and fall back to a short ease-out animation when Reduce Motion is enabled. The component exposes its current and total step count through accessibility.

---

## SFKSelectableChip

A selectable chip/capsule button that toggles between selected and unselected states with distinct visual styling and the shared theme feedback policy.

### Usage

```swift
import SwapFoundationKit

// Text-only
SFKSelectableChip("Swift", isSelected: true, tintColor: .blue) {
    toggleSelection()
}

// With icon (SF Symbol or emoji)
SFKSelectableChip("Swift", icon: "swift", isSelected: false) {
    selectLanguage()
}

// From app model data
SFKSelectableChip(
    goal.title,
    icon: goal.icon,
    isSelected: state.goals.contains(goal)
) {
    state.toggleGoal(goal)
}
```

### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `icon` | `String?` | `nil` | Optional SF Symbol name or emoji displayed before the label |
| `text` / `title` | `String` | — | The label text |
| `isSelected` | `Bool` | — | Whether the chip is in the selected state |
| `tintColor` | `Color` | `.primary` | Accent color for the selected state (fill + stroke) |
| `iconTint` | `Color?` | `nil` | Optional icon color override. Falls back to the chip's built-in tint logic when omitted |
| `action` | `() -> Void` | — | Closure executed on tap |

### Visual States

| State | Fill | Stroke | Text Color |
|-------|------|--------|------------|
| Unselected | `secondarySystemBackground` | `gray.opacity(0.45)` | `.primary` |
| Selected | `tintColor` | `tintColor` | `systemBackground` (white/black) |

### Feedback policy

Buttons and chips read one policy from the nearest theme. Hosts can disable
feedback or choose an impact style once at the app boundary:

```swift
ContentView()
    .sfkTheme(SFKTheme(feedback: .init(enabled: true, style: .light)))
```

---

## Secondary onboarding actions

Use the shared semantic button instead of introducing a separate onboarding-only button type.

### Usage

```swift
import SwapFoundationKit

SFKButton("Skip for now", role: .secondary) {
    skipOnboarding()
}

SFKButton("Not now", role: .destructive) {
    dismiss()
}
```

### Configuration

Use `.secondary` for a supporting action with visible chrome and `.borderless` for
a text or icon control with no fill. Add `.sfkIcon`, `.sfkSubtitle`, `.sfkLoading`,
`.sfkFullWidth`, `.sfkTint`, or `.sfkControlSize` only when the screen needs
that focused variation. Button feedback comes from the nearest
`SFKTheme.Feedback` policy.

---

## SFKTypography

Six `View` extension modifiers that provide a consistent typography scale using the `.rounded` font design for a friendly aesthetic.

### Modifiers

| Modifier | Font Size | Weight | Color | Use Case |
|----------|-----------|--------|-------|----------|
| `sfkFlowTitleStyle()` | `.title` | `.bold` | `.primary` | Screen headers, welcome titles |
| `sfkFlowQuestionStyle()` | `.title2` | `.bold` | `.primary` | Question prompts in multi-step flows |
| `sfkFlowSubtitleStyle()` | `.body` | `.medium` | `.secondary` | Descriptive text below titles |
| `sfkFlowCardTitleStyle()` | `.headline` | `.semibold` | `.primary` | Titles inside cards or sections |
| `sfkFlowCardBodyStyle()` | `.subheadline` | regular | `.secondary` | Card body text, descriptions |
| `sfkFlowChipStyle()` | `.subheadline` | `.semibold` | `.primary` | Text inside selectable chips and tags |

### Usage

```swift
import SwapFoundationKit

Text("Welcome to the App")
    .sfkFlowTitleStyle()

Text("What brings you here?")
    .sfkFlowQuestionStyle()

Text("This helps us personalize your experience")
    .sfkFlowSubtitleStyle()

Text("Feature Name")
    .sfkFlowCardTitleStyle()

Text("Supporting description text goes here")
    .sfkFlowCardBodyStyle()

Text("Chip Label")
    .sfkFlowChipStyle()
```

### Notes

- All modifiers use `.system(_:design: .rounded)` for a consistent rounded aesthetic.
- `sfkFlowTitleStyle()` and `sfkFlowQuestionStyle()` include `.minimumScaleFactor(0.8)` to prevent truncation on smaller devices.

---

## SFKCard

A generic rounded-rectangle card container with configurable background, corner radius, padding, and an optional leading icon.

### Usage

```swift
import SwapFoundationKit

// Simple card
SFKCard {
    VStack(alignment: .leading, spacing: 8) {
        Text("Card Title")
            .sfkFlowCardTitleStyle()
        Text("Card body text goes here")
            .sfkFlowCardBodyStyle()
    }
}

// Card with leading icon
SFKCard(icon: "star.fill", iconTint: .yellow) {
    Text("Featured content")
}

// Custom styling
SFKCard(
    cornerRadius: 16,
    backgroundFill: Color.blue.opacity(0.08),
    icon: "info.circle.fill",
    iconTint: .blue,
    padding: 20,
    alignment: .center
) {
    Text("Custom styled card")
}
```

### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `cornerRadius` | `CGFloat` | `12` | Corner radius of the card |
| `backgroundFill` | `Color` | `.secondarySystemBackground` | Background fill color |
| `icon` | `String?` | `nil` | Optional leading icon SF Symbol name |
| `iconTint` | `Color` | `.orange` | Tint color for the icon and its background pill |
| `padding` | `CGFloat` | `16` | Content padding inside the card |
| `alignment` | `Alignment` | `.leading` | Content alignment within the card |
| `content` | `() -> Content` | — | The card content |

### Icon Container

When an `icon` is provided, it renders inside a `28x28` rounded rectangle (`cornerRadius: 6`) with a fill of `iconTint.opacity(0.14)`, matching the icon container pattern used elsewhere in SwapFoundationKit.

---

## Building a Multi-Step Onboarding Flow

Here is how the components compose together to build a complete onboarding experience:

```swift
import SwiftUI
import SwapFoundationKit

struct MyOnboardingView: View {
    @State private var currentStep = 0
    @State private var selectedGoals: Set<String> = []
    let totalSteps = 4

    var body: some View {
        VStack(spacing: 0) {
            // Step indicator + progress bar
            VStack(alignment: .leading, spacing: 10) {
                Text("Step \(currentStep + 1) of \(totalSteps)")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.secondary)

                SFKSegmentedProgress(
                    currentStep: currentStep,
                    totalSteps: totalSteps
                )
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)

            // Screen content
            stepContent
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Shared CTA section
            ctaSection
        }
    }

    @ViewBuilder
    private var stepContent: some View {
        switch currentStep {
        case 0: welcomeStep
        case 1: goalsStep
        case 2: summaryStep
        default: completionStep
        }
    }

    // MARK: - Steps

    private var welcomeStep: some View {
        VStack(spacing: 18) {
            Image(systemName: "star.circle.fill")
                .font(.system(size: 76))
                .foregroundStyle(.primary)

            Text("Welcome to the App")
                .sfkFlowTitleStyle()
                .multilineTextAlignment(.center)

            Text("Let's personalize your experience")
                .sfkFlowSubtitleStyle()
                .multilineTextAlignment(.center)
        }
    }

    private var goalsStep: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("What are your goals?")
                .sfkFlowQuestionStyle()

            Text("Select all that apply")
                .sfkFlowSubtitleStyle()

            SFKChipFlowLayout(spacing: 8) {
                ForEach(["Save money", "Track spending", "Stay organized", "Cut waste"], id: \.self) { goal in
                    SFKSelectableChip(
                        goal,
                        isSelected: selectedGoals.contains(goal),
                        tintColor: .blue
                    ) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            if selectedGoals.contains(goal) {
                                selectedGoals.remove(goal)
                            } else {
                                selectedGoals.insert(goal)
                            }
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 24)
    }

    private var summaryStep: some View {
        ScrollView {
            VStack(spacing: 14) {
                Text("Your personalized plan")
                    .sfkFlowQuestionStyle()

                ForEach(Array(selectedGoals).prefix(3), id: \.self) { goal in
                    SFKCard(icon: "checkmark.circle.fill", iconTint: .green) {
                        Text(goal).sfkFlowCardTitleStyle()
                    }
                }
            }
            .padding(.horizontal, 24)
        }
    }

    private var completionStep: some View {
        VStack(spacing: 24) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(.primary)

            Text("You're all set!")
                .sfkFlowTitleStyle()

            Text("Your dashboard is ready")
                .sfkFlowSubtitleStyle()
        }
    }

    // MARK: - CTA

    @ViewBuilder
    private var ctaSection: some View {
        VStack(spacing: 12) {
            SFKButton(
                currentStep == totalSteps - 1 ? "Get Started" : "Continue",
                role: .primary
            ) {
                withAnimation {
                    currentStep = min(currentStep + 1, totalSteps - 1)
                }
            }

            if currentStep > 0 {
                SFKButton("Skip", role: .borderless) {
                    currentStep = totalSteps - 1
                }
                .sfkFullWidth(false)
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .background(.ultraThinMaterial)
    }
}
```

---

## SwapFoundationKitOnboarding product

An opt-in library product with the layout rules and containers for full-screen
onboarding and wizard flows that hold their shape on iPhone, iPad and iPhone Duo
(closed and open). Goaley's onboarding and goal-entry wizard are the reference.
Add the `SwapFoundationKitOnboarding` product and import it next to SwapFoundationKit:

```swift
import SwapFoundationKit
import SwapFoundationKitOnboarding
```

The product is layered. Layer 1 is layout rules (no views of their own), layer 2 is
the step and flow containers built on them. A later layer will add an enum of screen
kinds with a `.custom` escape hatch; host apps keep the state machine, persistence,
analytics and purchase logic either way.

### Layer 1: layout rules

| API | Purpose |
|-----|---------|
| `SFKWindowPaneLayout` | `.single` or `.twoPane`. Two panes need regular width **and** a window (safe area insets included) of at least `2 × minimumPaneWidth` (880 pt). Never a device check. |
| `SFKTwoPaneSplit` | Pane widths inside the safe area, split on the **window's** centre line (the fold), with a 24 pt `gutter`, a 480 pt `maximumContentWidth` per pane and a 20 pt `contentInset`. `resolve(sizeClass:size:safeAreaInsets:)` returns `nil` for one column. |
| `SFKOnboardingWideWindowMode` | `.twoPane` (default) or `.centredColumn(maxWidth: 560)`. |
| `SFKOnboardingLayout` | `contentWidth` (640 pt single-column cap) and the welcome icon-stage widths. |
| `\.twoPaneSplit` | Published by the flow root while two panes show; a pane resets it to `nil` for its own content. |
| `\.isOnboardingPaneColumn` | `true` for a single column living in a trailing pane (a form beside a live preview), so it and its footer use the pane's inset and cap. |
| `\.onboardingWideWindowMode` | The enclosing window's mode. |
| `\.onboardingBrandMark`, `.sfkOnboardingBrandMark { … }` | What a hero-less step shows in the leading pane. |
| `SFKVerticalBarProbe` (iOS 27.1) | Reports when bar items run down iPhone Duo's side bar, so a screen can move progress or a back button into it. |
| `SFKFoldRegionLayout`, `SFKFoldPose`, `SFKFoldColumnPlacement`, `.sfkFoldAwareColumn(maxWidth:)` | Fold math and the readable column that steps off an active fold (book: trailing half; tabletop: bottom half). Powers `.centredColumn`. |
| `SFKOrientationPolicy.keepOrientationCurrent(in:)` | Re-asks for supported orientations on every size-class change, so a flow opened landscape on the Duo's inner display comes back portrait on the outer one. Call it from the scene delegate. |

### Layer 2: containers

| API | Purpose |
|-----|---------|
| `SFKOnboardingWindow(mode:content:)` | The flow root. Measures the window on every size change, resolves the split for `mode`, publishes it, and hands the content an `SFKOnboardingWindowContext` (`split`, `size`, `safeAreaInsets`). |
| `SFKOnboardingStep(eyebrow:title:subtitle:heroToHeadlineSpacing:hero:content:)` | One step. One column: hero above headline and content, the hero shrinking (to 60%) on short displays. Two panes: hero leading, copy and controls trailing; no hero shows the brand mark. Centred column: the one-column layout in a fold-aware column. |
| `SFKOnboardingStepHeadline` | Eyebrow (theme accent), title, subtitle. |
| `SFKOnboardingFooterContainer` | Puts any actions on `AppFooterView`, aligned with the step: centred and capped in one column, over the trailing pane in two, inside the fold-aware column in `.centredColumn`. |
| `SFKOnboardingFooter` | Primary button plus an optional back/secondary action (text or glass circle) that slides in and out. |
| `SFKOnboardingPrimaryButton` | Full-width `SFKButton` with enabled, loading and loading-label states. |
| `SFKOnboardingBrandMark` | A mark (any view, or `image:` drawn as a rounded icon) with a tinted shadow and an accent glow. |
| `SFKOnboardingSelectionCard` | Selectable option row with an icon tile (emoji or any view), title, subtitle and check. |
| `SFKOnboardingSelectionStatus` | "SELECT ALL THAT APPLY / SELECT ONE" and the selection count or "REQUIRED / OPTIONAL". Labels resolve in the host's string catalogue. |
| `SFKOnboardingPressableRowButtonStyle` | The press-in style the cards use. |

Colours come from `SFKTheme` (`accent`, `text`, `secondaryText`, `surface`); per-option
tints are passed in. No copy, colour or model of any app lives in the product.

### Two-pane flow (default)

```swift
struct OnboardingContainerView: View {
    @StateObject var state: OnboardingState

    var body: some View {
        SFKOnboardingWindow { window in
            VStack(spacing: 0) {
                SFKSegmentedProgress(currentStep: state.index, totalSteps: state.count, width: 128)
                    // Status bar on the side (Duo open) leaves no top inset.
                    .padding(.top, window.safeAreaInsets.top > 0 ? 14 : 24)
                    // Over the trailing pane in two panes, centred in one.
                    .frame(width: window.split?.trailingWidth)
                    .frame(maxWidth: .infinity, alignment: window.split == nil ? .center : .trailing)

                stepView(for: state.step)
                    .id(state.step)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                SFKOnboardingFooter(primaryTitle: "Continue", isPrimaryEnabled: state.canAdvance) {
                    state.advance()
                }
            }
        }
        .sfkOnboardingBrandMark {
            SFKOnboardingBrandMark(image: Image("BrandIcon"))
        }
    }
}

struct GoalQuestionStep: View {
    @ObservedObject var state: OnboardingState

    var body: some View {
        SFKOnboardingStep(
            eyebrow: "YOUR GOAL",
            title: "What are you saving for?",
            subtitle: "Pick everything that applies."
        ) {
            EmptyView()                                  // brand mark fills the leading pane
        } content: {
            SFKOnboardingSelectionStatus(selectionCount: state.selection.count, isRequired: true)
            ForEach(GoalKind.allCases) { kind in
                SFKOnboardingSelectionCard(
                    emoji: kind.emoji,
                    title: kind.title,
                    tint: kind.color,
                    isSelected: state.selection.contains(kind)
                ) { state.toggle(kind) }
            }
        }
    }
}
```

A wizard whose form sits beside a live preview splits by hand and marks the trailing
column as a pane column:

```swift
SFKOnboardingWindow { window in
    if let split = window.split {
        HStack(spacing: SFKTwoPaneSplit.gutter) {
            DraftPreview().frame(width: split.leadingWidth)
            stepColumn
                .frame(width: split.trailingWidth)
                .environment(\.twoPaneSplit, nil)
                .environment(\.isOnboardingPaneColumn, true)
        }
    } else {
        stepColumn
    }
}
```

On iPhone Duo, put an `SFKVerticalBarProbe` in the background and, while it reports a
vertical bar, move the step progress and the back button into toolbar items instead
of the footer (see Goaley's `GoalEntryStepView`).

### Centred-column flow

Apps whose compositions should stay one readable column on wide windows (Windfall)
pass `.centredColumn`:

```swift
SFKOnboardingWindow(mode: .centredColumn(maxWidth: 560)) { _ in
    currentStep
        .safeAreaInset(edge: .bottom, spacing: 0) {
            SFKOnboardingFooter(primaryTitle: "Continue", primaryAction: advance)
        }
}
```

No split is resolved. Every `SFKOnboardingStep` and footer caps itself at `maxWidth`
in regular width and, while a fold divides the window, moves into the trailing half
(book) or the bottom half (tabletop). The footer's surface still spans the window.
Compact width is unchanged. Custom screens get the same behaviour with
`.sfkFoldAwareColumn(maxWidth:)`; apply it outside any `GeometryReader` that derives
positions from width.

### Checklist

- [ ] The flow root is an `SFKOnboardingWindow` (or resolves `SFKTwoPaneSplit` itself and sets `\.twoPaneSplit`).
- [ ] Every step is an `SFKOnboardingStep` or reads `\.twoPaneSplit` and splits itself.
- [ ] Hero-less steps have a brand mark via `.sfkOnboardingBrandMark`.
- [ ] Footers use `SFKOnboardingFooter` / `SFKOnboardingFooterContainer`, never a bare button row.
- [ ] Progress sits over the trailing pane in two panes and in the side bar on iPhone Duo.
- [ ] The scene delegate calls `SFKOrientationPolicy.keepOrientationCurrent(in:)`.
- [ ] Verified on iPhone, iPad landscape, Duo closed and Duo open.

---

## Migration from App-Local Components

If your app already has local onboarding components, replace them with the SFK equivalents:

| Your Local Component | SFK Replacement |
|---------------------|-----------------|
| `OnboardingChipFlowLayout` | `SFKChipFlowLayout` |
| `OnboardingProgressBar` | `SFKSegmentedProgress` |
| `GoalSelectionCard` / `SelectableChip` | `SFKSelectableChip` |
| `OnboardingSecondaryButton` | `SFKButton(_:role: .secondary)` |
| `onboardingTitleStyle()` | `sfkFlowTitleStyle()` |
| `onboardingSubtitleStyle()` | `sfkFlowSubtitleStyle()` |
| `onboardingQuestionTitleStyle()` | `sfkFlowQuestionStyle()` |
| `onboardingCardTitleStyle()` | `sfkFlowCardTitleStyle()` |
| `onboardingCardBodyStyle()` | `sfkFlowCardBodyStyle()` |
| `onboardingChipTitleStyle()` | `sfkFlowChipStyle()` |
| Custom card container | `SFKCard` |
| `OnboardingScrollableStep` | `SFKOnboardingStep` (SwapFoundationKitOnboarding) |
| `OnboardingFooterView` / `OnboardingFooterContainer` | `SFKOnboardingFooter` / `SFKOnboardingFooterContainer` |
| `TwoPaneSplit` / `WindowPaneLayout` | `SFKTwoPaneSplit` / `SFKWindowPaneLayout` |
| `OnboardingReadableColumn` / `foldAwareColumn(maxWidth:)` | `SFKOnboardingWindow(mode: .centredColumn())` / `sfkFoldAwareColumn(maxWidth:)` |

### Migration Steps

1. Add `import SwapFoundationKit` to each onboarding screen file.
2. Replace typography modifiers (`onboarding*Style()` → `sfkFlow*Style()`).
3. Replace `OnboardingProgressBar` with `SFKSegmentedProgress`.
4. Replace `OnboardingChipFlowLayout` with `SFKChipFlowLayout`.
5. Replace chip/selection cards with `SFKSelectableChip`.
6. Pass model labels/icons directly to `SFKSelectableChip(_:icon:isSelected:...)`.
7. Replace secondary buttons with `SFKButton(_:role: .secondary)`.
8. Delete the old local component files.
9. Build and verify all screens render correctly.

---

## Design Principles

1. **App-agnostic** — No references to specific app names, colors, or domain logic.
2. **Configurable by default** — Every component exposes sensible defaults with override points.
3. **System-color aware** — Uses `secondarySystemBackground`, `systemBackground`, `.primary`, `.secondary` so components adapt to light/dark mode automatically.
4. **Haptic feedback** — Interactive components follow one configurable `SFKTheme.Feedback` policy.
5. **Accessibility** — Typography modifiers include `.minimumScaleFactor` where appropriate; all components use standard SwiftUI button semantics.
6. **Preview-rich** — Every component includes `#Preview` blocks with multiple variants for rapid iteration in the SwapFoundationKitHost app.
