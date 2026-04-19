//
//  CompatibleNavigationSubtitle.swift
//  SwapFoundationKit
//
//  Created by Swapnanil Dhol  on 4/19/26.
//

import SwiftUI

/// A view modifier that applies `navigationSubtitle` on iOS 26+ with no-op fallback on earlier versions.
public struct SFKNavigationSubtitle: ViewModifier {
    private let subtitle: String

    public init(_ subtitle: String) {
        self.subtitle = subtitle
    }

    public func body(content: Content) -> some View {
        if #available(iOS 26, *) {
            content
                .navigationSubtitle(subtitle)
        } else {
            content
        }
    }
}

public extension View {
    /// Applies `navigationSubtitle` on iOS 26+; silent no-op on earlier versions.
    func sfkNavigationSubtitle(_ subtitle: String) -> some View {
        modifier(SFKNavigationSubtitle(subtitle))
    }
}

#Preview {
    NavigationStack {
        Text("Hello!")
            .font(.headline)
            .navigationTitle("Navigation Title")
            .sfkNavigationSubtitle("This is a subtitle")
    }
}
