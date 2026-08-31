import SwiftUI

/// The Liquid Glass material used by a custom surface.
public enum SFKGlassMaterial: Sendable {
    case regular
    case clear
}

/// The shape the glass effect is applied to.
public enum SFKGlassShape: Sendable {
    case roundedRectangle(cornerRadius: CGFloat, style: RoundedCornerStyle = .continuous)
    case capsule
    case circle
}

private struct SFKGlassSurfaceModifier: ViewModifier {
    let material: SFKGlassMaterial
    let tint: Color?
    let isInteractive: Bool
    let shape: SFKGlassShape

    @ViewBuilder
    func body(content: Content) -> some View {
        if #available(iOS 26, macOS 26, watchOS 26, tvOS 26, visionOS 26, *) {
            content.glassEffect(resolvedGlass, in: resolvedShape)
        } else {
            content.background(fallback)
        }
    }

    @available(iOS 26, macOS 26, watchOS 26, tvOS 26, visionOS 26, *)
    private var resolvedGlass: Glass {
        let base: Glass = switch material {
        case .regular: .regular
        case .clear: .clear
        }
        return base
            .tint(tint)
            .interactive(isInteractive)
    }

    @available(iOS 26, macOS 26, watchOS 26, tvOS 26, visionOS 26, *)
    private var resolvedShape: AnyShape {
        switch shape {
        case let .roundedRectangle(cornerRadius, style):
            AnyShape(RoundedRectangle(cornerRadius: cornerRadius, style: style))
        case .capsule:
            AnyShape(Capsule())
        case .circle:
            AnyShape(Circle())
        }
    }

    @ViewBuilder
    private var fallback: some View {
        switch shape {
        case let .roundedRectangle(cornerRadius, style):
            fallbackShape(RoundedRectangle(cornerRadius: cornerRadius, style: style))
        case .capsule:
            fallbackShape(Capsule())
        case .circle:
            fallbackShape(Circle())
        }
    }

    private func fallbackShape<S: Shape>(_ shape: S) -> some View {
        shape
            .fill(.ultraThinMaterial)
            .overlay {
                if let tint { shape.fill(tint) }
            }
    }
}

public extension View {
    /// Applies Liquid Glass to a custom control or surface with a pre-iOS-26 fallback.
    /// Buttons should use ``SFKButton`` and its semantic role instead.
    func sfkGlass(
        material: SFKGlassMaterial,
        tint: Color? = nil,
        isInteractive: Bool = false,
        shape: SFKGlassShape
    ) -> some View {
        modifier(SFKGlassSurfaceModifier(
            material: material,
            tint: tint,
            isInteractive: isInteractive,
            shape: shape
        ))
    }
}

#Preview("Custom Glass Surfaces") {
    HStack(spacing: 20) {
        Text("A")
            .font(.headline.weight(.bold))
            .frame(width: 56, height: 56)
            .sfkGlass(material: .regular, tint: .blue, isInteractive: true, shape: .circle)

        Text("B")
            .font(.headline.weight(.bold))
            .frame(height: 44)
            .padding(.horizontal, 18)
            .sfkGlass(material: .clear, tint: .green, isInteractive: true, shape: .capsule)
    }
    .padding(30)
    .background(LinearGradient(colors: [.orange, .pink, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
}
