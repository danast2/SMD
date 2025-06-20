//
//  TransactionsStoryOperationsList.swift
//  FinApp
//
//  Created by Даниил Дементьев on 20.06.2025.
//

import SwiftUI

struct TransactionsStoryOperationsList: View {
    @ObservedObject var viewModel: TransactionsStoryViewModel

    var body: some View {
        List {
            ForEach(Array(viewModel.sortedTransactions.enumerated()), id: \.element.id) { index, transaction in
                TransactionRowView(
                    transaction: transaction,
                    direction: viewModel.direction
                )
                .listRowInsets(EdgeInsets())
                .listRowBackground(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.white)
                        .padding(.top, index == 0 ? 0 : -16)
                        .padding(.bottom, index == viewModel.sortedTransactions.count - 1 ? 0 : -16)
                        .clipShape(Rectangle())
                )
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Color(.systemGray6))
    }
}
