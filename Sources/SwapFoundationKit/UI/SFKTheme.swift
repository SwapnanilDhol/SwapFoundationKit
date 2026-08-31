import SwiftUI

/// Shared semantic design tokens for SwapFoundationKit controls.
///
/// Use ``SFKTheme.system`` for the platform appearance, then override only the
/// values owned by the host app. Controls resolve these values at render time,
/// so a theme supplied higher in the view hierarchy applies consistently.
public struct SFKTheme {
    public struct Colors {
        public var accent: Color
        public var text: Color
        public var secondaryText: Color
        public var background: Color
        public var surface: Color
        public var border: Color
        public var destructive: Color
        public var onAccent: Color
        public var onDestructive: Color

        public init(
            accent: Color = .accentColor,
            text: Color = .primary,
            secondaryText: Color = .secondary,
            background: Color = Color(.systemBackground),
            surface: Color = Color(.secondarySystemBackground),
            border: Color = Color.primary.opacity(0.12),
            destructive: Color = .red,
            onAccent: Color = .white,
            onDestructive: Color = .white
        ) {
            self.accent = accent
            self.text = text
            self.secondaryText = secondaryText
            self.background = background
            self.surface = surface
            self.border = border
            self.destructive = destructive
            self.onAccent = onAccent
            self.onDestructive = onDestructive
        }

        public static let system = Colors()
    }

    public struct Typography {
        public var title: Font
        public var body: Font
        public var caption: Font

        public init(
            title: Font = .title3.weight(.semibold),
            body: Font = .body,
            caption: Font = .caption
        ) {
            self.title = title
            self.body = body
            self.caption = caption
        }

        public static let system = Typography()
    }

    public struct Spacing {
        public var control: CGFloat
        public var section: CGFloat
        public var inline: CGFloat

        public init(control: CGFloat = 12, section: CGFloat = 24, inline: CGFloat = 8) {
            self.control = control
            self.section = section
            self.inline = inline
        }

        public static let system = Spacing()
    }

    public struct Radii {
        public var control: CGFloat
        public var card: CGFloat

        public init(control: CGFloat = 12, card: CGFloat = 20) {
            self.control = control
            self.card = card
        }

        public static let system = Radii()
    }

    public struct Motion {
        public var standard: Animation

        public init(standard: Animation = .spring(response: 0.28, dampingFraction: 0.82)) {
            self.standard = standard
        }

        public static let system = Motion()
    }

    public struct Feedback {
        /// The shared impact style used by buttons and chips.
        public enum Style: Sendable {
            case none
            case light
            case medium
            case heavy
        }

        public var enabled: Bool
        public var style: Style

        public init(enabled: Bool = true, style: Style = .medium) {
            self.enabled = enabled
            self.style = style
        }

        public static let system = Feedback()
    }

    public var colors: Colors
    public var typography: Typography
    public var spacing: Spacing
    public var radii: Radii
    public var motion: Motion
    public var feedback: Feedback

    public init(
        colors: Colors = .system,
        typography: Typography = .system,
        spacing: Spacing = .system,
        radii: Radii = .system,
        motion: Motion = .system,
        feedback: Feedback = .system
    ) {
        self.colors = colors
        self.typography = typography
        self.spacing = spacing
        self.radii = radii
        self.motion = motion
        self.feedback = feedback
    }

    public static let system = SFKTheme()

    /// Returns a copy of this theme with a new semantic accent color.
    public func accent(_ color: Color) -> Self {
        var copy = self
        copy.colors.accent = color
        return copy
    }
}

private struct SFKThemeEnvironmentKey: EnvironmentKey {
    static let defaultValue = SFKTheme.system
}

public extension EnvironmentValues {
    /// The nearest theme supplied with ``View/sfkTheme(_:)``.
    var sfkTheme: SFKTheme {
        get { self[SFKThemeEnvironmentKey.self] }
        set { self[SFKThemeEnvironmentKey.self] = newValue }
    }
}

public extension View {
    /// Supplies semantic SFK tokens to this view and its descendants.
    func sfkTheme(_ theme: SFKTheme) -> some View {
        environment(\.sfkTheme, theme)
    }
}

#Preview("SFKTheme • Light • Large Type") {
    @Previewable @State var text = ""

    VStack(spacing: SFKTheme.system.spacing.section) {
        SFKButton("Continue", role: .primary) { }
            .sfkIcon("arrow.right")
        SFKTextField("Name", text: $text)
            .sfkInput(.standard)
    }
    .padding()
    .sfkTheme(.system.accent(.indigo))
    .preferredColorScheme(.light)
    .environment(\.sizeCategory, .accessibilityExtraExtraExtraLarge)
}

#Preview("SFKTheme • Dark • Large Type") {
    @Previewable @State var text = ""

    VStack(spacing: SFKTheme.system.spacing.section) {
        SFKButton("Continue", role: .primary) { }
            .sfkIcon("arrow.right")
        SFKTextField("Name", text: $text)
            .sfkInput(.standard)
    }
    .padding()
    .sfkTheme(.system.accent(.indigo))
    .preferredColorScheme(.dark)
    .environment(\.sizeCategory, .accessibilityExtraExtraExtraLarge)
}
