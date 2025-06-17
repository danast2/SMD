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
        VStack(spacing: 0) {
            HStack {
                Text(transactionsListViewModel.direction == .income ? "Доходы сегодня" : "Расходы сегодня")
                    .font(.system(size: 34, weight: .bold))
                Spacer()
            }
            .padding(.top, 20)
            .padding(.horizontal)

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
                        TransactionRowView(
                            transaction: transaction,
                            direction: transactionsListViewModel.direction
                        )
                        .listRowBackground(Color(.systemBackground))
                    }
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(Color(.systemGroupedBackground))
        }
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
