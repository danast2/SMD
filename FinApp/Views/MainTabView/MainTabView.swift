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

    @StateObject private var accountVM = BankAccountViewModel(
        service: BankAccountServiceMock()
    )

    @StateObject private var categoriesVM = CategoriesViewModel(
        service: CategoriesService()
    )

    init() {
        UITabBar.appearance().tintColor = UIColor(named: "NewAccentColor")
        UITabBar.appearance().unselectedItemTintColor = .gray
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            ExpensesTabView()
                .environmentObject(outcomeVM)
                .tag(TabType.expenses)

            IncomeTabView()
                .environmentObject(incomeVM)
                .tag(TabType.income)

            AccountTabView()
                .environmentObject(accountVM)
                .tag(TabType.account)

            ItemsTabView()
                .environmentObject(categoriesVM)
                .tag(TabType.items)

            SettingsTabView()
                .tag(TabType.settings)
        }
        .tint(Color("NewAccentColor"))
    }
}
