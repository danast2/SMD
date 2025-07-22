//
//  TransactionsListToolbar.swift
//  FinApp
//
//  Created by Даниил Дементьев on 20.06.2025.
//

import SwiftUI

struct TransactionsListToolbar: ToolbarContent {
    let direction: Direction
    let categoriesService: any CategoriesServiceProtocol
    let bankAccountService: any BankAccountServiceProtocol

    @EnvironmentObject private var listVM: TransactionsListViewModel

    var body: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            NavigationLink {
                TransactionsStoryView(
                    categoriesService: categoriesService,
                    bankAccountService: bankAccountService
                )
                .environmentObject(
                    TransactionsStoryViewModel(
                        direction: direction,
                        transactionsService: listVM.transactionsService
                    )
                )
            } label: {
                Image(systemName: "clock")
                    .foregroundColor(.indigo)
            }
        }
    }
}
