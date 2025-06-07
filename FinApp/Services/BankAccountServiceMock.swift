//
//  BankAccountServiceMock.swift
//  FinApp
//
//  Created by Даниил Дементьев on 09.06.2025.
//

import Foundation

actor BankAccountServiceMock {
    private var account = BankAccount(
        id: 1,
        userId: 1,
        name: "Основной счёт",
        balance: Decimal(string: "1000.00")!,
        currency: "RUB",
        createdAt: Date(),
        updatedAt: Date()
    )

    func account() async -> BankAccount {
        return account
    }

    func updateAccount(_ update: BankAccount) async -> BankAccount {
        self.account = update
        return account
    }
}
