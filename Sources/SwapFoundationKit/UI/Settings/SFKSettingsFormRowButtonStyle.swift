//
//  SFKSettingsFormRowButtonStyle.swift
//  SwapFoundationKit
//

import SwiftUI

/// Button style for settings rows inside ``Form``/``List``.
///
/// ``BorderlessButtonStyle`` keeps reliable hit testing in grouped lists, but on recent OS versions it can
/// also tint row labels with the app accent (often blue). This style keeps press feedback without recoloring
/// titles or subtitles.
public struct SFKSettingsFormRowButtonStyle: ButtonStyle {

    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.55 : 1.0)
    }
}
