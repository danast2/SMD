//
//  TransactionsListLoadedView.swift
//  FinApp
//
//  Created by Даниил Дементьев on 20.06.2025.
//

import SwiftUI

struct TransactionsListLoadedView: View {
    @ObservedObject var viewModel: TransactionsListViewModel

    var body: some View {
        VStack {
            TransactionsListHeader(direction: viewModel.direction)

            TotalCardView(totalAmount: viewModel.totalAmount)

            Text("title.operations".localized)
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.top, 12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)

            List {
                ForEach(Array(viewModel.transactions.enumerated()), id: \.element.id) { index, transaction in
                    TransactionRowView(transaction: transaction, direction: viewModel.direction)
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color.white)
                                .padding(.top, index == 0 ? 0 : -16)
                                .padding(.bottom, index == viewModel.transactions.count - 1 ? 0 : -16)
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
}
