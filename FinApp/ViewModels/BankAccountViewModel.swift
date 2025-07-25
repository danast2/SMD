//
//  BankAccountViewModel.swift
//  FinApp
//
//  Created by Даниил Дементьев on 23.06.2025.
//

import Foundation
import SwiftUI
import Combine

struct AccountTransaction: Identifiable {
    let id: UUID
    let date: Date
    let amount: Decimal
}

@MainActor
final class BankAccountViewModel: ObservableObject {

    @Published var account: BankAccount?
    @Published var isEditing = false
    @Published var isBalanceHidden = false
    @Published var balanceInput = ""
    @Published var selectedCurrency: String = Currency.rub.rawValue
    @Published var error: Error?
    @Published var isLoading = false
    @Published var transactions: [AccountTransaction] = []

    let didLoad = PassthroughSubject<Void, Never>()

    private let accountService: any BankAccountServiceProtocol
    private let transactionsService: any TransactionsServiceProtocol
    private var bag = Set<AnyCancellable>()
    private let calendar = Calendar.current

    init(
        accountService: any BankAccountServiceProtocol,
        transactionsService: any TransactionsServiceProtocol
    ) {
        self.accountService       = accountService
        self.transactionsService  = transactionsService

        Task { await loadAccount() }

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didShake),
            name: .deviceDidShakeNotification,
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(
            self,
            name: .deviceDidShakeNotification,
            object: nil
        )
    }

    @objc private func didShake() {
        withAnimation(.easeInOut(duration: 0.3)) {
            isBalanceHidden.toggle()
        }
    }

    func reload() { Task { await loadAccount() } }

    func toggleEditMode() {
        if isEditing {
            saveChanges()
        } else {
            isEditing = true
            if let account { balanceInput = "\(account.balance)" }
        }
    }

    func loadAccount() async {
        isLoading = true
        defer { isLoading = false }
        do {
            account = try await accountService.fetchAccount()
            selectedCurrency = account?.currency ?? Currency.rub.rawValue

            let now = Date()
            let startDate = calendar.date(byAdding: .month, value: -24, to: now) ?? now
            let endDate   = calendar.date(byAdding: .day, value: 1, to: now) ?? now

            let rawTransactions = try await transactionsService.fetchTransactions(
                from: startDate,
                to: endDate
            )

            transactions = rawTransactions.map {
                AccountTransaction(
                    id: UUID(),
                    date: $0.transactionDate,
                    amount: $0.category.direction == .income ? $0.amount : -$0.amount
                )
            }

            didLoad.send()
        } catch {
            self.error = error
        }
    }

    func balances(for period: ChartPeriod) -> [DateBalance] {
        guard !transactions.isEmpty else { return [] }
        var result: [DateBalance] = []
        let now = Date()
        let count = period.length
        for index in 0..<count {
            guard let anchorDate = calendar.date(
                byAdding: period.calendarComponent,
                value: -(count - 1 - index),
                to: now
            ) else { continue }

            switch period {
            case .day:
                let startDate = calendar.startOfDay(for: anchorDate)
                guard let endDate = calendar.date(byAdding: .day, value: 1, to: startDate)
                else { continue }
                let dailySum = transactions
                    .filter { $0.date >= startDate && $0.date < endDate }
                    .reduce(Decimal.zero) { $0 + $1.amount }
                result.append(DateBalance(date: startDate, amount: dailySum))

            case .month:
                guard let interval = calendar.dateInterval(of: .month, for: anchorDate)
                else { continue }
                let monthlySum = transactions
                    .filter { $0.date >= interval.start && $0.date < interval.end }
                    .reduce(Decimal.zero) { $0 + $1.amount }
                result.append(DateBalance(date: interval.start, amount: monthlySum))
            }
        }
        return result
    }

    private func saveChanges() {
        guard let oldAccount = account else { return }

        let cleaned = balanceInput
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: ",", with: ".")

        let validPattern = #"^-?\d*\.?\d*$"#
        guard
            cleaned.range(of: validPattern, options: .regularExpression) != nil,
            let newBalance = Decimal(string: cleaned)
        else { return }

        let updated = BankAccount(
            id: oldAccount.id,
            userId: oldAccount.userId,
            name: oldAccount.name,
            balance: newBalance,
            currency: selectedCurrency,
            createdAt: oldAccount.createdAt,
            updatedAt: Date()
        )

        Task {
            do {
                try await accountService.updateAccount(updated)
                await loadAccount()
                isEditing = false
            } catch {
                self.error = error
            }
        }
    }
}
