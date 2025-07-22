//
//  TransactionsServiceImpl.swift
//  FinApp
//
//  Created by Даниил Дементьев on 15.07.2025.
//

import Foundation
import Combine

protocol TransactionsBackupStorageProtocol {
    func all() async throws -> [BackupTransactionOperation]
    func add(_ op: BackupTransactionOperation) async throws
    func remove(by transactionId: Int) async throws
}

private struct TransactionRequestDTO: Encodable {
    let accountId: Int
    let categoryId: Int
    let amount: String
    let transactionDate: String
    let comment: String?

    init(from model: Transaction) {
        accountId  = model.account.id
        categoryId = model.category.id
        amount = NSDecimalNumber(decimal: model.amount).stringValue
        let fmt = ISO8601DateFormatter()
        fmt.formatOptions = [.withInternetDateTime]
        transactionDate = fmt.string(from: model.transactionDate)
        let trimmed = model.comment?.trimmingCharacters(in: .whitespacesAndNewlines)
        comment = trimmed?.isEmpty == true ? nil : trimmed
    }

    enum CodingKeys: CodingKey {
        case accountId, categoryId, amount, transactionDate, comment
    }

    func encode(to encoder: Encoder) throws {
        var coder = encoder.container(keyedBy: CodingKeys.self)
        try coder.encode(accountId, forKey: .accountId)
        try coder.encode(categoryId, forKey: .categoryId)
        try coder.encode(amount, forKey: .amount)
        try coder.encode(transactionDate, forKey: .transactionDate)
        try coder.encodeNil(forKey: .comment)
    }
}

@MainActor
final class TransactionsServiceImpl: @preconcurrency TransactionsServiceProtocol {

    private let networkClient: NetworkClient
    private let accountIdProvider: () -> Int?
    private let localStorage: TransactionsLocalStorageProtocol
    private let backupStorage: TransactionsBackupStorageProtocol
    private let accountsLocalStorage: AccountsLocalStorageProtocol
    private let accountBackupStorage: AccountBackupStorageProtocol

    private let changeSubject = PassthroughSubject<Void, Never>()
    var didChangePublisher: AnyPublisher<Void, Never> { changeSubject.eraseToAnyPublisher() }

    init(
        networkClient: NetworkClient,
        accountIdProvider: @escaping () -> Int?,
        localStorage: TransactionsLocalStorageProtocol,
        backupStorage: TransactionsBackupStorageProtocol,
        accountsLocalStorage: AccountsLocalStorageProtocol,
        accountBackupStorage: AccountBackupStorageProtocol
    ) {
        self.networkClient = networkClient
        self.accountIdProvider = accountIdProvider
        self.localStorage = localStorage
        self.backupStorage = backupStorage
        self.accountsLocalStorage = accountsLocalStorage
        self.accountBackupStorage = accountBackupStorage
    }

    func fetchTransactions(from startDate: Date, to endDate: Date) async throws -> [Transaction] {
        try await syncBackupWithBackend()
        do {
            let remote = try await loadRemote(startDate: startDate, endDate: endDate)
            try await persist(remote)
            return remote
        } catch {
            return try await mergedLocalAndBackup(startDate: startDate, endDate: endDate)
        }
    }

    func createTransaction(_ transaction: Transaction) async throws {
        do {
            try await sendCreate(transaction)
            try await localStorage.create(transaction)
            try await backupStorage.remove(by: transaction.id)
            changeSubject.send()
        } catch {
            try await localStorage.create(transaction)
            try await backupStorage.add(
                BackupTransactionOperation(transaction: transaction, action: .create)
            )
            let delta = signedAmount(for: transaction)
            try await adjustAccountBalance(by: delta)
            changeSubject.send()
            throw error
        }
    }

    func updateTransaction(_ transaction: Transaction) async throws {
        do {
            try await sendUpdate(transaction)
            try await localStorage.update(transaction)
            try await backupStorage.remove(by: transaction.id)
            changeSubject.send()
        } catch {
            let existing = try await localStorage.all()
                .first(where: { $0.id == transaction.id })
            let delta: Decimal
            if let old = existing {
                delta = signedAmount(for: transaction) - signedAmount(for: old)
                try await localStorage.update(transaction)
            } else {
                delta = signedAmount(for: transaction)
                try await localStorage.create(transaction)
            }
            try await backupStorage.add(
                BackupTransactionOperation(transaction: transaction, action: .update)
            )
            try await adjustAccountBalance(by: delta)
            changeSubject.send()
            throw error
        }
    }

