//
//  TransactionListViewModel.swift
//  FinApp
//
//  Created by Даниил Дементьев on 17.06.2025.
//

import Foundation

@MainActor
class TransactionsListViewModel: ObservableObject {

    let direction: Direction
    private let transactionsService: TransactionsService

    @Published var transactions: [Transaction] = []
    @Published var totalAmount: Decimal = 0
    @Published var isLoading = false
    @Published var error: Error?

    init(direction: Direction, transactionsService: TransactionsService) {
        self.direction = direction
        self.transactionsService = transactionsService
    }

    func loadTransactionsForListView() {
        Task {
            isLoading = true
            error = nil

            do {
                let calendar = Calendar.current
                let today = calendar.startOfDay(for: Date())
                let endOfDay = calendar.date(
                    bySettingHour: 23,
                    minute: 59,
                    second: 59,
                    of: today
                ) ?? today

                let all = try await transactionsService
                    .fetchTransactions(from: today, to: endOfDay)

                let related = all.filter { $0.category.direction == direction }
                transactions = related
                totalAmount = related.reduce(0) { $0 + $1.amount }
            } catch {
                self.error = error
            }
            isLoading = false
        }
    }
}
