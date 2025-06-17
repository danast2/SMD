//
//  TransactionsStoryViewModel.swift
//  FinApp
//
//  Created by Даниил Дементьев on 17.06.2025.
//

import Foundation

@MainActor
class TransactionsStoryViewModel: ObservableObject {
    enum SortOption: String, CaseIterable {
        case byDate = "По Дате"
        case byAmount = "По Сумме"
    }

    @Published var startDate = Calendar.current.date(
        byAdding: .month,
        value: -1,
        to: Date()) ?? Date()
    @Published var endDate = Date()
    @Published var transactions: [Transaction] = []
    @Published var totalAmount: Decimal = 0
    @Published var isLoading = false
    @Published var error: Error?
    @Published var selectedSortOption: SortOption = .byDate

    let direction: Direction
    let transactionsService: TransactionsService

    var sortedTransactions: [Transaction] {
        transactions.sorted(by: { lhs, rhs in
            switch selectedSortOption {
            case .byDate:
                return lhs.transactionDate < rhs.transactionDate
            case .byAmount:
                return lhs.amount > rhs.amount
            }
        })
    }

    init(direction: Direction, transactionsService: TransactionsService) {
        self.direction = direction
        self.transactionsService = transactionsService
        Task {
            await reloadData()
        }
    }

    func reloadData() async {
        isLoading = true
        error = nil
        do {
            let calendar = Calendar.current
            let startOfPeriod = calendar.startOfDay(for: startDate)
            var components = DateComponents()
            components.day = 1
            let endOfPeriod = calendar.startOfDay(for: endDate)
            let periodEnd = calendar.date(byAdding: .day, value: 1, to: endOfPeriod) ?? endOfPeriod

            let all = try await transactionsService.fetchTransactions(
                from: startOfPeriod,
                to: periodEnd)
            transactions = all.filter { $0.category.direction == direction }
            totalAmount = transactions.reduce(0) { $0 + $1.amount }
        } catch {
            self.error = error
        }
        isLoading = false
    }
}
