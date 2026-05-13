import SwiftUI

public struct SFKSettingsTheme {
    public struct Colors {
        public enum ItemTintBehavior {
            case preserveItemTint
            case useAccent
        }

        public var accent: Color
        public var itemTintBehavior: ItemTintBehavior
        public var toggleOnTint: Color?
        public var sliderTint: Color?
        public var titleColor: Color
        public var subtitleColor: Color
        public var valueColor: Color
        public var accessoryColor: Color
        public var destructiveTint: Color
        public var iconBackgroundOpacity: Double
        public var swatchBorderColor: Color

        public init(
            accent: Color = .blue,
            itemTintBehavior: ItemTintBehavior = .preserveItemTint,
            toggleOnTint: Color? = nil,
            sliderTint: Color? = nil,
            titleColor: Color = .primary,
            subtitleColor: Color = .secondary,
            valueColor: Color = .secondary,
            accessoryColor: Color = .secondary,
            destructiveTint: Color = .red,
            iconBackgroundOpacity: Double = 0.14,
            swatchBorderColor: Color = Color.primary.opacity(0.2)
        ) {
            self.accent = accent
            self.itemTintBehavior = itemTintBehavior
            self.toggleOnTint = toggleOnTint
            self.sliderTint = sliderTint
            self.titleColor = titleColor
            self.subtitleColor = subtitleColor
            self.valueColor = valueColor
            self.accessoryColor = accessoryColor
            self.destructiveTint = destructiveTint
            self.iconBackgroundOpacity = iconBackgroundOpacity
            self.swatchBorderColor = swatchBorderColor
        }
    }

    public struct Typography {
        public var iconFont: Font
        public var titleFont: Font
        public var subtitleFont: Font
        public var valueFont: Font
        public var accessoryFont: Font

        public init(
            iconFont: Font = .subheadline.weight(.semibold),
            titleFont: Font = .body.weight(.semibold),
            subtitleFont: Font = .body,
            valueFont: Font = .subheadline,
            accessoryFont: Font = .caption
        ) {
            self.iconFont = iconFont
            self.titleFont = titleFont
            self.subtitleFont = subtitleFont
            self.valueFont = valueFont
            self.accessoryFont = accessoryFont
        }
    }

    public struct Metrics {
        public var iconTileSize: CGFloat
        public var iconCornerRadius: CGFloat
        public var rowSpacing: CGFloat
        public var labelSpacing: CGFloat
        public var trailingSpacing: CGFloat
        public var rowVerticalPadding: CGFloat
        public var colorSwatchSize: CGFloat

        public init(
            iconTileSize: CGFloat = 32,
            iconCornerRadius: CGFloat = 6,
            rowSpacing: CGFloat = 12,
            labelSpacing: CGFloat = 2,
            trailingSpacing: CGFloat = 8,
            rowVerticalPadding: CGFloat = 6,
            colorSwatchSize: CGFloat = 24
        ) {
            self.iconTileSize = iconTileSize
            self.iconCornerRadius = iconCornerRadius
            self.rowSpacing = rowSpacing
            self.labelSpacing = labelSpacing
            self.trailingSpacing = trailingSpacing
            self.rowVerticalPadding = rowVerticalPadding
            self.colorSwatchSize = colorSwatchSize
        }
    }

    public var colors: Colors
    public var typography: Typography
    public var metrics: Metrics

    public init(
        colors: Colors = Colors(),
        typography: Typography = Typography(),
        metrics: Metrics = Metrics()
    ) {
        self.colors = colors
        self.typography = typography
        self.metrics = metrics
    }
}

private struct SFKSettingsThemeKey: EnvironmentKey {
    static let defaultValue = SFKSettingsTheme()
}

public extension EnvironmentValues {
    var sfkSettingsTheme: SFKSettingsTheme {
        get { self[SFKSettingsThemeKey.self] }
        set { self[SFKSettingsThemeKey.self] = newValue }
    }
}

public extension View {
    func sfkSettingsTheme(_ theme: SFKSettingsTheme) -> some View {
        environment(\.sfkSettingsTheme, theme)
    }
}

extension SFKSettingsTheme {
    func resolvedItemTint(_ itemTint: Color) -> Color {
        switch colors.itemTintBehavior {
        case .preserveItemTint:
            return itemTint
        case .useAccent:
            return colors.accent
        }
    }

    func resolvedTint(_ explicitTint: Color?) -> Color {
        explicitTint ?? colors.accent
    }

    func resolvedToggleTint(_ explicitTint: Color?) -> Color {
        explicitTint ?? colors.toggleOnTint ?? colors.accent
    }

    func resolvedSliderTint(_ explicitTint: Color?) -> Color {
        explicitTint ?? colors.sliderTint ?? colors.accent
    }
}
