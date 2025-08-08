//
//  ContentView.swift
//  SwapFoundationKitHost
//
//  Created by Swapnanil Dhol  on 8/8/25.
//

import SwiftUI
import SwapFoundationKit

struct ContentView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("Core Utilities") {
                    NavigationLink("Date Examples", destination: DateExamplesView())
                    NavigationLink("String Examples", destination: StringExamplesView())
                    NavigationLink("Number Examples", destination: NumberExamplesView())
                    NavigationLink("Bundle InfoPlist Examples", destination: BundleInfoPlistExamplesView())
                    NavigationLink("Debouncer Examples", destination: DebouncerExamplesView())
                    NavigationLink("UserDefault Examples", destination: UserDefaultExamplesView())
                }
                Section("UI & System") {
                    NavigationLink("Color / UIColor Examples", destination: ColorExamplesView())
                    NavigationLink("Haptics Examples", destination: HapticsExamplesView())
                    NavigationLink("UIApplication Helpers", destination: UIApplicationHelpersExamplesView())
                    NavigationLink("Item Sharing Examples", destination: ItemDetailSourceExamplesView())
                    NavigationLink("App Link Opener Examples", destination: AppLinkOpenerExamplesView())
                }
                Section("Analytics & Logging") {
                    NavigationLink("Logger Examples", destination: LoggerExamplesView())
                    NavigationLink("Analytics Examples", destination: AnalyticsExamplesView())
                }
                Section("Currency & Rates") {
                    NavigationLink("Currency Examples", destination: CurrencyExamplesView())
                    NavigationLink("Exchange Rate Manager", destination: ExchangeRateManagerExamplesView())
                }
            }
            .navigationTitle("SwapFoundationKit Examples")
        }
    }
}
