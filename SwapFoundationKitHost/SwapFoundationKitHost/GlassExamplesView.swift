/****************************************************************************
 * GlassExamplesView.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2026 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import SwiftUI
import SwapFoundationKit

struct GlassExamplesView: View {
    @State private var isFavorite = false
    @State private var isExpanded = true
    @Namespace private var glassNamespace

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 30) {
                guidanceHeader
                materialVariants
                buttonStyles
                shapeVariants
                interactiveGlass
                containerAndMorphing
                usageGuidance
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Liquid Glass")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var guidanceHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Controls above content", systemImage: "square.3.layers.3d.top.filled")
                .font(.headline)

            Text("Liquid Glass is a functional layer for controls and navigation. The examples below sit over content so you can judge their real translucency, contrast, and response.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.background, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private var materialVariants: some View {
        CatalogExampleGroup(
            title: "Material Variants",
            apiNames: ["Glass.regular", "Glass.clear", "Glass.identity"]
        ) {
            GlassDemoStage {
                VStack(spacing: 14) {
                    nativeGlassLabel("Regular", detail: "Default", glass: .regular)
                    nativeGlassLabel("Clear", detail: "Media", glass: .clear)

                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Identity")
                                .font(.subheadline.weight(.semibold))
                            Text("No effect")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Image(systemName: "circle.slash")
                    }
                    .padding(.horizontal, 16)
                    .frame(height: 58)
                    .glassEffect(.identity, in: .rect(cornerRadius: 18))
                }
                .padding(18)
            }
        }
    }

    private var buttonStyles: some View {
        CatalogExampleGroup(
            title: "Button Emphasis",
            apiNames: ["buttonStyle(.glass)", "buttonStyle(.glassProminent)"]
        ) {
            GlassDemoStage {
                HStack(spacing: 12) {
                    Button("Secondary") {}
                        .buttonStyle(.glass)

                    Button("Primary") {}
                        .buttonStyle(.glassProminent)
                        .tint(.blue)
                }
                .controlSize(.large)
                .padding(22)
            }
        }
    }

    private var shapeVariants: some View {
        CatalogExampleGroup(
            title: "Shapes",
            apiNames: ["SFKGlassShape.circle", ".capsule", ".roundedRectangle"]
        ) {
            GlassDemoStage {
                HStack(spacing: 14) {
                    Image(systemName: "circle.fill")
                        .frame(width: 54, height: 54)
                        .sfkGlass(color: .blue.opacity(0.12), shape: .circle)

                    Text("Capsule")
                        .font(.subheadline.weight(.semibold))
                        .frame(height: 54)
                        .padding(.horizontal, 16)
                        .sfkGlass(color: .blue.opacity(0.12), shape: .capsule)

                    Image(systemName: "rectangle.roundedtop.fill")
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .sfkGlass(
                            color: .blue.opacity(0.12),
                            shape: .roundedRectangle(cornerRadius: 16)
                        )
                }
                .padding(18)
            }
        }
    }

    private var interactiveGlass: some View {
        CatalogExampleGroup(
            title: "Tint & Interaction",
            apiNames: ["Glass.tint", "Glass.interactive", "sfkGlass"]
        ) {
            GlassDemoStage {
                Button {
                    isFavorite.toggle()
                } label: {
                    Label(
                        isFavorite ? "Favorited" : "Tap to favorite",
                        systemImage: isFavorite ? "heart.fill" : "heart"
                    )
                    .font(.subheadline.weight(.semibold))
                    .padding(.horizontal, 18)
                    .frame(height: 54)
                }
                .buttonStyle(.plain)
                .foregroundStyle(isFavorite ? .white : .primary)
                .sfkGlass(
                    color: isFavorite ? .pink : .blue.opacity(0.14),
                    isInteractive: true,
                    shape: .capsule
                )
                .animation(.snappy, value: isFavorite)
                .padding(22)
            }
        }
    }

    private var containerAndMorphing: some View {
        CatalogExampleGroup(
            title: "Container & Morphing",
            apiNames: ["GlassEffectContainer", "glassEffectID"]
        ) {
            GlassDemoStage {
                GlassEffectContainer(spacing: 28) {
                    HStack(spacing: 18) {
                        morphingSymbol("scribble.variable", id: "draw")

                        if isExpanded {
                            morphingSymbol("eraser.fill", id: "erase")
                                .transition(.identity)
                        }

                        Button {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.78)) {
                                isExpanded.toggle()
                            }
                        } label: {
                            Image(systemName: isExpanded ? "arrow.left.and.right.circle.fill" : "plus")
                                .frame(width: 50, height: 50)
                        }
                        .buttonStyle(.glassProminent)
                        .buttonBorderShape(.circle)
                        .tint(.blue)
                        .accessibilityLabel(isExpanded ? "Collapse glass shapes" : "Expand glass shapes")
                    }
                }
                .padding(22)
            }
        }
    }

    private var usageGuidance: some View {
        CatalogExampleGroup(
            title: "Apple Guidance",
            apiNames: ["Human Interface Guidelines · Materials"]
        ) {
            VStack(alignment: .leading, spacing: 12) {
                guidanceRow("Use glass for controls and navigation above content.", systemImage: "square.3.layers.3d")
                guidanceRow("Use Regular by default; reserve Clear for rich media.", systemImage: "photo.on.rectangle")
                guidanceRow("Tint sparingly to communicate prominence or meaning.", systemImage: "paintbrush.pointed")
                guidanceRow("Use interactive glass only on elements people can operate.", systemImage: "hand.tap")

                Divider()

                Link(destination: URL(string: "https://developer.apple.com/design/human-interface-guidelines/materials")!) {
                    Label("Apple HIG: Materials", systemImage: "arrow.up.right.square")
                }

                Link(destination: URL(string: "https://developer.apple.com/documentation/swiftui/applying-liquid-glass-to-custom-views")!) {
                    Label("SwiftUI: Applying Liquid Glass", systemImage: "arrow.up.right.square")
                }
            }
            .padding(16)
            .background(.background, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
    }

    private func nativeGlassLabel(_ title: String, detail: String, glass: Glass) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: title == "Clear" ? "drop.fill" : "circle.lefthalf.filled")
        }
        .padding(.horizontal, 16)
        .frame(height: 58)
        .glassEffect(glass, in: .rect(cornerRadius: 18))
    }

    private func morphingSymbol(_ symbol: String, id: String) -> some View {
        Image(systemName: symbol)
            .font(.title3.weight(.semibold))
            .frame(width: 54, height: 54)
            .glassEffect(.regular.interactive(), in: .circle)
            .glassEffectID(id, in: glassNamespace)
    }

    private func guidanceRow(_ title: String, systemImage: String) -> some View {
        Label(title, systemImage: systemImage)
            .font(.subheadline)
            .foregroundStyle(.secondary)
    }
}

private struct GlassDemoStage<Content: View>: View {
    private let content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        content()
            .frame(maxWidth: .infinity)
            .background {
                LinearGradient(
                    colors: [
                        Color.indigo.opacity(0.76),
                        Color.cyan.opacity(0.56),
                        Color.orange.opacity(0.48)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .overlay(alignment: .topTrailing) {
                    Circle()
                        .fill(.white.opacity(0.42))
                        .frame(width: 120, height: 120)
                        .blur(radius: 4)
                        .offset(x: 34, y: -42)
                }
                .overlay(alignment: .bottomLeading) {
                    Image(systemName: "wave.3.right")
                        .font(.system(size: 72, weight: .thin))
                        .foregroundStyle(.white.opacity(0.2))
                        .offset(x: 10, y: 18)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .strokeBorder(.white.opacity(0.16))
            }
    }
}

#Preview {
    NavigationStack {
        GlassExamplesView()
    }
    .fontDesign(.rounded)
}
