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
/// Choose a role based on hierarchy rather than a specific glass implementation:
///
/// - ``primary``: The main action in a flow.
/// - ``secondary``: A supporting or alternative action.
/// - ``toolbar``: A compact control placed in a system toolbar.
/// - ``destructive``: An action that removes or irreversibly changes data.
public enum SFKButtonStyle: Sendable, Equatable {
    case primary
    case secondary
    case toolbar
    /// A destructive action such as deleting or removing data.
    case destructive

    var defaultTitleColor: Color {
        switch self {
        case .primary:
            .white
        case .secondary, .toolbar:
            .primary
        case .destructive:
            .white
        }
    }

    var defaultSubtitleColor: Color {
        switch self {
        case .primary:
            Color.white.opacity(0.8)
        case .secondary, .toolbar:
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
