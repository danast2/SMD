//
//  IncomeTabView.swift
//  FinApp
//
//  Created by Даниил Дементьев on 20.06.2025.
//

import SwiftUI

struct IncomeTabView: View {

    private let categoriesService: any CategoriesServiceProtocol
    private let bankAccountService: any BankAccountServiceProtocol

    init(
        categoriesService: any CategoriesServiceProtocol,
        bankAccountService: any BankAccountServiceProtocol
    ) {
        self.categoriesService  = categoriesService
        self.bankAccountService = bankAccountService
    }

    var body: some View {
        TransactionsListView(
            categoriesService: categoriesService,
            bankAccountService: bankAccountService
        )
        .tabItem {
            Label {
                Text(TabType.income.title)
            } icon: {
                TabType.income.icon
            }
        }
    }
}
