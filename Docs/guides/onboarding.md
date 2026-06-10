# Onboarding UI Components

Generic, reusable SwiftUI components extracted from multi-step onboarding flows. All components live under `Sources/SwapFoundationKit/UI/Onboarding/` and are designed to be app-agnostic so any host app can assemble a consistent onboarding experience.

---

## Component Index

| Component | File | Purpose |
|-----------|------|---------|
| `SFKChipFlowLayout` | `SFKChipFlowLayout.swift` | Flex-wrap `Layout` for chips/tags |
| `SFKSegmentedProgress` | `SFKSegmentedProgress.swift` | Story-style segmented progress bar |
| `SFKSelectableChip` | `SFKSelectableChip.swift` | Selectable capsule button with icon support |
| `SFKChipItem` | `SFKSelectableChip.swift` | Protocol for model types used with chips |
| `SFKSecondaryButton` | `SFKSecondaryButton.swift` | Text-only button for skip/dismiss actions |
| `SFKTypography` | `SFKTypography.swift` | Six View-extension typography modifiers |
| `SFKCard` | `SFKCard.swift` | Rounded-rectangle card container with optional icon |

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

A segmented progress indicator similar to iOS story indicators. Renders capsule-shaped segments where completed steps are filled and remaining steps are dimmed.

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
| `activeColor` | `Color` | `.primary` | Color for completed/active segments |
| `inactiveColor` | `Color` | `.gray.opacity(0.25)` | Color for remaining segments |
| `height` | `CGFloat` | `6` | Height of each segment capsule |
| `spacing` | `CGFloat` | `6` | Gap between segments |

### Animation

Transitions between steps animate with `.easeInOut(duration: 0.2)` driven by the `currentStep` value.

---

## SFKSelectableChip

A selectable chip/capsule button that toggles between selected and unselected states with distinct visual styling and built-in haptic feedback.

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

// From a conforming model type
SFKSelectableChip(item: goal, isSelected: state.goals.contains(goal)) {
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

### Haptics

Tapping triggers a `UIImpactFeedbackGenerator(style: .light)` impact.

---

## SFKChipItem Protocol

A lightweight protocol that lets your model types plug directly into `SFKSelectableChip`.

### Conformance

```swift
import SwapFoundationKit

enum Goal: String, CaseIterable, SFKChipItem {
    case trackSpending = "Track my spending"
    case saveMoney = "Save money"

    var chipLabel: String { rawValue }
    var chipIcon: String? { nil } // optional emoji or SF Symbol
}
```

### Required Properties

| Property | Type | Description |
|----------|------|-------------|
| `chipLabel` | `String` | Text displayed on the chip |
| `chipIcon` | `String?` | Optional icon (SF Symbol name or emoji). Default: `nil` |

---

## SFKSecondaryButton

A text-only button styled for secondary actions like "Skip", "Not now", or "Dismiss".

### Usage

```swift
import SwapFoundationKit

SFKSecondaryButton("Skip for now") {
    skipOnboarding()
}

SFKSecondaryButton("Not now", color: .red) {
    dismiss()
}

SFKSecondaryButton("Maybe later", font: .footnote) {
    dismiss()
}
```

### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `title` | `String` | — | Button label text |
| `color` | `Color` | `.secondary` | Text color |
| `font` | `Font` | `.subheadline` | Label font |
| `action` | `() -> Void` | — | Closure executed on tap |

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
                color: .blue,
                chrome: .glassProminent
            ) {
                withAnimation {
                    currentStep = min(currentStep + 1, totalSteps - 1)
                }
            }

            if currentStep > 0 {
                SFKSecondaryButton("Skip") {
                    currentStep = totalSteps - 1
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .background(.ultraThinMaterial)
    }
}
```

---

## Migration from App-Local Components

If your app already has local onboarding components, replace them with the SFK equivalents:

| Your Local Component | SFK Replacement |
|---------------------|-----------------|
| `OnboardingChipFlowLayout` | `SFKChipFlowLayout` |
| `OnboardingProgressBar` | `SFKSegmentedProgress` |
| `GoalSelectionCard` / `SelectableChip` | `SFKSelectableChip` |
| `OnboardingSecondaryButton` | `SFKSecondaryButton` |
| `onboardingTitleStyle()` | `sfkFlowTitleStyle()` |
| `onboardingSubtitleStyle()` | `sfkFlowSubtitleStyle()` |
| `onboardingQuestionTitleStyle()` | `sfkFlowQuestionStyle()` |
| `onboardingCardTitleStyle()` | `sfkFlowCardTitleStyle()` |
| `onboardingCardBodyStyle()` | `sfkFlowCardBodyStyle()` |
| `onboardingChipTitleStyle()` | `sfkFlowChipStyle()` |
| Custom card container | `SFKCard` |

### Migration Steps

1. Add `import SwapFoundationKit` to each onboarding screen file.
2. Replace typography modifiers (`onboarding*Style()` → `sfkFlow*Style()`).
3. Replace `OnboardingProgressBar` with `SFKSegmentedProgress`.
4. Replace `OnboardingChipFlowLayout` with `SFKChipFlowLayout`.
5. Replace chip/selection cards with `SFKSelectableChip`.
6. Make your model types conform to `SFKChipItem` instead of using app-specific chip protocols.
7. Replace secondary buttons with `SFKSecondaryButton`.
8. Delete the old local component files.
9. Build and verify all screens render correctly.

---

## Design Principles

1. **App-agnostic** — No references to specific app names, colors, or domain logic.
2. **Configurable by default** — Every component exposes sensible defaults with override points.
3. **System-color aware** — Uses `secondarySystemBackground`, `systemBackground`, `.primary`, `.secondary` so components adapt to light/dark mode automatically.
4. **Haptic feedback** — Interactive components include subtle haptics out of the box.
5. **Accessibility** — Typography modifiers include `.minimumScaleFactor` where appropriate; all components use standard SwiftUI button semantics.
6. **Preview-rich** — Every component includes `#Preview` blocks with multiple variants for rapid iteration in the SwapFoundationKitHost app.
