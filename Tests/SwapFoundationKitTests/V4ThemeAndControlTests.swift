import SwiftUI
import UIKit
import XCTest
@testable import SwapFoundationKit

/// Compile and contract fixtures for the v4 semantic UI surface.
///
/// These tests intentionally avoid pixel assertions: token resolution is
/// environment-driven and should be exercised by host previews and UI tests.
final class V4ThemeAndControlTests: XCTestCase {
    func testThemeCustomizationAndEnvironmentValues() {
        let theme = SFKTheme.system
            .accent(.indigo)

        XCTAssertEqual(theme.spacing.control, SFKTheme.Spacing.system.control)
        XCTAssertEqual(theme.spacing.section, SFKTheme.Spacing.system.section)
        XCTAssertEqual(theme.radii.card, SFKTheme.Radii.system.card)

        let custom = SFKTheme(
            spacing: .init(control: 16, section: 32, inline: 10),
            radii: .init(control: 10, card: 24),
            feedback: .init(enabled: false)
        )
        XCTAssertEqual(custom.spacing.control, 16)
        XCTAssertEqual(custom.spacing.section, 32)
        XCTAssertEqual(custom.spacing.inline, 10)
        XCTAssertEqual(custom.radii.card, 24)
        XCTAssertFalse(custom.feedback.enabled)

        let contrastTheme = SFKTheme.Colors(
            accent: .yellow,
            destructive: .pink,
            onAccent: .black,
            onDestructive: .yellow
        )
        XCTAssertEqual(contrastTheme.onAccent, .black)
        XCTAssertEqual(contrastTheme.onDestructive, .yellow)

        let projectedAppearance = SFKTextFieldAppearance(theme: custom)
        XCTAssertEqual(projectedAppearance.cornerRadius, 10)
        XCTAssertEqual(projectedAppearance.horizontalPadding, 16)

        let themedView = Text("Themed").sfkTheme(custom)
        _ = themedView
    }

    func testSemanticButtonRolesAndFocusedModifiersCompile() {
        let loadingButton: SFKButton = SFKButton("Continue") { }
            .sfkIcon("arrow.right")
            .sfkSubtitle("Review your details")
            .sfkLoading(true)
            .sfkFullWidth(false)
            .sfkTint(.indigo)
        _ = loadingButton

        let destructiveButton: SFKButton = SFKButton("Delete", role: .destructive) { }
            .sfkIcon("trash")
        _ = destructiveButton

        let compactIcon: SFKCompactButton = SFKCompactButton(
            systemImage: "ellipsis",
            accessibilityLabel: "More"
        ) { }
        let compactText = SFKCompactButton("Edit") { }
        let compactIconAndText = SFKCompactButton("Edit", systemImage: "pencil") { }
        let legacyChrome: SFKCloseButtonChrome = .toolbar
        _ = (compactIcon, compactText, compactIconAndText, legacyChrome)
    }

    func testCompactTextFieldAndFocusedAppearanceCompile() {
        var value = ""
        var focused = false
        let binding = Binding<String>(
            get: { value },
            set: { value = $0 }
        )
        let focusBinding = Binding<Bool>(
            get: { focused },
            set: { focused = $0 }
        )

        let compactField: SFKTextField = SFKTextField("Email", text: binding)
            .sfkInput(.email)
            .sfkStatus(.error("Invalid address"))
            .sfkSupportingText("Use a valid email address.")
            .sfkTint(.indigo)
            .sfkOnSubmit { value = value.trimmingCharacters(in: .whitespaces) }
            .sfkFocused(focusBinding)
            .sfkTrailingAction(systemImage: "xmark.circle.fill", accessibilityLabel: "Clear") {
                value = ""
            }
            .sfkAppearance(.standard.metrics(cornerRadius: 10))
            .sfkSecure(false)
        _ = compactField

        let appearance = SFKTextFieldAppearance(
            backgroundColor: .clear,
            focusedBorderColor: .indigo
        )
        let customizedAppearance = appearance.metrics(cornerRadius: 8)
        let configuredField = SFKTextField(
            "Configured",
            text: binding,
            prompt: "Configured placeholder"
        )
        .sfkAppearance(customizedAppearance)
        _ = configuredField
        XCTAssertEqual(customizedAppearance.cornerRadius, 8)
        XCTAssertEqual(appearance.cornerRadius, 12)
    }

