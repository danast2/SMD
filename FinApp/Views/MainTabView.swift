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

    var body: some View {
        TabView(selection: $selectedTab) {
            TransactionsListView(direction: .outcome)
                .tabItem {
                    Label("Расходы", systemImage: "arrow.down")
                }
                .tag(TabType.expenses)

            TransactionsListView(direction: .income)
                .tabItem {
                    Label("Доходы", systemImage: "arrow.up")
                }
                .tag(TabType.income)

            account
                .tabItem {
                    Label("Счет", systemImage: "creditcard")
                }
                .tag(TabType.account)

            items
                .tabItem {
                    Label("Статьи", systemImage: "list.bullet")
                }
                .tag(TabType.items)

            settings
                .tabItem {
                    Label("Настройки", systemImage: "gear")
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
        Text("Настройки ")
            .font(.largeTitle)
    }
}

// Вью-заглушка для табов
struct PlaceholderView: View {
    let title: String
    let icon: String

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: icon)
                    .font(.system(size: 50))
                    .foregroundColor(Color("AccentColor"))

                Text(title)
                    .font(.title2.bold())
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
