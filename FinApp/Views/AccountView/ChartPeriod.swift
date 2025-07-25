//
//  ChartPeriod.swift
//  FinApp
//
//  Created by Даниил Дементьев on 26.07.2025.
//

import Foundation

enum ChartPeriod: String, CaseIterable, Identifiable {
    case day
    case month

    var id: String { rawValue }

    var title: String {
        switch self {
        case .day:   return NSLocalizedString("Дни", comment: "")
        case .month: return NSLocalizedString("Месяцы", comment: "")
        }
    }

    var length: Int {
        switch self {
        case .day:   return 30
        case .month: return 24
        }
    }

    var calendarComponent: Calendar.Component {
        switch self {
        case .day:   return .day
        case .month: return .month
        }
    }
}
