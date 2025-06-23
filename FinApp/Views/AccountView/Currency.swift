//
//  Currency.swift
//  FinApp
//
//  Created by Даниил Дементьев on 23.06.2025.
//

enum Currency: String, CaseIterable, Identifiable {
    case rub = "RUB"
    case usd = "USD"
    case eur = "EUR"

    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .rub: return "₽"
        case .usd: return "$"
        case .eur: return "€"
        }
    }

    var title: String {
        switch self {
        case .rub: return "currency.rub".localized
        case .usd: return "currency.usd".localized
        case .eur: return "currency.eur".localized
        }
    }

    var displayTitle: String {
        return "\(title) \(symbol)"
    }
}
