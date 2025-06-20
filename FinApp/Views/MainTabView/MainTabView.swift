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
            TransactionsListView(transactionsListViewModel: outcomeVM)
                .tabItem {
                    Label {
                        Text(TabType.expenses.title)
                    } icon: {
                        TabType.expenses.icon
                    }
                }
                .tag(TabType.expenses)

            TransactionsListView(transactionsListViewModel: incomeVM)
                .tabItem {
                    Label {
                        Text(TabType.income.title)
                    } icon: {
                        TabType.income.icon
                    }
                }
                .tag(TabType.income)

            Text(TabType.account.title)
                .font(.largeTitle)
                .tabItem {
                    Label {
                        Text(TabType.account.title)
                    } icon: {
                        TabType.account.icon
                    }
                }
                .tag(TabType.account)

            Text(TabType.items.title)
                .font(.largeTitle)
                .tabItem {
                    Label {
                        Text(TabType.items.title)
                    } icon: {
                        TabType.items.icon
                    }
                }
                .tag(TabType.items)

            Text(TabType.settings.title)
                .font(.largeTitle)
                .tabItem {
                    Label {
                        Text(TabType.settings.title)
                    } icon: {
                        TabType.settings.icon
                    }
                }
                .tag(TabType.settings)
        }
    }
}
