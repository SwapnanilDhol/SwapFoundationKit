//
//  ContentView.swift
//  SwapFoundationKitHost
//
//  Created by Swapnanil Dhol  on 8/8/25.
//

import SwiftUI
import UIKit
import SwapFoundationKit

struct ContentView: View {
    var body: some View {
        // Precompute values so we don't declare inside view builders
        let now = Date()
        let sample = " Hello World \n"
        let color = UIColor(hex: "#FF5733")

        return ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Date Formats")
                        .font(.headline)
                    Text("ISO8601: \(now.iso8601String)")
                    Text("Short: \(now.shortDate)")
                    Text("Medium: \(now.mediumDate)")
                    Text("Long: \(now.longDate)")
                    Text("Time: \(now.timeOnly)")
                    Text("yyyy-MM-dd: \(now.yyyyMMdd)")
                    Text("MMM d, yyyy: \(now.MMMdyyyy)")
                }

                Divider()

                VStack(alignment: .leading, spacing: 4) {
                    Text("String Utils")
                        .font(.headline)
                    Text("isBlank: \(sample.isBlank.description)")
                    Text("trimmed: \(sample.trimmed)")
                    Text("removingWhitespaces: \(sample.removingWhitespaces)")
                    Text("isAlphanumeric: \("A1B2".isAlphanumeric.description)")
                }

                Divider()

                VStack(alignment: .leading, spacing: 4) {
                    Text("Number Utils")
                        .font(.headline)
                    Text("Clean double: \(1234.56.clean)")
                    Text("Words (123): \(123.0.wordRepresentation ?? "-")")
                }

                Divider()

                VStack(alignment: .leading, spacing: 4) {
                    Text("Color & UI")
                        .font(.headline)
                    Text("Hex -> UIColor -> Hex: \(color.hex())")
                    Rectangle()
                        .fill(Color(color))
                        .frame(height: 24)
                        .cornerRadius(6)
                }

                Divider()

                VStack(alignment: .leading, spacing: 4) {
                    Text("Haptics (tap)")
                        .font(.headline)
                    Button("Light Impact") {
                        HapticsHelper().lightImpact()
                    }
                    Button("Custom Impact 0.7") {
                        HapticsHelper().customImpact(intensity: 0.7)
                    }
                    Button("Success Notification") {
                        HapticsHelper().successNotification()
                    }
                }
            }
            .padding()
        }
    }
}

#Preview {
    ContentView()
}
