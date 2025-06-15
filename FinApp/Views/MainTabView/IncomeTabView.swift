//
//  IncomeTabView.swift
//  FinApp
//
//  Created by Даниил Дементьев on 20.06.2025.
//

import SwiftUI

struct IncomeTabView: View {
    var body: some View {
        TransactionsListView()
            .tabItem {
                Label {
                    Text(TabType.income.title)
                } icon: {
                    TabType.income.icon
                }
            }
    }
}
