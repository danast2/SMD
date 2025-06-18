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
            .toolbar { toolbar }
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
        Text("Ошибка: \(error.localizedDescription)")
            .multilineTextAlignment(.center)
            .padding()
            .frame(maxHeight: .infinity)
    }

    private var contentView: some View {
        VStack {
            headerView

            TotalCardView(totalAmount: transactionsListViewModel.totalAmount)

            Text("ОПЕРАЦИИ")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.top, 12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)

            List {
                ForEach(Array(
                    transactionsListViewModel.transactions.enumerated()),
                        id: \.element.id) { index, transaction in
                    TransactionRowView(
                        transaction: transaction,
                        direction: transactionsListViewModel.direction
                    )
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(
                        RoundedRectangle(cornerRadius: 16,
                                         style: .continuous)
                            .fill(Color.white)
                            .padding(.top, index == 0 ? 0 : -16)
                            .padding(.bottom,
                                     index == transactionsListViewModel.transactions.count - 1 ?
                                     0 : -16)
                            .clipShape(Rectangle())
                    )
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
        }
        .padding()
        .background(Color(.systemGray6).ignoresSafeArea())
    }

    private var headerView: some View {
        HStack {
            Text(
                transactionsListViewModel.direction == .outcome ?
                "Расходы сегодня" : "Доходы сегодня")
                .font(.largeTitle)
                .bold()
            Spacer()
        }
        .padding(.top, 16)
    }

    private var toolbar: some ToolbarContent {
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
