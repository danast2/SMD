//
//  TransactionListViewModel.swift
//  FinApp
//
//  Created by Даниил Дементьев on 17.06.2025.
//

import Foundation

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
            await MainActor.run { self.isLoading = true }
            defer { Task { await MainActor.run { self.isLoading = false } } }

            do {
                let calendar = Calendar.current
                let today = calendar.startOfDay(for: Date())
                let endOfDay = calendar.date(
                    bySettingHour: 23, minute: 59, second: 59, of: today
                ) ?? today

                let all = try await transactionsService.fetchTransactions(from: today, to: endOfDay)
                let related = all.filter { $0.category.direction == direction }
                let total = related.reduce(0) { $0 + $1.amount }

                await MainActor.run {
                    self.transactions = related
                    self.totalAmount = total
                }

            } catch {
                await MainActor.run {
                    self.error = error
                }
            }
        }
    }
}
