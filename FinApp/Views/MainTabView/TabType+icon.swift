//
//  TabType+icon.swift
//  FinApp
//
//  Created by Даниил Дементьев on 20.06.2025.
//

import SwiftUI

extension TabType {
    var icon: Image {
        switch self {
        case .expenses: return Image("outcome")
        case .income: return Image("income")
        case .account: return Image("accounts")
        case .items: return Image("items")
        case .settings: return Image("settings")
        }
    }
}
