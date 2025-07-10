//
//  TransactionListViewModel.swift
//  FinApp
//
//  Created by Даниил Дементьев on 17.06.2025.
//

import Foundation

class TransactionsListViewModel: ObservableObject {

    let transactionsService: TransactionsService
    let direction: Direction

    @Published var transactions: [Transaction] = []
    @Published var totalAmount: Decimal = 0
    @Published var isLoading = false
    @Published var error: Error?

    init(direction: Direction, transactionsService: TransactionsService) {
        self.direction = direction
        self.transactionsService = transactionsService
    }

    /// Запускает асинхронную загрузку (на фоновом потоке)
    func loadTransactionsForListView() {
        Task {
            await fetchAndProcessTransactions()
        }
    }

    /// Выполняет fetch на фоне, затем — UI-обновления на главном потоке
    @MainActor
    private func fetchAndProcessTransactions() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())
            let endOfDay = calendar.date(
                bySettingHour: 23, minute: 59, second: 59, of: today
            ) ?? today

            // Асинхронный вызов на фоне
            let all = try await transactionsService.fetchTransactions(
                from: today, to: endOfDay
            )

            // Фильтрация и подсчёт — тоже безопасно на главном, быстро
            let related = all.filter { $0.category.direction == direction }
            let total = related.reduce(0) { $0 + $1.amount }

            // Обновляем свойства, которые наблюдаются UI
            transactions = related
            totalAmount = total

        } catch {
            self.error = error
        }
    }
}
