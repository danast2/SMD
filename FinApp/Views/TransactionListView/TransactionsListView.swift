//
//  TransactionsListView.swift
//  FinApp
//
//  Created by Даниил Дементьев on 15.06.2025.
//

import SwiftUI

struct TransactionsListView: View {

    @EnvironmentObject private var viewModel: TransactionsListViewModel

    @State private var isPresentingCreateForm = false
    @State private var editingTransaction: Transaction?

    private let categoriesService: any CategoriesServiceProtocol
    private let bankAccountService: any BankAccountServiceProtocol

    init(
        categoriesService: any CategoriesServiceProtocol,
        bankAccountService: any BankAccountServiceProtocol
    ) {
        self.categoriesService   = categoriesService
        self.bankAccountService  = bankAccountService
    }

    var body: some View {
        NavigationView {
            ZStack {
                TransactionsListContentView { trx in
                    editingTransaction = trx
                }
                .environmentObject(viewModel)

                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        FloatingActionButton { isPresentingCreateForm = true }
                            .padding(.trailing, 20)
                            .padding(.bottom)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                TransactionsListToolbar(direction: viewModel.direction)
            }
            .alert("Ошибка", isPresented: .constant(viewModel.error != nil), presenting: viewModel.error) { _ in
                Button("OK", role: .cancel) { }
            } message: { error in
                Text(error.localizedDescription)
            }
            .fullScreenCover(isPresented: $isPresentingCreateForm) {
                TransactionFormView(
                    mode: .create,
                    direction: viewModel.direction,
                    transactionsService: viewModel.transactionsService,
                    bankAccountService: bankAccountService,
                    categoriesService: categoriesService
                )
                .environmentObject(viewModel)
            }
            .fullScreenCover(item: $editingTransaction) { trx in
                TransactionFormView(
                    mode: .edit,
                    transaction: trx,
                    direction: viewModel.direction,
                    transactionsService: viewModel.transactionsService,
                    bankAccountService: bankAccountService,
                    categoriesService: categoriesService
                )
                .environmentObject(viewModel)
            }
        }
        .loading(viewModel.isLoading)
    }
}
