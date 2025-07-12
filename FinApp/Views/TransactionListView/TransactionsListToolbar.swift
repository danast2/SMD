//
//  TransactionsListToolbar.swift
//  FinApp
//
//  Created by Даниил Дементьев on 20.06.2025.
//

import SwiftUI

struct TransactionsListToolbar: ToolbarContent {
    let direction: Direction
    @EnvironmentObject var transactionsListViewModel: TransactionsListViewModel

    var body: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            NavigationLink(
                destination: TransactionsStoryView()
                    .environmentObject(
                        TransactionsStoryViewModel(
                            direction: direction,
                            transactionsService: transactionsListViewModel.transactionsService
                        )
                    )
            ) {
                Image(systemName: "clock")
                    .foregroundColor(.indigo)
            }
        }
    }
}
