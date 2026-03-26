/*****************************************************************************
 * CurrencyExamplesView.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2025 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import SwiftUI
import SwapFoundationKit

/// Examples for `Currency` enums and helpers.
struct CurrencyExamplesView: View {
    var body: some View {
        List {
            Section("Common") {
                LabeledContent("USD symbol", value: Currency.USD.currencySymbol)
                LabeledContent("EUR symbol", value: Currency.EUR.currencySymbol)
                LabeledContent("INR symbol", value: Currency.INR.currencySymbol)
            }
            Section("All codes") {
                ForEach(Array(Currency.allCases), id: \.self) { c in
                    HStack { Text(c.rawValue); Spacer(); Text(c.symbol) }
                }
            }
        }
        .navigationTitle("Currency")
    }
}


