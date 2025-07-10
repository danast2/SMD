//
//  TransactionsListLoadedView.swift
//  FinApp
//
//  Created by Даниил Дементьев on 20.06.2025.
//

import SwiftUI

struct TransactionsListLoadedView: View {
    @EnvironmentObject var viewModel: TransactionsListViewModel
    let onSelect: (Transaction) -> Void

    var body: some View {
        VStack {
            TransactionsListHeader(direction: viewModel.direction)

            TotalCardView(totalAmount: viewModel.totalAmount)

            Text("title.operations".localized)
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.top, 12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 10)

            let items = viewModel.transactions
            List {
                ForEach(Array(items.enumerated()), id: \.element.id) { index, transaction in
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
                            .padding(.bottom, index == items.count - 1 ? 0 : -16)
                            .clipShape(Rectangle())
                    )
                    .listRowSeparator(
                        items.count == 1
                        ? .hidden
                        : index == 0
                        ? .hidden
                        : index == items.count - 1
                        ? .hidden
                        : .visible,
                        edges: items.count == 1
                        ? .all
                        : index == 0
                        ? .top
                        : index == items.count - 1
                        ? .bottom
                        : .all
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
