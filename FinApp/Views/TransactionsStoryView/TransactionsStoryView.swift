//
//  TransactionsStoryView.swift
//  FinApp
//
//  Created by Даниил Дементьев on 15.06.2025.
//

import SwiftUI

struct TransactionsStoryView: View {
    @EnvironmentObject private var viewModel: TransactionsStoryViewModel
    @State private var showAnalysis = false
    @State private var editingTransaction: Transaction?

    private let categoriesService: any CategoriesServiceProtocol
    private let bankAccountService: any BankAccountServiceProtocol

    init(
        categoriesService: any CategoriesServiceProtocol,
        bankAccountService: any BankAccountServiceProtocol
    ) {
        self.categoriesService = categoriesService
        self.bankAccountService = bankAccountService
    }

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                TransactionsStoryFilterCard()
                TransactionsStoryOperationsHeader()
                TransactionsStoryOperationsList { trx in
                    editingTransaction = trx
                }
            }
            .padding(.horizontal)
            .padding(.bottom)

            if let error = viewModel.error {
                Text("error.title".localized + ": \(error.localizedDescription)")
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(8)
            }
        }
        .sheet(isPresented: $showAnalysis) {
            AnalysisView(viewModel: viewModel)
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
        .navigationTitle("title.myHistory".localized)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button { showAnalysis = true } label: {
                    Image(systemName: "doc")
                        .foregroundColor(.indigo)
                }
            }
        }
        .background(Color(.systemGray6).ignoresSafeArea())
        .loading(viewModel.isLoading)
        .onAppear {
            Task { await viewModel.reloadData() }
        }
    }
}
