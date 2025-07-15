//
//  BankAccountServiceImpl.swift
//  FinApp
//
//  Created by Даниил Дементьев on 15.07.2025.
//

import Foundation
import SwiftData
import Combine

protocol AccountBackupStorageProtocol {
    func all() async throws -> [BackupAccountOperation]
    func add(_ op: BackupAccountOperation) async throws
    func remove(by accountId: Int) async throws
}

private struct AccountUpdateRequest: Encodable {
    let name: String
    let balance: String
    let currency: String

    init(from account: BankAccount) {
        name = account.name
        balance = Self.posixDecimalFormatter.string(from:
                                                        account.balance as NSDecimalNumber)
        ?? "0.00"
        currency = account.currency
    }

    static let posixDecimalFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        formatter.decimalSeparator = "."
        formatter.groupingSeparator = ""
        return formatter
    }()
}

@MainActor
final class BankAccountServiceImpl: BankAccountServiceProtocol {

    private let networkClient: NetworkClient
    private let localStorage: AccountsLocalStorageProtocol
    private let backupStorage: AccountBackupStorageProtocol

    init(
        networkClient: NetworkClient,
        localStorage: AccountsLocalStorageProtocol,
        backupStorage: AccountBackupStorageProtocol
    ) {
        self.networkClient = networkClient
        self.localStorage = localStorage
        self.backupStorage = backupStorage
    }

    func fetchAccount() async throws -> BankAccount {
        try await syncBackupWithBackend()

        do {
            let remoteAccounts: [BankAccount] = try await networkClient.request(.accounts)
            guard let remote = remoteAccounts.first else {
                throw NetworkError.http(code: 404, message: "Пользователь не имеет счёта")
            }
            try await persist(remote)
            return remote
        } catch {
            let localAccounts = try await localStorage.all()
            guard var local = localAccounts.first else { throw error }

            if let pending = try await backupStorage.all().first(where: { $0.id == local.id }) {
                local = pending.account
            }
            return local
        }
    }

    func updateAccount(_ updated: BankAccount) async throws {
        do {
            try await sendUpdate(updated)
            try await localStorage.update(updated)
            try await backupStorage.remove(by: updated.id)
        } catch {
            try await localStorage.update(updated)
            let operation = BackupAccountOperation(account: updated, action: .update)
            try await backupStorage.add(operation)
            throw error
        }
    }

    private func persist(_ account: BankAccount) async throws {
        let existing = try await localStorage.all()
        if existing.contains(where: { $0.id == account.id }) {
            try await localStorage.update(account)
        } else {
            try await localStorage.create(account)
        }
    }

    private func syncBackupWithBackend() async throws {
        let pending = try await backupStorage.all()
        guard !pending.isEmpty else { return }

        for operation in pending {
            do {
                try await sendUpdate(operation.account)
                try await backupStorage.remove(by: operation.id)
            } catch {
                continue
            }
        }
    }

    private func sendUpdate(_ account: BankAccount) async throws {
        let body = AccountUpdateRequest(from: account)
        _ = try await networkClient.request(
            .updateAccount(id: account.id),
            body: body,
            responseType: BankAccount.self
        )
    }
}
