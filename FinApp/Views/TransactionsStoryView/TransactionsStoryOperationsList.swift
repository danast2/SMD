//
//  TransactionsStoryOperationsList.swift
//  FinApp
//
//  Created by Даниил Дементьев on 20.06.2025.
//

import SwiftUI

struct TransactionsStoryOperationsList: View {
    @EnvironmentObject var viewModel: TransactionsStoryViewModel
    let onSelect: (Transaction) -> Void

    var body: some View {
        List {
            ForEach(Array(viewModel.sortedTransactions.enumerated()),
                    id: \.element.id) { index, transaction in
                TransactionRowView(
                    transaction: transaction,
                    direction: viewModel.direction,
                    onTap: { onSelect(transaction) }
                )
                .listRowInsets(EdgeInsets())
                .listRowBackground(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.white)
                        .padding(.top, index == 0 ? 0 : -16)
                        .padding(.bottom, index == viewModel.sortedTransactions.count - 1 ? 0 : -16)
                        .clipShape(Rectangle())
                )
                .listRowSeparator(
                    (index == 0 || index == viewModel.sortedTransactions.count - 1)
                    ? .hidden
                    : .visible,
                    edges: index == 0
                    ? .top
                    : index == viewModel.sortedTransactions.count - 1
                    ? .bottom
                    : .all
                )
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Color(.systemGray6))
    }
}
