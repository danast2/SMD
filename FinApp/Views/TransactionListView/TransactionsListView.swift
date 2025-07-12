//
//  TransactionsListView.swift
//  FinApp
//
//  Created by Даниил Дементьев on 15.06.2025.
//

import SwiftUI

struct TransactionsListView: View {
    @EnvironmentObject var transactionsListViewModel: TransactionsListViewModel

    @State private var isPresentingCreateForm = false
    @State private var editingTransaction: Transaction?

    var body: some View {
        NavigationView {
            ZStack {
                TransactionsListContentView(onSelect: { transaction in
                    editingTransaction = transaction
                })
                .environmentObject(transactionsListViewModel)

                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        FloatingActionButton {
                            isPresentingCreateForm = true
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                TransactionsListToolbar(direction: transactionsListViewModel.direction)
            }
            .fullScreenCover(isPresented: $isPresentingCreateForm) {
                TransactionFormView(
                    mode: .create,
                    direction: transactionsListViewModel.direction,
                    transactionsService: transactionsListViewModel.transactionsService,
                    bankAccountService: BankAccountServiceMock()
                )
                .environmentObject(transactionsListViewModel)
            }
            .fullScreenCover(item: $editingTransaction) { transaction in
                TransactionFormView(
                    mode: .edit,
                    transaction: transaction,
                    direction: transactionsListViewModel.direction,
                    transactionsService: transactionsListViewModel.transactionsService,
                    bankAccountService: BankAccountServiceMock()
                )
                .environmentObject(transactionsListViewModel)
            }
        }
        .onAppear {
            transactionsListViewModel.loadTransactionsForListView()
        }
    }
}
