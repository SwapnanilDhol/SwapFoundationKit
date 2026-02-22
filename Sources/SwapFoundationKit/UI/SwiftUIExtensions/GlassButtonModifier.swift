import SwiftUI

// MARK: - Glass Button Modifiers

/// A modifier that applies a glass-style rounded rectangle treatment to button surfaces.
///
/// This modifier provides a modern glassmorphism effect that automatically adapts between
/// iOS 26's native `glassEffect` and a custom gradient fallback for older iOS versions.
///
/// ## Usage
/// ```swift
/// Button("Tap Me") { }
///     .glassButton(cornerRadius: 16, tint: .blue)
/// ```
///
/// - Note: On iOS 26+, uses native `glassEffect` with interactive tint. On earlier versions,
///   uses a custom gradient with shadow for visual consistency.
public struct GlassButtonModifier: ViewModifier {

    /// The corner radius for the rounded rectangle shape.
    public let cornerRadius: CGFloat

    /// The tint color applied to the glass effect and shadow.
    public let tint: Color

    /// Whether to enable the drop shadow effect.
    public let isShadowEnabled: Bool

    /// Forces the fallback gradient style, bypassing the iOS 26 glass effect.
    public let forceDisable: Bool

    /// Creates a glass button modifier with customizable appearance.
    ///
    /// - Parameters:
    ///   - cornerRadius: The corner radius of the button. Defaults to `16`.
    ///   - tint: The tint color for the glass effect. Defaults to `.blue`.
    ///   - isShadowEnabled: Whether to display the drop shadow. Defaults to `true`.
    ///   - forceDisable: Forces the use of the fallback gradient style. Defaults to `false`.
    public init(
        cornerRadius: CGFloat = 16,
        tint: Color = .blue,
        isShadowEnabled: Bool = true,
        forceDisable: Bool = false
    ) {
        self.cornerRadius = cornerRadius
        self.tint = tint
        self.isShadowEnabled = isShadowEnabled
        self.forceDisable = forceDisable
    }