    func deleteTransaction(by id: Int) async throws {
        do {
            try await sendDelete(id: id)
            try await localStorage.delete(by: id)
            try await backupStorage.remove(by: id)
            changeSubject.send()
        } catch {
            let existing = try await localStorage.all().first(where: { $0.id == id })
            try await backupStorage.add(
                BackupTransactionOperation(
                    transaction: existing ?? placeholder(id: id),
                    action: .delete
                )
            )
            changeSubject.send()
            throw error
        }
    }

    private func signedAmount(for transaction: Transaction) -> Decimal {
        transaction.category.direction == .income ? transaction.amount : -transaction.amount
    }

    private func adjustAccountBalance(by delta: Decimal) async throws {
        let accounts = try await accountsLocalStorage.all()
        guard var acc = accounts.first else { return }
        let newBalance = acc.balance + delta
        acc = BankAccount(
            id: acc.id,
            userId: acc.userId,
            name: acc.name,
            balance: newBalance,
            currency: acc.currency,
            createdAt: acc.createdAt,
            updatedAt: Date()
        )
        try await accountsLocalStorage.update(acc)
        let op = BackupAccountOperation(account: acc, action: .update)
        try await accountBackupStorage.add(op)
    }

    private func placeholder(id: Int) -> Transaction {
        Transaction(
            id: id,
            account: AccountBrief(id: 0, name: "", balance: 0, currency: ""),
            category: Category(id: 0, name: "", emoji: "", direction: .outcome),
            amount: 0,
            transactionDate: .distantPast,
            comment: nil,
            createdAt: .distantPast,
            updatedAt: .distantPast
        )
    }

    private func loadRemote(startDate: Date, endDate: Date) async throws -> [Transaction] {
        guard let accountId = accountIdProvider() else {
            throw NetworkError.http(code: 404, message: "Account ID not found")
        }
        return try await networkClient.request(
            .transactionsPeriod(accountId: accountId, startDate: startDate, endDate: endDate),
            responseType: [Transaction].self
        )
    }

    private func persist(_ list: [Transaction]) async throws {
        let existing = try await localStorage.all()
            .reduce(into: [Int: Transaction]()) { $0[$1.id] = $1 }
        for trx in list {
            if existing[trx.id] == nil {
                try await localStorage.create(trx)
            } else {
                try await localStorage.update(trx)
            }
        }
    }

    private func mergedLocalAndBackup(startDate: Date,
                                      endDate: Date) async throws -> [Transaction] {
        let local = try await localStorage.all()
        let ops   = try await backupStorage.all()
        var map   = local.reduce(into: [Int: Transaction]()) { $0[$1.id] = $1 }
        for op in ops {
            switch op.action {
            case .create, .update: map[op.id] = op.transaction
            case .delete: map.removeValue(forKey: op.id)
            }
        }
        return map.values.filter {
            $0.transactionDate >= startDate && $0.transactionDate <= endDate
        }
    }

    private func syncBackupWithBackend() async throws {
        let ops = try await backupStorage.all()
        guard !ops.isEmpty else { return }
        for op in ops {
            do {
                switch op.action {
                case .create: try await sendCreate(op.transaction)
                case .update: try await sendUpdate(op.transaction)
                case .delete: try await sendDelete(id: op.id)
                }
                try await backupStorage.remove(by: op.id)
            } catch {
                continue
            }
        }
    }

    private func sendCreate(_ trx: Transaction) async throws {
        try await networkClient.request(
            .createTransaction,
            body: TransactionRequestDTO(from: trx),
            responseType: EmptyBody.self
        )
    }

    private func sendUpdate(_ trx: Transaction) async throws {
        try await networkClient.request(
            .updateTransaction(id: trx.id),
            body: TransactionRequestDTO(from: trx),
            responseType: EmptyBody.self
        )
    }

    private func sendDelete(id: Int) async throws {
        try await networkClient.request(
            .deleteTransaction(id: id),
            responseType: EmptyBody.self
        )
    }
}
