import SwiftUI
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
    }

    func testCompactTextFieldAndCompatibilityAppearanceCompile() {
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
            .sfkAppearance(.init(cornerRadius: 10))
            .sfkSecure(false)
        _ = compactField

        let appearance = SFKTextFieldAppearance(
            backgroundColor: .clear,
            focusedBorderColor: .indigo,
            cornerRadius: 8
        )
        let legacyField = SFKTextField(
            "Legacy",
            text: binding,
            placeholder: "Legacy placeholder",
            appearance: appearance
        )
        _ = legacyField
        XCTAssertEqual(appearance.cornerRadius, 8)
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
}
