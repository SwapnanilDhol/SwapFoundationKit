/*****************************************************************************
 * CatalogDestinationView.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2026 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import SwiftUI

struct CatalogDestinationView: View {
    let destination: CatalogDestination

    @ViewBuilder
    var body: some View {
        switch destination {
        case .buttons: ButtonExamplesView()
        case .settings: SettingsExamplesView()
        case .colorPicker: ColorExamplesView()
        case .chips: ChipExamplesView()
        case .progress: ProgressExamplesView()
        case .cardsAndTypography: CardAndTypographyExamplesView()
        case .itemPicker: ItemPickerExamplesView()
        case .glass: GlassExamplesView()
        case .effects: EffectsExamplesView()
        case .proBanner: ProBannerExamplesView()
        case .alerts: AlertExamplesView()
        case .captureAndMedia: CaptureExamplesView()
        case .appearance: AppearanceExamplesView()
        case .haptics: HapticsExamplesView()
        case .analytics: AnalyticsExamplesView()
        case .logging: LoggerExamplesView()
        case .appLinks: AppLinkOpenerExamplesView()
        case .userDefaults: UserDefaultExamplesView()
        case .currency: CurrencyExamplesView()
        case .exchangeRates: ExchangeRateManagerExamplesView()
        case .dates: DateExamplesView()
        case .strings: StringExamplesView()
        case .numbers: NumberExamplesView()
        case .bundleInfo: BundleInfoPlistExamplesView()
        case .debouncer: DebouncerExamplesView()
        case .applicationHelpers: UIApplicationHelpersExamplesView()
        case .itemDetailSource: ItemDetailSourceExamplesView()
        }
    }
}
