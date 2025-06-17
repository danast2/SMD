//
//  TransactionsListView.swift
//  FinApp
//
//  Created by Даниил Дементьев on 15.06.2025.
//

import SwiftUI

struct TransactionsListView: View {
    @ObservedObject var transactionsListViewModel: TransactionsListViewModel

    var body: some View {
        NavigationView {
            Group {
                if transactionsListViewModel.isLoading {
                    loadingView
                } else if let error = transactionsListViewModel.error {
                    errorView(error)
                } else {
                    contentView
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(transactionsListViewModel.direction == .income ? "Доходы сегодня" : "Расходы сегодня")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbarItems }
        }
        .onAppear {
            transactionsListViewModel.loadTransactionsForListView()
        }
    }

    private var loadingView: some View {
        ProgressView()
            .frame(maxHeight: .infinity)
    }

    private func errorView(_ error: Error) -> some View {
        Text("Error: \(error.localizedDescription)")
            .frame(maxHeight: .infinity)
    }

    private var contentView: some View {
        List {
            Section {
                TotalCardView(totalAmount: transactionsListViewModel.totalAmount)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color(.systemBackground))
            }

            Section(header: Text("ОПЕРАЦИИ")
                .font(.system(size: 13))
                .foregroundColor(.gray)
            ) {
                ForEach(transactionsListViewModel.transactions) { transaction in
                    TransactionRow(
                        transaction: transaction,
                        direction: transactionsListViewModel.direction
                    )
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color(.systemBackground))
                }
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(Color(.systemGroupedBackground))
    }

    private var toolbarItems: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            NavigationLink(
                destination: TransactionsStoryView(
                    transactionsStoryViewModel: TransactionsStoryViewModel(
                        direction: transactionsListViewModel.direction,
                        transactionsService: TransactionsService()
                    )
                )
            ) {
                Image(systemName: "clock")
                    .foregroundColor(.black)
            }
        }
    }
}

struct TransactionRow: View {
    let transaction: Transaction
    let direction: Direction

    var body: some View {
        HStack(spacing: 12) {
            Text(String(transaction.category.emoji))
                .font(.system(size: 17))

            VStack(alignment: .leading, spacing: 2) {
                Text(transaction.category.name)
                    .font(.system(size: 17))
                    .foregroundColor(.primary)

                if let comment = transaction.comment, !comment.isEmpty {
                    Text(comment)
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                }
            }

            Spacer()

            Text(transaction.amount.formatted(.currency(code: "RUB")))
                .font(.system(size: 17))
                .foregroundColor(.black)
        }
        .padding(.vertical, 12)
    }
}

struct TotalCardView: View {
    let totalAmount: Decimal

    var body: some View {
        HStack {
            Text(String("Всего"))
                .font(.system(size: 17))

            Spacer()

            VStack(alignment: .leading, spacing: 4) {
                Text(totalAmount.formatted(.currency(code: "RUB")))
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(.primary)
            }
        }
        .padding(.vertical, 12)
    }
}
