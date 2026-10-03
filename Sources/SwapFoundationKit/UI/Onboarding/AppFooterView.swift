/****************************************************************************
 * AppFooterView.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2026 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import SwiftUI

/// A safe-area-aware footer for one or two caller-supplied action views.
///
/// The footer controls placement and its background while leaving button style,
/// labels, loading state, and actions to the host app.
///
/// ## Usage
/// ```swift
/// AppFooterView(primary: {
///     SFKButton("Continue", role: .primary) { advance() }
///         .sfkIcon("arrow.right")
/// }, secondary: {
///     SFKButton("Continue with Free", role: .borderless) { continueForFree() }
/// })
/// ```
public struct AppFooterView<Primary: View, Secondary: View>: View {
    /// The layout used when both action views are present.
    public enum Arrangement {
        /// Places the actions in separate vertical rows.
        case stacked
        /// Places the actions next to each other in a horizontal row.
        case sideBySide
    }

    /// The footer surface style.
    public enum Appearance {
        /// Uses a translucent ultra-thin material.
        case material
        /// Uses the grouped system background with slight transparency.
        case solid
    }

    private let primary: Primary
    private let secondary: Secondary?
    private let arrangement: Arrangement
    private let appearance: Appearance

    /// Creates a footer containing primary and secondary action views.
    /// - Parameters:
    ///   - arrangement: Placement of the two actions. Defaults to `.stacked`.
    ///   - appearance: Footer surface style. Defaults to `.material`.
    ///   - primary: The primary action view.
    ///   - secondary: The optional secondary action view.
    public init(
        arrangement: Arrangement = .stacked,
        appearance: Appearance = .material,
        @ViewBuilder primary: () -> Primary,
        @ViewBuilder secondary: () -> Secondary
    ) {
        self.primary = primary()
        self.secondary = secondary()
        self.arrangement = arrangement
        self.appearance = appearance
    }

    public var body: some View {
        Group {
            if let secondary {
                switch arrangement {
                case .stacked:
                    VStack {
                        primary
                        secondary
                    }
                case .sideBySide:
                    HStack {
                        primary
                        secondary
                    }
                }
            } else {
                primary
            }
        }
        .padding(.horizontal)
        .padding(.top)
        .padding(.bottom)
        .background {
            VStack {
                switch appearance {
                case .material:
                    Rectangle()
                        .fill(.ultraThinMaterial)
                case .solid:
                    Color(.systemGroupedBackground)
                        .opacity(0.92)
                }
            }
            .ignoresSafeArea(edges: .bottom)
        }
    }
}

public extension AppFooterView where Secondary == EmptyView {
    /// Creates a footer containing only the primary action view.
    /// - Parameters:
    ///   - appearance: Footer surface style. Defaults to `.material`.
    ///   - primary: The primary action view.
    init(
        appearance: Appearance = .material,
        @ViewBuilder primary: () -> Primary
    ) {
        self.primary = primary()
        self.secondary = nil
        self.arrangement = .stacked
        self.appearance = appearance
    }
}

private struct AppFooterPreviewHost<Footer: View>: View {
    let footer: Footer

    var body: some View {
        VStack {
            List(1...100, id: \.self) { item in
                Text("App Content")
                    .font(.headline)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
        .safeAreaInset(edge: .bottom) {
            footer
        }
    }
}

#Preview("Primary only") {
    AppFooterPreviewHost(footer: AppFooterView(primary: {
        SFKButton("Continue", role: .primary, action: {})
            .sfkIcon("arrow.right")
    }))
}

#Preview("Two primary actions side by side") {
    AppFooterPreviewHost(footer: AppFooterView(
        arrangement: .sideBySide,
        primary: {
            SFKButton("Create Pass", role: .primary, action: {})
                .sfkIcon("wallet.pass.fill")
        },
        secondary: {
            SFKButton("Import Pass", role: .secondary, action: {})
                .sfkIcon("square.and.arrow.down")
        }
    ))
}

#Preview("Two primary actions stacked") {
    AppFooterPreviewHost(footer: AppFooterView(
        primary: {
            SFKButton("Create Pass", role: .primary, action: {})
                .sfkIcon("wallet.pass.fill")
        },
        secondary: {
            SFKButton("Import Pass", role: .secondary, action: {})
                .sfkIcon("square.and.arrow.down")
        }
    ))
}

#Preview("Primary with text secondary") {
    AppFooterPreviewHost(footer: AppFooterView(
        primary: {
            SFKButton("Review purchase", role: .primary, action: {})
                .sfkIcon("bag.fill")
        },
        secondary: {
            SFKButton("Continue with Free", role: .borderless, action: {})
                .frame(maxWidth: .infinity, minHeight: 44)
                .contentShape(Rectangle())
        }
    ))
}

#Preview("Primary with filled secondary") {
    AppFooterPreviewHost(footer: AppFooterView(
        arrangement: .sideBySide,
        primary: {
            SFKButton("Continue", role: .primary, action: {})
                .sfkIcon("arrow.right")
        },
        secondary: {
            SFKButton("Not now", role: .secondary, action: {})
                .sfkIcon("xmark")
        }
    ))
}

#Preview("Primary with stacked secondary") {
    AppFooterPreviewHost(footer: AppFooterView(
        primary: {
            SFKButton("Continue", role: .primary, action: {})
                .sfkIcon("arrow.right")
        },
        secondary: {
            SFKButton("Not now", role: .secondary, action: {})
                .sfkIcon("xmark")
        }
    ))
}

#Preview("Loading and disabled") {
    AppFooterPreviewHost(footer: AppFooterView(
        primary: {
            SFKButton("Finishing", role: .primary, action: {})
                .sfkIcon("checkmark")
                .sfkLoading(true)
        },
        secondary: {
            SFKButton("Continue with Free", role: .borderless, action: {})
                .disabled(true)
        }
    ))
}
