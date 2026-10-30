import SwiftUI

public extension View {
    /// Applies the soft scroll edge effect on iOS 26 and later. No-op on earlier systems.
    ///
    /// Wraps `scrollEdgeEffectStyle(.soft, for:)` so hosts that deploy below iOS 26
    /// don't need their own availability checks.
    @ViewBuilder
    func sfkSoftScrollEdgeEffect(for edges: Edge.Set = .top) -> some View {
        if #available(iOS 26, *) {
            scrollEdgeEffectStyle(.soft, for: edges)
        } else {
            self
        }
    }

    /// Hides the scroll edge effect on iOS 26 and later. No-op on earlier systems.
    ///
    /// Wraps `scrollEdgeEffectHidden(_:for:)`.
    @ViewBuilder
    func sfkHiddenScrollEdgeEffect(for edges: Edge.Set = .top) -> some View {
        if #available(iOS 26, *) {
            scrollEdgeEffectHidden(true, for: edges)
        } else {
            self
        }
    }
}
