//
//  TransactionsStoryViewModel.swift
//  FinApp
//
//  Created by Даниил Дементьев on 17.06.2025.
//

import Foundation

class TransactionsStoryViewModel: ObservableObject {
    enum SortOption: String, CaseIterable {
        case byDate  = "title.byDate"
        case byAmount = "title.byAmount"

        var localizedTitle: String { rawValue.localized }
    }

    @Published var startDate: Date
    @Published var endDate: Date
    @Published var transactions: [Transaction] = []
    @Published var totalAmount: Decimal = 0
    @Published var isLoading = false
    @Published var error: Error?
    @Published var selectedSortOption: SortOption = .byDate

    let direction: Direction
    private let transactionsService: any TransactionsServiceProtocol

    var sortedTransactions: [Transaction] {
        transactions.sorted {
            switch selectedSortOption {
            case .byDate:   return $0.transactionDate < $1.transactionDate
            case .byAmount: return $0.amount > $1.amount
            }
        }
    }

    init(direction: Direction, transactionsService: any TransactionsServiceProtocol) {
        self.direction = direction
        self.transactionsService = transactionsService

        let now = Date()
        let calendar = Calendar.current
        self.endDate   = now
        self.startDate = calendar.date(byAdding: .month, value: -1, to: now) ?? now

        Task { await reloadData() }
    }

    @MainActor
    func reloadData() async {
        isLoading = true
        error = nil

        let calendar = Calendar.current
        let periodStart = calendar.startOfDay(for: startDate)
        let dayAfterEnd = calendar.date(
            byAdding: .day,
            value: 1,
            to: calendar.startOfDay(for: endDate)) ?? endDate

        do {
            let all = try await transactionsService.fetchTransactions(
                from: periodStart,
                to: dayAfterEnd)
            let filtered = all.filter { $0.category.direction == direction }
            transactions = filtered
            totalAmount = filtered.reduce(0) { $0 + $1.amount }
        } catch {
            self.error = error
        }

        isLoading = false
    }
}
