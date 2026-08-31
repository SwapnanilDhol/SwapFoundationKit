/*****************************************************************************
 * Currency.swift
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

public enum Currency: String, CaseIterable, Hashable, Codable, Sendable {

    public var id: String { rawValue }

    case AUD
    case INR
    case TRY
    case BGN
    case ISK
    case USD
    case BRL
    case JPY
    case ZAR
    case CAD
    case KRW
    case CHF
    case MXN
    case CNY
    case MYR
    case CZK
    case NOK
    case DKK
    case NZD
    case EUR
    case PHP
    case GBP
    case PLN
    case HKD
    case RON
    case HRK
    case RUB
    case HUF
    case SEK
    case IDR
    case SGD
    case ILS
    case THB
    case BWP
    case MUR
    case ARS
    case LKR
    case AED
    case TWD
    case VND
    case PKR
    case BDT
    case COP
    case CLP
    case PEN
    case EGP
    case QAR
    case KWD
    case OMR
    case BHD
    case JOD
    case MAD
    case KES
    case GHS
    case UAH
    case SAR
    case NGN
    case RSD

    public var description: LocalizedStringResource {
        switch self {
        case .EUR:
            return "Euro"
        case .USD:
            return "US Dollar"
        case .JPY:
            return "Japanese Yen"
        case .BGN:
            return "Bulgarian Lev"
        case .CZK:
            return "Czech koruna"
        case .DKK:
            return "Danish krone"
        case .GBP:
            return "Pound Sterling"
        case .HUF:
            return "Hungarian forint"
        case .PLN:
            return "Polish zloty"
        case .RON:
            return "Romanian Leu"
        case .SEK:
            return "Swedish krona"
        case .CHF:
            return "Swiss franc"
        case .ISK:
            return "Icelandic krona"
        case .NOK:
            return "Norwegian krone"
        case .HRK:
            return "Croatian kuna"
        case .RUB:
            return "Russian rouble"
        case .TRY:
            return "Turkish lira"
        case .AUD:
            return "Australian dollar"
        case .BRL:
            return "Brazilian real"
        case .CAD:
            return "Canadian dollar"
        case .CNY:
            return "Chinese yuan renminbi"
        case .HKD:
            return "Hong Kong dollar"
        case .IDR:
            return "Indonesian rupiah"
        case .ILS:
            return "Israeli shekel"
        case .INR:
            return "Indian rupee"
        case .KRW:
            return "South Korean won"
        case .MXN:
            return "Mexican peso"
        case .MYR:
            return "Malaysian ringgit"
        case .NZD:
            return "New Zealand dollar"
        case .PHP:
            return "Philippine peso"
        case .SGD:
            return "Singapore dollar"
        case .THB:
            return "Thai baht"
        case .ZAR:
            return "South African rand"
        case .BWP:
            return "Botswana pula"
        case .MUR:
            return "Mauritian Rupees"
        case .ARS:
            return "Argentine peso"
        case .LKR:
            return "Sri Lankan Rupee"
        case .AED:
            return "UAE Dirham"
        case .TWD:
            return "New Taiwan dollar"
        case .VND:
            return "Vietnamese dong"
        case .PKR:
            return "Pakistani rupee"
        case .BDT:
            return "Bangladeshi taka"
        case .COP:
            return "Colombian peso"
        case .CLP:
            return "Chilean peso"
        case .PEN:
            return "Peruvian sol"
        case .EGP:
            return "Egyptian pound"
        case .QAR:
            return "Qatari riyal"
        case .KWD:
            return "Kuwaiti dinar"
        case .OMR:
            return "Omani rial"
        case .BHD:
            return "Bahraini dinar"
        case .JOD:
            return "Jordanian dinar"
        case .MAD:
            return "Moroccan dirham"
        case .KES:
            return "Kenyan shilling"
        case .GHS:
            return "Ghanaian cedi"
        case .UAH:
            return "Ukrainian hryvnia"
        case .SAR:
            return "Saudi Riyal"
        case .NGN:
            return "Nigerian naira"
        case .RSD:
            return "Serbian dinar"
        }
    }

    public var symbol: String {
        switch self {
        case .AUD:
            return "🇦🇺"
        case .INR:
            return "🇮🇳"
        case .TRY:
            return "🇹🇷"
        case .BGN:
            return "🇧🇬"
        case .ISK:
            return "🇮🇸"
        case .USD:
            return "🇺🇸"
        case .BRL:
            return "🇧🇷"
        case .JPY:
            return "🇯🇵"
        case .ZAR:
            return "🇿🇦"
        case .CAD:
            return "🇨🇦"
        case .KRW:
            return "🇰🇷"
        case .CHF:
            return "🇨🇭"
        case .MXN:
            return "🇲🇽"
        case .CNY:
            return "🇨🇳"
        case .MYR :
            return "🇲🇾"
        case .CZK:
            return "🇨🇿"
        case .NOK:
            return "🇳🇴"
        case .DKK:
            return "🇩🇰"
        case .NZD:
            return "🇳🇿"
        case .EUR:
            return "🇪🇺"
        case .PHP:
            return "🇵🇭"
        case .GBP:
            return "🇬🇧"
        case .PLN:
            return "🇵🇱"
        case .HKD :
            return "🇭🇰"
        case .RON:
            return "🇷🇴"
        case .HRK:
            return "🇭🇷"
        case .RUB:
            return "🇷🇺"
        case .HUF:
            return "🇭🇺"
        case .SEK:
            return "🇸🇪"
        case .IDR:
            return "🇮🇩"
        case .SGD:
            return "🇸🇬"
        case .ILS:
            return "🇮🇱"
        case .THB:
            return "🇹🇭"
        case .BWP:
            return "🇧🇼"
        case .MUR:
            return "🇲🇺"
        case .ARS:
            return "🇦🇷"
        case .LKR:
            return "🇱🇰"
        case .AED:
            return "🇦🇪"
        case .TWD:
            return "🇹🇼"
        case .VND:
            return "🇻🇳"
        case .PKR:
            return "🇵🇰"
        case .BDT:
            return "🇧🇩"
        case .COP:
            return "🇨🇴"
        case .CLP:
            return "🇨🇱"
        case .PEN:
            return "🇵🇪"
        case .EGP:
            return "🇪🇬"
        case .QAR:
            return "🇶🇦"
        case .KWD:
            return "🇰🇼"
        case .OMR:
            return "🇴🇲"
        case .BHD:
            return "🇧🇭"
        case .JOD:
            return "🇯🇴"
        case .MAD:
            return "🇲🇦"
        case .KES:
            return "🇰🇪"
        case .GHS:
            return "🇬🇭"
        case .UAH:
            return "🇺🇦"
        case .SAR:
            return "🇸🇦"
        case .NGN:
            return "🇳🇬"
        case .RSD:
            return "🇷🇸"
        }
    }

    public var currencySymbol: String {
        switch self {
        case .AUD:
            return "A$"
        case .INR:
            return "₹"
        case .TRY:
            return "₺"
        case .BGN:
            return "лв."
        case .ISK:
            return "ISK"
        case .USD:
            return "$"
        case .BRL:
            return "R$"
        case .JPY:
            return "¥"
        case .ZAR:
            return "ZAR"
        case .CAD:
            return "CA$"
        case .KRW:
            return "₩"
        case .CHF:
            return "CHF"
        case .MXN:
            return "MX$"
        case .CNY:
            return "CN¥"
        case .MYR:
            return "MYR"
        case .CZK:
            return "CZK"
        case .NOK:
            return "kr"
        case .DKK:
            return "DKK"
        case .NZD:
            return "NZ$"
        case .EUR:
            return "€"
        case .PHP:
            return "₱"
        case .GBP:
            return "£"
        case .PLN:
            return "zł"
        case .HKD:
            return "HK$"
        case .RON:
            return "RON"
        case .HRK:
            return "kn"
        case .RUB:
            return "₽"
        case .HUF:
            return "Ft"
        case .SEK:
            return "Skr"
        case .IDR:
            return "Rp"
        case .SGD:
            return "SGD"
        case .ILS:
            return "₪"
        case .THB:
            return "฿"
        case .BWP:
            return "P"
        case .MUR:
            return "Rs"
        case .ARS:
            return "$"
        case .LKR:
            return "Rs"
        case .AED:
            return "AED"
        case .TWD:
            return "NT$"
        case .VND:
            return "₫"
        case .PKR:
            return "₨"
        case .BDT:
            return "৳"
        case .COP:
            return "COL$"
        case .CLP:
            return "CLP$"
        case .PEN:
            return "S/"
        case .EGP:
            return "E£"
        case .QAR:
            return "ر.ق"
        case .KWD:
            return "د.ك"
        case .OMR:
            return "ر.ع."
        case .BHD:
            return ".د.ب"
        case .JOD:
            return "د.ا"
        case .MAD:
            return "د.م."
        case .KES:
            return "KSh"
        case .GHS:
            return "GH₵"
        case .UAH:
            return "₴"
        case .SAR:
            return "﷼"
        case .NGN:
            return "₦"
        case .RSD:
            return "дин."
        }
    }
}

// Wrapper for concurrency-safe access
public struct CurrencyRates: @unchecked Sendable {
    let rates: [Currency: Double]
}

extension Currency {
    public static let fallBackExchangeRates = CurrencyRates(rates: [
        .EUR: 1.0,
        .USD: 1.08,
        .GBP: 0.85,
        .JPY: 163.0,
        .INR: 90.0,
        .AUD: 1.63,
        .CAD: 1.47,
        .CHF: 0.96,
        .CNY: 7.80,
        .HKD: 8.45,
        .SGD: 1.45,
        .NZD: 1.77,
        .SEK: 11.45,
        .NOK: 11.65,
        .DKK: 7.46,
        .PLN: 4.35,
        .CZK: 24.8,
        .HUF: 390.0,
        .RON: 4.97,
        .BGN: 1.96,
        .HRK: 7.53,
        .RUB: 97.0,
        .TRY: 35.1,
        .BRL: 5.80,
        .ZAR: 19.8,
        .MXN: 19.8,
        .MYR: 5.10,
        .IDR: 17500.0,
        .PHP: 62.0,
        .ILS: 3.95,
        .ISK: 150.0,
        .KRW: 1480.0,
        .THB: 39.0,
        .BWP: 14.5,
        .MUR: 50.0,
        .ARS: 950.0,
        .LKR: 330.0,
        .AED: 3.97,
        // Manual fallbacks: ECB daily XML does not publish these rates.
        .TWD: 34.8,
        .VND: 30000.0,
        .PKR: 320.0,
        .BDT: 140.0,
        .COP: 4700.0,
        .CLP: 1050.0,
        .PEN: 3.75,
        .EGP: 57.0,
        .QAR: 3.93,
        .KWD: 0.33,
        .OMR: 0.42,
        .BHD: 0.42,
        .JOD: 0.77,
        .MAD: 10.7,
        .KES: 150.0,
        .GHS: 12.5,
        .UAH: 48.0,
        // Manual fallback: ECB daily XML does not publish a SAR rate.
        .SAR: 4.05,
        // Manual fallback: ECB daily XML does not publish an NGN rate.
        .NGN: 1570.66,
        // Manual fallback: ECB daily XML does not publish an RSD rate.
        .RSD: 117.3717
    ])
}

// MARK: - SFKPickableItem Conformance

extension Currency: SFKPickableItem {
    public var pickableItemId: String { rawValue }

    public var pickableItemIconKind: SFKPickableItemIconKind {
        .text(text: symbol)
    }

    public var pickableItemTitle: String { rawValue }

    public var pickableItemSubtitle: String? {
        String(localized: String.LocalizationValue(description.key))
    }
}

// MARK: - Sorting

extension Currency {
    /// Returns all currency cases sorted alphabetically by their display name.
    public static var sortedAllCases: [Currency] {
        allCases.sorted {
            String(localized: String.LocalizationValue($0.description.key))
                .localizedCaseInsensitiveCompare(
                    String(localized: String.LocalizationValue($1.description.key))
                ) == .orderedAscending
        }
    }

    /// Returns currencies sorted with the user's local currency first,
    /// followed by major currencies (USD, EUR, GBP, JPY, AUD), then the rest.
    public static var sortedWithMajorFirst: [Currency] {
        let majorCurrencies: Set<Currency> = [.USD, .EUR, .GBP, .JPY, .AUD]
        let localCurrencyCode = Locale.current.currency?.identifier ?? ""

        return sortedAllCases.sorted { lhs, rhs in
            let lhsIsLocal = lhs.rawValue == localCurrencyCode
            let rhsIsLocal = rhs.rawValue == localCurrencyCode

            if lhsIsLocal { return true }
            if rhsIsLocal { return false }

            switch (majorCurrencies.contains(lhs), majorCurrencies.contains(rhs)) {
            case (true, false): return true
            case (false, true): return false
            default:
                let lhsName = String(localized: String.LocalizationValue(lhs.description.key))
                let rhsName = String(localized: String.LocalizationValue(rhs.description.key))
                return lhsName < rhsName
            }
        }
    }

    /// Detects the user's local currency from the current locale.
    /// Falls back to USD if no currency code is set.
    public static var local: Currency {
        guard let code = Locale.current.currency?.identifier else { return .USD }
        return Currency(rawValue: code) ?? .USD
    }
}

// MARK: - Formatting

extension Currency {
    /// Formats an amount with the currency symbol and proper fraction digits.
    /// - Parameter amount: The amount to format.
    /// - Returns: A formatted string (e.g., "₹1,234.56").
    public func formatAmount(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = currencySymbol
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: amount)) ?? "\(currencySymbol)\(amount)"
    }

    /// Formats an amount with abbreviated notation for large numbers.
    /// - Parameter amount: The amount to format.
    /// - Returns: A compact string (e.g., "₹1.2K", "₹3.4M").
    public func formatAbbreviated(_ amount: Double) -> String {
        let absAmount = abs(amount)
        let sign = amount < 0 ? "-" : ""

        switch absAmount {
        case 1_000_000_000...:
            return "\(sign)\(currencySymbol)\(String(format: "%.1f", absAmount / 1_000_000_000))B"
        case 1_000_000...:
            return "\(sign)\(currencySymbol)\(String(format: "%.1f", absAmount / 1_000_000))M"
        case 1_000...:
            return "\(sign)\(currencySymbol)\(String(format: "%.1f", absAmount / 1_000))K"
        default:
            return formatAmount(amount)
        }
    }
}