    /// `accessibilityReduceMotion` is a read-only system environment value in the
    /// current SDK. Reduce Motion behavior is therefore verified manually with
    /// the simulator's Accessibility setting, while this fixture checks that
    /// themed controls remain constructible with the configured motion policy.
    func testThemeMotionAndFeedbackConfigurationCompile() {
        let themedControls = VStack {
            SFKButton("Continue", role: .primary) { }
            SFKChip("Filter", style: .secondary) { }
        }
        .sfkTheme(SFKTheme(
            motion: .init(standard: .linear(duration: 0.2)),
            feedback: .init(enabled: false)
        ))

        _ = themedControls
    }

    @MainActor
    func testRenderedControlsRespectDynamicTypeAndThemeTokens() {
        let theme = SFKTheme(
            colors: .init(accent: .indigo, onAccent: .yellow),
            feedback: .init(enabled: false, style: .none)
        )
        let button = SFKButton(
            "A deliberately long action title that must remain readable",
            role: .primary
        ) { }
        .sfkTheme(theme)
        .environment(\.sizeCategory, .accessibilityExtraExtraExtraLarge)

        let buttonHost = UIHostingController(rootView: button)
        buttonHost.loadViewIfNeeded()
        let buttonSize = buttonHost.sizeThatFits(in: CGSize(width: 180, height: 400))
        XCTAssertGreaterThan(buttonSize.height, 44)
        XCTAssertGreaterThan(buttonSize.width, 0)

        let field = SFKTextField("Email", text: .constant(""), prompt: "you@example.com")
            .sfkInput(.email)
            .sfkTheme(theme)
            .environment(\.sizeCategory, .accessibilityExtraExtraExtraLarge)
        let fieldHost = UIHostingController(rootView: field)
        fieldHost.loadViewIfNeeded()
        let fieldSize = fieldHost.sizeThatFits(in: CGSize(width: 320, height: 200))
        XCTAssertGreaterThanOrEqual(fieldSize.height, SFKTextFieldAppearance.standard.minimumHeight)
    }

    @MainActor
    func testCompactButtonStandaloneSizingAndDynamicTypeGrowth() {
        let theme = SFKTheme.system.accent(.indigo)

        let icon = SFKCompactButton(
            systemImage: "ellipsis",
            accessibilityLabel: "More",
            chrome: .glass
        ) { }
        let iconSize = sizeThatFits(icon.sfkTheme(theme), in: CGSize(width: 200, height: 200))
        XCTAssertGreaterThanOrEqual(iconSize.width, 35)
        XCTAssertGreaterThanOrEqual(iconSize.height, 35)

        let shortText = SFKCompactButton("Edit", chrome: .glass) { }
        let longText = SFKCompactButton(
            "A longer action title",
            systemImage: "pencil",
            chrome: .glass
        ) { }
        let shortSize = sizeThatFits(shortText.sfkTheme(theme), in: CGSize(width: 300, height: 100))
        let longSize = sizeThatFits(longText.sfkTheme(theme), in: CGSize(width: 400, height: 100))
        XCTAssertGreaterThanOrEqual(shortSize.width, 35)
        XCTAssertGreaterThanOrEqual(shortSize.height, 35)
        XCTAssertGreaterThan(longSize.width, shortSize.width)
        XCTAssertGreaterThanOrEqual(longSize.height, 35)

        let largeText = SFKCompactButton(
            "A longer action title",
            systemImage: "pencil",
            chrome: .glass
        ) { }
        .sfkTheme(theme)
        .environment(\.sizeCategory, .accessibilityExtraExtraExtraLarge)
        let largeSize = sizeThatFits(largeText, in: CGSize(width: 600, height: 200))
        XCTAssertGreaterThan(largeSize.width, shortSize.width)
        XCTAssertGreaterThanOrEqual(largeSize.height, longSize.height)
    }

    @MainActor
    private func sizeThatFits<Content: View>(
        _ view: Content,
        in proposal: CGSize
    ) -> CGSize {
        let host = UIHostingController(rootView: view)
        host.loadViewIfNeeded()
        return host.sizeThatFits(in: proposal)
    }
}
