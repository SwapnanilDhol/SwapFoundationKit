# Chip Components

SwapFoundationKit distinguishes action chips from selectable chips so host apps can express behavior with the correct component vocabulary.

## Component index

| Component | Purpose |
|-----------|---------|
| `SFKChip` | Performs a compact action using primary or secondary hierarchy |
| `SFKChipStyle` | Selects `.primary` or `.secondary` action emphasis |
| `SFKSelectableChip` | Represents state that can be selected or deselected |
| `SFKChipFlowLayout` | Wraps either chip type across rows |
| `SFKChipItem` | Adapts model values for `SFKSelectableChip` |

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

Use `.primary` for the preferred action in a chip group and `.secondary` for supporting actions. Use `SFKButton` for full-size CTAs and toolbar controls.

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
