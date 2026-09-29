/****************************************************************************
 * SFKNumberPad.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2026 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import SwiftUI

/// A 3-column amount-entry keypad (`1`–`9`, `.`, `0`, backspace).
///
/// Pair this with ``SFKAmountInput`` to apply the shared amount-entry rules,
/// or pass the raw ``SFKNumberPadInput`` straight to an existing amount
/// string editor. Styling and layout are fixed to match the keypad every
/// host app already used.
///
/// ## Usage
/// ```swift
/// SFKNumberPad { input in
///     viewModel.applyNumberPadInput(input)
/// }
/// ```
public struct SFKNumberPad: View {
    private let layout = [
        GridItem(.flexible(minimum: 72), spacing: 10),
        GridItem(.flexible(minimum: 72), spacing: 10),
        GridItem(.flexible(minimum: 72), spacing: 10)
    ]
    private let action: (_ input: SFKNumberPadInput) -> Void

    public init(action: @escaping (_ input: SFKNumberPadInput) -> Void) {
        self.action = action
    }

    public var body: some View {
        LazyVGrid(columns: layout, spacing: 10) {
            ForEach(SFKNumberPadInput.allCases, id: \.self) { number in
                SFKNumberPadButton(number: number) {
                    action(number)
                }
            }
        }
    }
}

#Preview {
    SFKNumberPad { _ in }
        .padding()
}
