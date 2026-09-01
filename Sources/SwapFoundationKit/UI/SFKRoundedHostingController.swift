#if canImport(SwiftUI)
import SwiftUI

/// A `UIHostingController` subclass that applies `.fontDesign(.rounded)` to its root view.
///
/// Use this when embedding SwiftUI views in a UIKit app with a rounded typography design.
///
/// ## Usage
/// ```swift
/// let vc = SFKRoundedHostingController(rootView: MySettingsView())
/// navigationController.pushViewController(vc, animated: true)
/// ```
open class SFKRoundedHostingController<Content: View>: UIHostingController<AnyView> {

    public init(rootView: Content) {
        super.init(
            rootView: AnyView(
                rootView
                    .font(.system(.body, design: .rounded))
                    .fontDesign(.rounded)
            )
        )
    }

    @MainActor @objc required dynamic public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Rounded typography re-application
    //
    // SwiftUI modifiers like `toolbarBackground` synthesize fresh, per-instance
    // `UINavigationBarAppearance` values on the navigation item / navigation bar. Those
    // synthesized appearances do NOT inherit the `UINavigationBar.appearance()` proxy fonts
    // that `SFKAppearanceManager.configure()` set globally, so without re-patching them here
    // the navigation bar silently reverts to the system (non-rounded) font whenever SwiftUI
    // decides to resynthesize its appearance. This happens more than once per screen, and at
    // unpredictable points in the view lifecycle, hence patching from three different
    // lifecycle hooks below rather than once.

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        applyRoundedNavigationFonts()
    }

    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        applyRoundedNavigationFonts()
        // SwiftUI can finish synthesizing toolbar appearances after `viewDidAppear` returns
        // (e.g. once the enclosing NavigationStack finishes its own appear pass), so a
        // same-runloop-turn-later re-apply is needed to catch appearances that land late.
        DispatchQueue.main.async { [weak self] in
            self?.applyRoundedNavigationFonts()
        }
    }

    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        applyRoundedNavigationFonts()
    }

    private func applyRoundedNavigationFonts() {
        SFKAppearanceManager.applyRoundedFonts(to: navigationItem)
        if let navigationBar = navigationController?.navigationBar {
            SFKAppearanceManager.applyRoundedFonts(to: navigationBar)
        }
    }
}
#endif