    public func body(content: Content) -> some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)

        if #available(iOS 26, *), !forceDisable {
            content
                .glassEffect(.regular.tint(tint).interactive(), in: shape)
        } else {
            content
                .background(
                    shape.fill(
                        LinearGradient(
                            colors: [tint.opacity(0.35), tint.opacity(0.12)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                )
                .overlay(
                    shape.stroke(.white.opacity(0.3), lineWidth: 0.6)
                )
                .shadow(
                    color: isShadowEnabled ? tint.opacity(0.25) : .clear,
                    radius: 12,
                    x: 0,
                    y: 6
                )
        }
    }
}

/// A modifier that applies a glass-style capsule (pill) treatment to button surfaces.
///
/// Provides a rounded capsule shape with glassmorphism effect, ideal for pill-shaped action buttons.
///
/// ## Usage
/// ```swift
/// Button("Continue") { }
///     .glassCapsuleButton(tint: .green)
/// ```
public struct GlassCapsuleButtonModifier: ViewModifier {

    /// The tint color applied to the glass effect and shadow.
    public let tint: Color

    /// Whether to enable the drop shadow effect.
    public let isShadowEnabled: Bool

    /// Forces the fallback gradient style, bypassing the iOS 26 glass effect.
    public let forceDisable: Bool

    /// Creates a glass capsule button modifier.
    ///
    /// - Parameters:
    ///   - tint: The tint color for the glass effect. Defaults to `.mint`.
    ///   - isShadowEnabled: Whether to display the drop shadow. Defaults to `true`.
    ///   - forceDisable: Forces the use of the fallback gradient style. Defaults to `false`.
    public init(
        tint: Color = .mint,
        isShadowEnabled: Bool = true,
        forceDisable: Bool = false
    ) {
        self.tint = tint
        self.isShadowEnabled = isShadowEnabled
        self.forceDisable = forceDisable
    }

    public func body(content: Content) -> some View {
        if #available(iOS 26, *), !forceDisable {
            content
                .glassEffect(.regular.tint(tint).interactive(), in: Capsule())
        } else {
            content
                .background(
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [tint.opacity(0.32), tint.opacity(0.12)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                )
                .overlay(
                    Capsule()
                        .stroke(.white.opacity(0.28), lineWidth: 0.6)
                )
                .shadow(
                    color: isShadowEnabled ? tint.opacity(0.25) : .clear,
                    radius: 12,
                    x: 0,
                    y: 6
                )
        }
    }
}

/// A modifier that applies a glass-style circular treatment to button surfaces.
///
/// Provides a circular shape with glassmorphism effect, perfect for FAB-style or icon buttons.
///
/// ## Usage
/// ```swift
/// Button(action: { }) {
///     Image(systemName: "plus")
///         .font(.title2)
/// }
/// .glassCircleButton(tint: .blue)
/// ```
public struct GlassCircleButtonModifier: ViewModifier {

    /// The tint color applied to the glass effect and shadow.
    public let tint: Color

    /// Whether to enable the drop shadow effect.
    public let isShadowEnabled: Bool

    /// Forces the fallback gradient style, bypassing the iOS 26 glass effect.
    public let forceDisable: Bool

    /// Creates a glass circle button modifier.
    ///
    /// - Parameters:
    ///   - tint: The tint color for the glass effect. Defaults to `.mint`.
    ///   - isShadowEnabled: Whether to display the drop shadow. Defaults to `true`.
    ///   - forceDisable: Forces the use of the fallback gradient style. Defaults to `false`.
    public init(
        tint: Color = .mint,
        isShadowEnabled: Bool = true,
        forceDisable: Bool = false
    ) {
        self.tint = tint
        self.isShadowEnabled = isShadowEnabled
        self.forceDisable = forceDisable
    }

    public func body(content: Content) -> some View {
        if #available(iOS 26, *), !forceDisable {
            content
                .glassEffect(.regular.tint(tint).interactive(), in: Circle())
        } else {
            content
                .background(
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [tint.opacity(0.32), tint.opacity(0.12)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                )
                .overlay(
                    Circle()
                        .stroke(.white.opacity(0.28), lineWidth: 0.6)
                )
                .shadow(
                    color: isShadowEnabled ? tint.opacity(0.25) : .clear,
                    radius: 12,
                    x: 0,
                    y: 6
                )
        }
    }
}

// MARK: - View Extension

public extension View {

    /// Applies a glass-style rounded rectangle treatment suitable for buttons.
    ///
    /// - Parameters:
    ///   - cornerRadius: The corner radius of the button. Defaults to `16`.
    ///   - tint: The tint color for the glass effect. Defaults to `.blue`.
    ///   - isShadowEnabled: Whether to display the drop shadow. Defaults to `true`.
    ///   - forceDisable: Forces the use of the fallback gradient style. Defaults to `false`.
    ///
    /// - Returns: A view with the glass button modifier applied.
    func glassButton(
        cornerRadius: CGFloat = 16,
        tint: Color = .blue,
        isShadowEnabled: Bool = true,
        forceDisable: Bool = false
    ) -> some View {
        modifier(
            GlassButtonModifier(
                cornerRadius: cornerRadius,
                tint: tint,
                isShadowEnabled: isShadowEnabled,
                forceDisable: forceDisable
            )
        )
    }

    /// Applies a glass-style capsule (pill) treatment suitable for pill buttons.
    ///
    /// - Parameters:
    ///   - tint: The tint color for the glass effect. Defaults to `.mint`.
    ///   - isShadowEnabled: Whether to display the drop shadow. Defaults to `true`.
    ///   - forceDisable: Forces the use of the fallback gradient style. Defaults to `false`.
    ///
    /// - Returns: A view with the glass capsule button modifier applied.
    func glassCapsuleButton(
        tint: Color = .mint,
        isShadowEnabled: Bool = true,
        forceDisable: Bool = false
    ) -> some View {
        modifier(
            GlassCapsuleButtonModifier(
                tint: tint,
                isShadowEnabled: isShadowEnabled,
                forceDisable: forceDisable
            )
        )
    }

    /// Applies a glass-style circle treatment suitable for circular buttons.
    ///
    /// - Parameters:
    ///   - tint: The tint color for the glass effect. Defaults to `.mint`.
    ///   - isShadowEnabled: Whether to display the drop shadow. Defaults to `true`.
    ///   - forceDisable: Forces the use of the fallback gradient style. Defaults to `false`.
    ///
    /// - Returns: A view with the glass circle button modifier applied.
    func glassCircleButton(
        tint: Color = .mint,
        isShadowEnabled: Bool = true,
        forceDisable: Bool = false
    ) -> some View {
        modifier(
            GlassCircleButtonModifier(
                tint: tint,
                isShadowEnabled: isShadowEnabled,
                forceDisable: forceDisable
            )
        )
    }
}

// MARK: - Glass Effect Container

/// A container view that applies a glass-style background treatment to its content.
///
/// This container provides a glassmorphism background effect that automatically adapts
/// between iOS 26's native `glassEffect` and a custom gradient fallback for older versions.
///
/// ## Usage
/// ```swift
/// GlassEffectContainer(cornerRadius: 20, tint: .white) {
///     Text("Glass Content")
///         .padding()
/// }
/// ```
///
/// - Note: The container applies the glass effect to the background while preserving
///   the content's original appearance.
public struct GlassEffectContainer<Content: View>: View {

    /// The corner radius for the container shape.
    public let cornerRadius: CGFloat

    /// The tint color applied to the glass effect.
    public let tint: Color

    /// Whether to enable the drop shadow effect.
    public let isShadowEnabled: Bool

    /// Forces the fallback gradient style, bypassing the iOS 26 glass effect.
    public let forceDisable: Bool

    /// The content to display inside the glass container.
    public let content: Content

    /// Creates a glass effect container.
    ///
    /// - Parameters:
    ///   - cornerRadius: The corner radius of the container. Defaults to `20`.
    ///   - tint: The tint color for the glass effect. Defaults to system background.
    ///   - isShadowEnabled: Whether to display the drop shadow. Defaults to `true`.
    ///   - forceDisable: Forces the use of the fallback gradient style. Defaults to `false`.
    ///   - content: A view builder that provides the content to display inside the container.
    public init(
        cornerRadius: CGFloat = 20,
        tint: Color = Color(uiColor: .systemBackground),
        isShadowEnabled: Bool = true,
        forceDisable: Bool = false,
        @ViewBuilder content: () -> Content
    ) {
        self.cornerRadius = cornerRadius
        self.tint = tint
        self.isShadowEnabled = isShadowEnabled
        self.forceDisable = forceDisable
        self.content = content()
    }

    public var body: some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)

        if #available(iOS 26, *), !forceDisable {
            content
                .background(
                    shape
                        .fill(.regularMaterial)
                        .glassEffect(.regular.tint(tint).interactive(), in: shape)
                )
        } else {
            content
                .background(
                    shape.fill(
                        LinearGradient(
                            colors: [tint.opacity(0.85), tint.opacity(0.65)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                )
                .overlay(
                    shape.stroke(.white.opacity(0.4), lineWidth: 0.6)
                )
                .shadow(
                    color: isShadowEnabled ? .black.opacity(0.08) : .clear,
                    radius: 12,
                    x: 0,
                    y: 4
                )
        }
    }
}

// MARK: - Previews

#Preview("Glass Buttons") {
    VStack(spacing: 16) {
        Button("Add Transaction") {}
            .font(.headline)
            .foregroundStyle(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .glassButton(cornerRadius: 18, tint: .blue)

        Button("Approve") {}
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 22)
            .padding(.vertical, 10)
            .glassCapsuleButton(tint: .green)

        Button("Skip") {}
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 22)
            .padding(.vertical, 10)
            .glassCapsuleButton(tint: .orange)

        Button("Learn More") {}
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .glassButton(cornerRadius: 14, tint: .purple)
    }
    .padding(24)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(
        LinearGradient(
            colors: [Color(.systemGroupedBackground), Color(.secondarySystemBackground)],
            startPoint: .top,
            endPoint: .bottom
        )
    )
}

