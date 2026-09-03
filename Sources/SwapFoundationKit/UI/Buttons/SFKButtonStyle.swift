/****************************************************************************
 * SFKButtonStyle.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2026 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import SwiftUI

/// The semantic role of an ``SFKButton``.
///
/// Choose a role based on visual hierarchy rather than placement:
///
/// - ``primary``: The main action in a flow.
/// - ``secondary``: A supporting or alternative action with visible chrome.
/// - ``borderless``: A text or icon control with no fill, glass, or border.
/// - ``destructive``: An action that removes or irreversibly changes data.
public enum SFKButtonStyle: Sendable, Equatable {
    case primary
    case secondary
    case borderless
    /// A destructive action such as deleting or removing data.
    case destructive

    /// Renamed to ``borderless``. The old name described placement, not appearance.
    @available(*, deprecated, renamed: "borderless")
    public static var toolbar: Self { .borderless }

    var defaultTitleColor: Color {
        switch self {
        case .primary:
            .white
        case .secondary, .borderless:
            .primary
        case .destructive:
            .white
        }
    }

    var defaultSubtitleColor: Color {
        switch self {
        case .primary:
            Color.white.opacity(0.8)
        case .secondary, .borderless:
            .secondary
        case .destructive:
            Color.white.opacity(0.8)
        }
    }
}

/// Semantic content alignment for an `SFKButton`.
///
/// Alignment affects the content of full-width buttons. For `trailing`, an
/// optional icon moves after the title and subtitle to keep it on the trailing
/// edge; `leading` and `center` retain the conventional leading icon order.
///
/// ## Usage
///
/// ```swift
/// SFKButton("Continue", role: .primary) { submit() }
///     .sfkIcon("arrow.right")
///     .sfkAlignment(.trailing)
/// ```
public enum SFKButtonAlignment: Sendable, Equatable {
    case leading
    case center
    case trailing

    var horizontalAlignment: HorizontalAlignment {
        switch self {
        case .leading: .leading
        case .center: .center
        case .trailing: .trailing
        }
    }

    var frameAlignment: Alignment {
        switch self {
        case .leading: .leading
        case .center: .center
        case .trailing: .trailing
        }
    }
}
