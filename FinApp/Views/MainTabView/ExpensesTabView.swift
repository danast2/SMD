//
//  ExpensesTabView.swift
//  FinApp
//
//  Created by Даниил Дементьев on 20.06.2025.
//

import SwiftUI

struct ExpensesTabView: View {
    var body: some View {
        TransactionsListView()
            .tabItem {
                Label {
                    Text(TabType.expenses.title)
                } icon: {
                    TabType.expenses.icon
                }
            }
    }
}
