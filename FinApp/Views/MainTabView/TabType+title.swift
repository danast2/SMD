//
//  TabType+title.swift
//  FinApp
//
//  Created by Даниил Дементьев on 20.06.2025.
//

import SwiftUI

extension TabType {
    var title: String {
        switch self {
        case .expenses: return "Расходы"
        case .income: return "Доходы"
        case .account: return "Счет"
        case .items: return "Статьи"
        case .settings: return "Настройки"
        }
    }
}
