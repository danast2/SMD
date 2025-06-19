//
//  MainTabView.swift
//  FinApp
//
//  Created by Даниил Дементьев on 15.06.2025.
//

import SwiftUI

struct MainTabView: View {
    enum TabType: Hashable {
        case expenses
        case income
        case account
        case items
        case settings
    }

    @State private var selectedTab: TabType = .expenses

    init() {
        UITabBar.appearance().tintColor = UIColor(named: "NewAccentColor")
        UITabBar.appearance().unselectedItemTintColor = .gray
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            TransactionsListView(
                transactionsListViewModel:
                    TransactionsListViewModel(direction: .outcome,
                                              transactionsService: TransactionsService()))
            .tabItem {
                Label {
                    Text("Расходы")
                } icon: {
                    Image("outcome")
                }
            }
            .tag(TabType.expenses)

            TransactionsListView(
                transactionsListViewModel:
                    TransactionsListViewModel(direction: .income,
                                              transactionsService: TransactionsService()))
            .tabItem {
                Label {
                    Text("Доходы")
                } icon: {
                    Image("income")
                }
            }
            .tag(TabType.income)

            account
                .tabItem {
                    Label {
                        Text("Счет")
                    } icon: {
                        Image("accounts")
                    }
                }
                .tag(TabType.account)

            items
                .tabItem {
                    Label {
                        Text("Статьи")
                    } icon: {
                        Image("items")
                    }
                }
                .tag(TabType.items)

            settings
                .tabItem {
                    Label {
                        Text("Настройки")
                    } icon: {
                        Image("settings")
                    }
                }
                .tag(TabType.settings)
        }
    }

    private var account: some View {
        Text("Счет")
            .font(.largeTitle)
    }

    private var items: some View {
        Text("Статьи")
            .font(.largeTitle)
    }

    private var settings: some View {
        Text("Настройки")
            .font(.largeTitle)
    }
}
