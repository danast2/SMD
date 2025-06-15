//
//  TransactionsListView.swift
//  FinApp
//
//  Created by Даниил Дементьев on 15.06.2025.
//

import SwiftUI

struct TransactionsListView: View {
    let direction: Direction
    @State private var transactions: [Transaction] = []
    @State private var totalAmount: Decimal = 0
    @State private var isLoading = false
    @State private var error: Error?

    private let transactionsService = TransactionsService()

    var body: some View {
        VStack {
            if isLoading {
                ProgressView()
            } else if let error = error {
                Text("Error: \(error.localizedDescription)")
            } else {
                VStack {
                    Text(direction == .income ? "Доходы" : "Расходы")
                        .font(.headline)
                    Text("\(totalAmount.formatted(.currency(code: "RUB")))")
                        .font(.largeTitle)
                }
                .padding()
                List(transactions) { transaction in
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
                        .foregroundColor(direction == .income ? .green : .red)
                    }
                }
                .listStyle(.plain)
            }
        }
        .task {
            isLoading = true
            error = nil

            do {
                let calendar = Calendar.current
                let today = calendar.startOfDay(for: Date())
                let endOfDay = calendar.date(byAdding: .day, value: 1, to: today)

                let allTransactions = try await transactionsService
                    .fetchTransactions(from:
                                        today,
                                       to:
                                        endOfDay ?? today)

                transactions = allTransactions.filter { $0.category.direction == direction }
                totalAmount = transactions.reduce(0) { $0 + $1.amount }
            } catch {
                self.error = error
            }

            isLoading = false
        }
    }
}

struct TransactionsListView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            TransactionsListView(direction: .income)
                .previewDisplayName("Доходы сегодня")

            TransactionsListView(direction: .outcome)
                .previewDisplayName("Расходы сегодня")
        }
    }
}
