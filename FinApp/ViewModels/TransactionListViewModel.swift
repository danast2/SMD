//
//  TransactionsListViewModel.swift
//  FinApp
//
//  Created by Даниил Дементьев on 17.06.2025.
//

import Foundation
import Combine

@MainActor
final class TransactionsListViewModel: ObservableObject {

    @Published var transactions: [Transaction] = []
    @Published var totalAmount: Decimal = 0
    @Published var isLoading = false
    @Published var error: Error?

    private let directionValue: Direction
    private let service: any TransactionsServiceProtocol

    var direction: Direction { directionValue }
    var transactionsService: any TransactionsServiceProtocol { service }

    private var bag = Set<AnyCancellable>()

    init(
        direction: Direction,
        transactionsService: any TransactionsServiceProtocol,
        accountDidLoad: AnyPublisher<Void, Never>
    ) {
        self.directionValue = direction
        self.service        = transactionsService

        accountDidLoad
            .sink { [weak self] in
                guard let self else { return }
                Task { await self.fetchAndProcessTransactions() }
            }
            .store(in: &bag)

        service.didChangePublisher
            .sink { [weak self] in
                guard let self else { return }
                Task { await self.fetchAndProcessTransactions() }
            }
            .store(in: &bag)
    }

    func loadTransactionsForListView() {
        Task { await fetchAndProcessTransactions() }
    }

    private func fetchAndProcessTransactions() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let cal   = Calendar.current
            let today = cal.startOfDay(for: Date())
            guard let endOfDay = cal.date(bySettingHour: 23, minute: 59, second: 59, of: today)
            else { return }

            let all     = try await service.fetchTransactions(from: today, to: endOfDay)
            let related = all.filter { $0.category.direction == direction }
            transactions = related
            totalAmount  = related.reduce(0) { $0 + $1.amount }
        } catch {
            self.error = error
        }
    }
}
