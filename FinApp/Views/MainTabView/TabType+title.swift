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
        case .expenses: return "tab.expenses".localized
        case .income: return "tab.income".localized
        case .account: return "tab.account".localized
        case .items: return "tab.items".localized
        case .settings: return "tab.settings".localized
        }
    }
}
