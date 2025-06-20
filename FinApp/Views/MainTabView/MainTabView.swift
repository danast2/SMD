//
//  MainTabView.swift
//  FinApp
//
//  Created by Даниил Дементьев on 15.06.2025.
//

import SwiftUI

struct MainTabView: View {

    @State private var selectedTab: TabType = .expenses

    init() {
        UITabBar.appearance().tintColor = UIColor(named: "NewAccentColor")
        UITabBar.appearance().unselectedItemTintColor = .gray
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            TransactionsListView(
                transactionsListViewModel: TransactionsListViewModel(
                    direction: .outcome,
                    transactionsService: TransactionsService()
                )
            )
            .tabItem {
                Label {
                    Text(TabType.expenses.title)
                } icon: {
                    TabType.expenses.icon
                }
            }
            .tag(TabType.expenses)

            TransactionsListView(
                transactionsListViewModel: TransactionsListViewModel(
                    direction: .income,
                    transactionsService: TransactionsService()
                )
            )
            .tabItem {
                Label {
                    Text(TabType.income.title)
                } icon: {
                    TabType.income.icon
                }
            }
            .tag(TabType.income)

            Text("Счет")
                .font(.largeTitle)
                .tabItem {
                    Label {
                        Text(TabType.account.title)
                    } icon: {
                        TabType.account.icon
                    }
                }
                .tag(TabType.account)

            Text("Статьи")
                .font(.largeTitle)
                .tabItem {
                    Label {
                        Text(TabType.items.title)
                    } icon: {
                        TabType.items.icon
                    }
                }
                .tag(TabType.items)

            Text("Настройки")
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
