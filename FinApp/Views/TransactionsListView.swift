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
            VStack {
                if transactionsListViewModel.isLoading {
                    ProgressView()
                } else if let error = transactionsListViewModel.error {
                    Text("Error: \(error.localizedDescription)")
                } else {
                    VStack {
                        Text(transactionsListViewModel.totalAmount.formatted(
                            .currency(code: "RUB")))
                        .font(.largeTitle)
                    }
                    .padding()

                    List(transactionsListViewModel.transactions) { transaction in
                        HStack {
                            Text(String(transaction.category.emoji))
                                .font(.largeTitle)
                                .padding(.trailing, 8)

                            VStack(alignment: .leading) {
                                Text(transaction.category.name)
                                    .font(.headline)

                                if let comment = transaction.comment, !comment.isEmpty {
                                    Text(comment)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                            }

                            Spacer()

                            Text(transaction.amount.formatted(
                                .currency(code: transaction.account.currency)))
                            .foregroundColor(
                                transactionsListViewModel.direction == .income ?
                                    .green : .red)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle(
                transactionsListViewModel.direction == .income ?
                "Доходы сегодня" : "Расходы сегодня")
            .toolbar {
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
                    }
                }
            }
        }
        .onAppear {
            transactionsListViewModel.loadTransactionsForListView()
        }
    }
}