#Preview("Glass Circle Buttons") {
    HStack(spacing: 20) {
        Button(action: {}) {
            Image(systemName: "plus")
                .font(.title2.weight(.semibold))
                .foregroundStyle(.white)
                .frame(width: 56, height: 56)
        }
        .glassCircleButton(tint: .blue)

        Button(action: {}) {
            Image(systemName: "heart.fill")
                .font(.title3.weight(.semibold))
                .foregroundStyle(.white)
                .frame(width: 48, height: 48)
        }
        .glassCircleButton(tint: .red)

        Button(action: {}) {
            Image(systemName: "star.fill")
                .font(.title3.weight(.semibold))
                .foregroundStyle(.white)
                .frame(width: 40, height: 40)
        }
        .glassCircleButton(tint: .yellow)
    }
    .padding(32)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(
        LinearGradient(
            colors: [Color(.systemGroupedBackground), Color(.secondarySystemBackground)],
            startPoint: .top,
            endPoint: .bottom
        )
    )
}

#Preview("Glass Effect Container") {
    GlassEffectContainer(cornerRadius: 20, tint: .white) {
        VStack(alignment: .leading, spacing: 8) {
            Text("Glass Card")
                .font(.headline)
            Text("This is a glassmorphism container that adapts to iOS versions.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
    }
    .padding(24)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(
        LinearGradient(
            colors: [Color(.systemGroupedBackground), Color(.secondarySystemBackground)],
            startPoint: .top,
            endPoint: .bottom
        )
    )
}
