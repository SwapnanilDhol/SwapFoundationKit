/*****************************************************************************
 * CatalogDestination.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2026 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import SwiftUI

enum CatalogSection: String, CaseIterable, Identifiable {
    case components = "Components"
    case services = "Services"
    case foundation = "Foundation APIs"

    var id: Self { self }
}

enum CatalogDestination: String, CaseIterable, Identifiable, Hashable {
    case buttons
    case settings
    case colorPicker
    case onboarding
    case itemPicker
    case glass
    case effects
    case proBanner
    case alerts
    case captureAndMedia
    case appearance
    case haptics
    case analytics
    case logging
    case appLinks
    case userDefaults
    case currency
    case exchangeRates
    case dates
    case strings
    case numbers
    case bundleInfo
    case debouncer
    case applicationHelpers
    case itemDetailSource

    var id: Self { self }

    static var visualComponentCount: Int {
        allCases
            .filter { $0.section == .components }
            .flatMap(\.apiNames)
            .count
    }

    var section: CatalogSection {
        switch self {
        case .buttons, .settings, .colorPicker, .onboarding, .itemPicker,
             .glass, .effects, .proBanner, .alerts, .captureAndMedia, .appearance:
            return .components
        case .haptics, .analytics, .logging, .appLinks, .userDefaults:
            return .services
        case .currency, .exchangeRates, .dates, .strings, .numbers, .bundleInfo,
             .debouncer, .applicationHelpers, .itemDetailSource:
            return .foundation
        }
    }

    var title: String {
        switch self {
        case .buttons: "Buttons"
        case .settings: "Settings"
        case .colorPicker: "Color Picker"
        case .onboarding: "Onboarding"
        case .itemPicker: "Item Picker"
        case .glass: "Liquid Glass"
        case .effects: "Aura Effects"
        case .proBanner: "Pro Banner"
        case .alerts: "Alerts"
        case .captureAndMedia: "Capture & Media"
        case .appearance: "Appearance"
        case .haptics: "Haptics"
        case .analytics: "Analytics"
        case .logging: "Logging"
        case .appLinks: "App Links"
        case .userDefaults: "User Defaults"
        case .currency: "Currency"
        case .exchangeRates: "Exchange Rates"
        case .dates: "Date Extensions"
        case .strings: "String Extensions"
        case .numbers: "Number Extensions"
        case .bundleInfo: "Bundle Information"
        case .debouncer: "Debouncer"
        case .applicationHelpers: "Application Helpers"
        case .itemDetailSource: "Item Detail Source"
        }
    }

    var summary: String {
        switch self {
        case .buttons: "Primary actions, loading states, close controls, and button chrome."
        case .settings: "Settings shells, rows, toggles, pickers, and theme customization."
        case .colorPicker: "Preset and custom color selection with explicit apply behavior."
        case .onboarding: "Cards, chips, progress, typography, and secondary actions."
        case .itemPicker: "Searchable single- and multi-selection lists with row actions."
        case .glass: "Materials, shapes, button emphasis, tint, interaction, and morphing."
        case .effects: "Atmospheric aura and glow background treatments."
        case .proBanner: "Reusable premium upgrade and thank-you states."
        case .alerts: "Alert, confirmation, action-sheet, and text-input presentation."
        case .captureAndMedia: "Live barcode scanning and photo-library selection."
        case .appearance: "Rounded UIKit and SwiftUI typography configuration."
        case .haptics: "Standardized impact and notification feedback."
        case .analytics: "Shared analytics event routing and logger integrations."
        case .logging: "Structured logging and Pulse inspection."
        case .appLinks: "Safe URL opening and application-link helpers."
        case .userDefaults: "Property-wrapper-backed preference storage."
        case .currency: "Currency metadata, formatting, and locale support."
        case .exchangeRates: "Exchange-rate fetching and conversion."
        case .dates: "Reusable date calculations and formatting helpers."
        case .strings: "Localization, validation, and string utilities."
        case .numbers: "Numeric formatting and conversion helpers."
        case .bundleInfo: "Typed access to application metadata."
        case .debouncer: "Async-safe control over rapidly repeated work."
        case .applicationHelpers: "UIKit application and safe-area conveniences."
        case .itemDetailSource: "Shareable text, URL, and image detail sources."
        }
    }

    var symbolName: String {
        switch self {
        case .buttons: "button.programmable"
        case .settings: "gearshape.2.fill"
        case .colorPicker: "paintpalette.fill"
        case .onboarding: "rectangle.stack.fill"
        case .itemPicker: "checklist"
        case .glass: "circle.hexagongrid.fill"
        case .effects: "sun.max.trianglebadge.exclamationmark.fill"
        case .proBanner: "sparkles"
        case .alerts: "exclamationmark.bubble.fill"
        case .captureAndMedia: "camera.viewfinder"
        case .appearance: "textformat"
        case .haptics: "waveform"
        case .analytics: "chart.xyaxis.line"
        case .logging: "text.alignleft"
        case .appLinks: "link"
        case .userDefaults: "switch.2"
        case .currency: "banknote.fill"
        case .exchangeRates: "arrow.left.arrow.right"
        case .dates: "calendar"
        case .strings: "textformat.abc"
        case .numbers: "number"
        case .bundleInfo: "shippingbox.fill"
        case .debouncer: "timer"
        case .applicationHelpers: "apps.iphone"
        case .itemDetailSource: "square.and.arrow.up"
        }
    }

    var tint: Color {
        switch section {
        case .components: .blue
        case .services: .purple
        case .foundation: .orange
        }
    }

    var apiNames: [String] {
        switch self {
        case .buttons: ["SFKButton", "SFKCloseButton"]
        case .settings: [
            "SFKSettingsScreen",
            "SFKSettingsRow",
            "SFKSettingsLabel",
            "SFKSettingsToggle",
            "SFKSettingsToggleRow",
            "SFKSettingsDatePickerRow",
            "SFKSettingsTimePickerRow",
            "SFKSettingsInlineDatePicker",
            "SFKSettingsPickerRow",
            "SFKSettingsPickerSheetRow",
            "SFKSettingsStepperRow",
            "SFKSettingsSliderRow",
            "SFKSettingsColorPickerRow",
            "SFKSettingsInlineColorPicker",
            "SFKSettingsLinkRow",
            "SFKSettingsDestructiveRow",
            "SFKSettingsConfirmationRow"
        ]
        case .colorPicker: ["SFKColorPickerSheet"]
        case .onboarding: ["SFKCard", "SFKSelectableChip", "SFKChipFlowLayout", "SFKSegmentedProgress", "SFKSecondaryButton", "SFKTypography"]
        case .itemPicker: ["SFKItemPickerView", "SFKItemPickerRow", "SFKItemPickerSection"]
        case .glass: ["sfkGlass", "SFKGlassStyle", "SFKGlassShape", "GlassEffectContainer"]
        case .effects: ["TopAuraBackground", "SFKAuraLayer", "SFKAuraGlowBackground"]
        case .proBanner: ["SFKProBannerView"]
        case .alerts: ["AlertController", "AlertPresenter"]
        case .captureAndMedia: ["BarcodeScannerScreen", "BarcodeScannerView", "PhotoPicker"]
        case .appearance: ["SFKAppearanceManager", "SFKRoundedHostingController"]
        case .haptics: ["HapticsHelper"]
        case .analytics: ["AnalyticsManager"]
        case .logging: ["Logger", "SFKPulseConsoleView"]
        case .appLinks: ["AppLinkOpener"]
        case .userDefaults: ["UserDefault"]
        case .currency: ["Currency"]
        case .exchangeRates: ["ExchangeRateManager"]
        case .dates: ["Date"]
        case .strings: ["String"]
        case .numbers: ["NumberFormatter"]
        case .bundleInfo: ["Bundle"]
        case .debouncer: ["Debouncer"]
        case .applicationHelpers: ["UIApplication", "UIViewController"]
        case .itemDetailSource: ["ItemDetailSource"]
        }
    }

    func matches(_ searchText: String) -> Bool {
        guard !searchText.isEmpty else { return true }
        let searchableText = ([title, summary, section.rawValue] + apiNames).joined(separator: " ")
        return searchableText.localizedCaseInsensitiveContains(searchText)
    }
}
