//
//  TransactionsListView.swift
//  FinApp
//
//  Created by Даниил Дементьев on 15.06.2025.
//

import SwiftUI

struct TransactionsListView: View {
    @EnvironmentObject var transactionsListViewModel: TransactionsListViewModel

    var body: some View {
        NavigationView {
            TransactionsListContentView()
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    TransactionsListToolbar(direction: transactionsListViewModel.direction)
                }
        }
        .onAppear {
            transactionsListViewModel.loadTransactionsForListView()
        }
    }
}
