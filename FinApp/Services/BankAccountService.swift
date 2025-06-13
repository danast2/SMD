//
//  BankAccountService.swift
//  FinApp
//
//  Created by Даниил Дементьев on 09.06.2025.
//

import Foundation

enum BankAccountServiceError: Error, LocalizedError {
    case noAvailableAccounts
    case accountNotFound

    var errorDescription: String? {
        switch self {
        case .noAvailableAccounts:
            return "No available accounts"
        case .accountNotFound:
            return "Account not found"
        }
    }
}

final class BankAccountServiceMock {

    private var accounts: [BankAccount] = {
        let mainBalance = Decimal(15000.00)
        let cardBalance = Decimal(3200.50)

        return [
            BankAccount(
                id: 1,
                userId: 1,
                name: "Основной счёт",
                balance: mainBalance,
                currency: "RUB",
                createdAt: Date(),
                updatedAt: Date()
            ),
            BankAccount(
                id: 2,
                userId: 1,
                name: "Карта Я. Пэй",
                balance: cardBalance,
                currency: "RUB",
                createdAt: Date(),
                updatedAt: Date()
            )
        ]
    }()

    func fetchAccount() async throws -> BankAccount {
        guard let first = accounts.first else {
            throw BankAccountServiceError.noAvailableAccounts
        }
        return first
    }

    func updateAccount(_ updated: BankAccount) async throws {
        guard let index = accounts.firstIndex(where: { $0.id == updated.id }) else {
            throw BankAccountServiceError.accountNotFound
        }
        accounts[index] = updated
    }
}
