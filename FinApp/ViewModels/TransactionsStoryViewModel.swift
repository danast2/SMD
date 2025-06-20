//
//  TransactionsStoryViewModel.swift
//  FinApp
//
//  Created by Даниил Дементьев on 17.06.2025.
//

import Foundation

class TransactionsStoryViewModel: ObservableObject {
    enum SortOption: String, CaseIterable {
        case byDate = "title.byDate"
        case byAmount = "title.byAmount"

        var localizedTitle: String {
            rawValue.localized
        }
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
        transactions.sorted {
            switch selectedSortOption {
            case .byDate:
                return $0.transactionDate < $1.transactionDate
            case .byAmount:
                return $0.amount > $1.amount
            }
        }
    }

    init(direction: Direction, transactionsService: TransactionsService) {
        self.direction = direction
        self.transactionsService = transactionsService
        Task {
            await reloadData()
        }
    }

    func reloadData() async {
        await MainActor.run {
            self.isLoading = true
            self.error = nil
        }

        do {
            let calendar = Calendar.current
            let startOfPeriod = calendar.startOfDay(for: startDate)
            let endOfPeriod = calendar.startOfDay(for: endDate)
            let periodEnd = calendar.date(byAdding: .day, value: 1, to: endOfPeriod) ?? endOfPeriod

            let all = try await transactionsService.fetchTransactions(
                from: startOfPeriod,
                to: periodEnd)
            let filtered = all.filter { $0.category.direction == direction }
            let total = filtered.reduce(0) { $0 + $1.amount }

            await MainActor.run {
                self.transactions = filtered
                self.totalAmount = total
            }
        } catch {
            await MainActor.run {
                self.error = error
            }
        }

        await MainActor.run {
            self.isLoading = false
        }
    }
}
