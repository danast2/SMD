//
//  TransactionsService.swift
//  FinApp
//
//  Created by Даниил Дементьев on 11.06.2025.
//

import Foundation

enum TransactionsServiceError: Error, LocalizedError {
    case transactionAlreadyExists
    case transactionNotFound

    var errorDescription: String? {
        switch self {
        case .transactionAlreadyExists:
            return "A transaction with this ID already exists"
        case .transactionNotFound:
            return "The update transaction was not found"
        }
    }
}

final class TransactionsService {

    private var transactions: [Transaction] = {
        let isoFormatter = ISO8601DateFormatter()

        let mainBalance = Decimal(15000.00)
        let salaryAmount = Decimal(50000.00)
        let groceriesAmount = Decimal(1500.50)
        let mockAmount1 = Decimal(1500.50)
        let mockAmount2 = Decimal(2330.50)
        let mockAmount3 = Decimal(99999.60)

        guard
            let salaryDate = isoFormatter.date(from: "2025-06-15T10:00:00Z"),
            let groceriesDate = isoFormatter.date(from: "2025-06-15T15:00:00Z"),
            let mockDate1 = isoFormatter.date(from: "2025-06-15T15:01:23Z"),
            let mockDate2 = isoFormatter.date(from: "2025-06-15T15:06:40Z"),
            let mockDate3 = isoFormatter.date(from: "2025-06-15T15:23:33Z")
        else {
            fatalError("Error when creating mock data: invalid Date")
        }

        let account = AccountBrief(
            id: 1,
            name: "Основной счёт",
            balance: mainBalance,
            currency: "RUB"
        )

        let salaryCategory = Category(
            id: 1,
            name: "зп",
            emoji: "💰",
            direction: .income
        )

        let groceriesCategory = Category(
            id: 2,
            name: "продукты в шестёрочке",
            emoji: "🛒",
            direction: .outcome
        )

        let mockCategory1 = Category(
            id: 3,
            name: "продукты в лавке",
            emoji: "🛒",
            direction: .outcome
        )

        let mockCategory2 = Category(
            id: 3,
            name: "Dark Souls 3 в стиме",
            emoji: "🛒",
            direction: .outcome
        )

        let mockCategory3 = Category(
            id: 3,
            name: "выхлоп с темки",
            emoji: "🛒",
            direction: .income
        )

        return [
            Transaction(
                id: 1,
                account: account,
                category: salaryCategory,
                amount: salaryAmount,
                transactionDate: salaryDate,
                comment: "зп за май",
                createdAt: Date(),
                updatedAt: Date()
            ),
            Transaction(
                id: 2,
                account: account,
                category: groceriesCategory,
                amount: groceriesAmount,
                transactionDate: groceriesDate,
                comment: "поход в шестёрочку",
                createdAt: Date(),
                updatedAt: Date()
            ),
            Transaction(
                id: 3,
                account: account,
                category: mockCategory1,
                amount: mockAmount1,
                transactionDate: mockDate1,
                comment: nil,
                createdAt: Date(),
                updatedAt: Date()
            ),
            Transaction(
                id: 4,
                account: account,
                category: mockCategory2,
                amount: mockAmount2,
                transactionDate: mockDate2,
                comment: nil,
                createdAt: Date(),
                updatedAt: Date()
            ),
            Transaction(
                id: 5,
                account: account,
                category: mockCategory3,
                amount: mockAmount3,
                transactionDate: mockDate3,
                comment: nil,
                createdAt: Date(),
                updatedAt: Date()
            )
        ]
    }()

    func fetchTransactions(from: Date, to: Date) async throws -> [Transaction] {
        return transactions.filter {
            $0.transactionDate >= from && $0.transactionDate <= to
        }
    }

    func createTransaction(_ transaction: Transaction) async throws {
        guard !transactions.contains(where: { $0.id == transaction.id }) else {
            throw TransactionsServiceError.transactionAlreadyExists
        }
        transactions.append(transaction)
    }

    func updateTransaction(_ transaction: Transaction) async throws {
        guard let index = transactions.firstIndex(where: { $0.id == transaction.id }) else {
            throw TransactionsServiceError.transactionNotFound
        }
        transactions[index] = transaction
    }

    func deleteTransaction(by id: Int) async throws {
        transactions.removeAll { $0.id == id }
    }
}
