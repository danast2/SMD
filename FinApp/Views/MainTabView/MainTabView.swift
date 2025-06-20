//
//  MainTabView.swift
//  FinApp
//
//  Created by Даниил Дементьев on 15.06.2025.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: TabType = .expenses

    @StateObject private var outcomeVM = TransactionsListViewModel(
        direction: .outcome,
        transactionsService: TransactionsService()
    )

    @StateObject private var incomeVM = TransactionsListViewModel(
        direction: .income,
        transactionsService: TransactionsService()
    )

    init() {
        UITabBar.appearance().tintColor = UIColor(named: "NewAccentColor")
        UITabBar.appearance().unselectedItemTintColor = .gray
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            ExpensesTabView(viewModel: outcomeVM)
                .tag(TabType.expenses)

            IncomeTabView(viewModel: incomeVM)
                .tag(TabType.income)

            AccountTabView()
                .tag(TabType.account)

            ItemsTabView()
                .tag(TabType.items)

            SettingsTabView()
                .tag(TabType.settings)
        }
    }
}
