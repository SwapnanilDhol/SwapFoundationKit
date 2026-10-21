# Chip Components

SwapFoundationKit distinguishes action chips from selectable chips so host apps can express behavior with the correct component vocabulary.

## Component index

| Component | Purpose |
|-----------|---------|
| `SFKChip` | Performs a compact action using primary or secondary hierarchy |
| `SFKMenuChip` | Presents a native menu from a chip-styled label |
| `SFKChipStyle` | Selects `.primary` or `.secondary` action emphasis |
| `SFKBadge` | Labels a status the person reads but does not tap |
| `SFKSelectableChip` | Represents state that can be selected or deselected |
| `SFKChipFlowLayout` | Wraps either chip type across rows |
| `SFKChipItem` | Adapts model values for `SFKSelectableChip` |

## Badges

Use `SFKBadge` for a status label: "PRO", "TODAY", "2 DAYS LATE", "PAUSED". It has no button trait, haptics, or glass, so VoiceOver reads it as text. Use `SFKChip` when tapping does something.

```swift
SFKBadge("TODAY", tintColor: .green)
SFKBadge("2 DAYS LATE", tintColor: .orange)
SFKBadge("PAUSED")                                   // neutral
SFKBadge("PRO", leadingIconName: "sparkles", tintColor: .green, controlSize: .regular)
```

A tinted badge draws the tint as text over a 15% fill of the same color. Padding comes from the theme's spacing tokens, so rows and headers stay consistent.

## Action chips

Use `SFKChip` when tapping opens an editor, applies a filter, or performs another immediate action.

```swift
SFKChipFlowLayout(spacing: 8) {
    SFKChip(
        "Category",
        leadingIconName: "tag",
        controlSize: .small,
        style: .secondary
    ) {
        presentCategoryEditor()
    }
}
```

Use `.primary` for the preferred action in a chip group and `.secondary` for supporting actions. Use `SFKButton` for full-size CTAs and borderless text actions.

Use `SFKMenuChip` when the compact action opens a native menu. This keeps the
menu as the owning control instead of nesting an `SFKChip` button inside it.

```swift
SFKMenuChip("Reading", leadingIconName: "book", style: .primary) {
    Button("Want to Read") { updateStatus(.wantToRead) }
    Button("Finished") { updateStatus(.finished) }
}
```

## Selectable chips

Use `SFKSelectableChip` only when the chip represents selected state.

```swift
SFKSelectableChip(
    item: category,
    isSelected: selectedCategories.contains(category),
    tintColor: .blue,
    controlSize: .small
) {
    toggle(category)
}
```

Both chip types use Dynamic Type fonts, the same compact sizing metrics, capsule glass, and `SFKChipFlowLayout`.
