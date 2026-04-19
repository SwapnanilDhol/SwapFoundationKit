/*****************************************************************************
 * CompatibleTabBarMinimizeBehavior.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2026 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import SwiftUI

/// A view modifier that applies `tabBarMinimizeBehavior(.onScrollDown)` on iOS 26+
/// with no-op fallback on earlier versions.
public struct SFKTabBarMinimizeBehavior: ViewModifier {
    public init() {}

    public func body(content: Content) -> some View {
        if #available(iOS 26, *) {
            content
                .tabBarMinimizeBehavior(.onScrollDown)
        } else {
            content
        }
    }
}

public extension View {
    /// Applies `tabBarMinimizeBehavior(.onScrollDown)` on iOS 26+; silent no-op on earlier versions.
    func compatibleTabBarMinimizeBehavior() -> some View {
        modifier(SFKTabBarMinimizeBehavior())
    }
}

#Preview {
    TabView {
        ScrollView {
            VStack(spacing: 20) {
                ForEach(0..<30) { i in
                    Text("Row \(i)")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.gray.opacity(0.2))
                }
            }
        }
        .tabItem {
            Label("Scroll", systemImage: "arrow.down.circle")
        }
    }
    .compatibleTabBarMinimizeBehavior()
}
