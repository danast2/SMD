//
//  Migrator.swift
//  FinApp
//
//  Created by Даниил Дементьев on 19.07.2025.
//

import Foundation
import os.log

@MainActor
enum Migrator {

    static func migrate(from sourceEngine: StorageEngine,
                        to targetEngine: StorageEngine) async throws {

        guard sourceEngine != targetEngine else { return }

        let log = Logger(subsystem: "FinApp", category: "Migration")
        log.info("Start migration \(sourceEngine.rawValue) → \(targetEngine.rawValue)")

        let srcAccounts      = StorageFactory.makeAccounts(engine: sourceEngine)
        let srcCategories    = StorageFactory.makeCategories(engine: sourceEngine)
        let srcTransactions  = StorageFactory.makeTransactions(engine: sourceEngine)
        let srcAccBackup     = StorageFactory.makeAccountBackup(engine: sourceEngine)
        let srcTrxBackup     = StorageFactory.makeTransactionsBackup(engine: sourceEngine)

        let dstAccounts      = StorageFactory.makeAccounts(engine: targetEngine)
        let dstCategories    = StorageFactory.makeCategories(engine: targetEngine)
        let dstTransactions  = StorageFactory.makeTransactions(engine: targetEngine)
        let dstAccBackup     = StorageFactory.makeAccountBackup(engine: targetEngine)
        let dstTrxBackup     = StorageFactory.makeTransactionsBackup(engine: targetEngine)

        try await migrateAccounts(from: srcAccounts, to: dstAccounts)
        try await migrateCategories(from: srcCategories, to: dstCategories)
        try await migrateTransactions(from: srcTransactions, to: dstTransactions)
        try await migrateAccountBackups(from: srcAccBackup, to: dstAccBackup)
        try await migrateTransactionBackups(from: srcTrxBackup, to: dstTrxBackup)

        log.info("Migration completed")
    }

    private static func migrateAccounts(
        from source: any AccountsLocalStorageProtocol,
        to   target: any AccountsLocalStorageProtocol
    ) async throws {
        for model in try await source.all() {
            try await upsert(model, to: target)
        }
    }

    private static func migrateCategories(
        from source: any CategoriesLocalStorageProtocol,
        to   target: any CategoriesLocalStorageProtocol
    ) async throws {
        for model in try await source.all() {
            try await upsert(model, to: target)
        }
    }

    private static func migrateTransactions(
        from source: any TransactionsLocalStorageProtocol,
        to   target: any TransactionsLocalStorageProtocol
    ) async throws {
        for model in try await source.all() {
            try await upsert(model, to: target)
        }
    }

    private static func migrateAccountBackups(
        from source: any AccountBackupStorageProtocol,
        to   target: any AccountBackupStorageProtocol
    ) async throws {
        for op in try await source.all() {
            try await target.add(op)
        }
    }

    private static func migrateTransactionBackups(
        from source: any TransactionsBackupStorageProtocol,
        to   target: any TransactionsBackupStorageProtocol
    ) async throws {
        for op in try await source.all() {
            try await target.add(op)
        }
    }

    private static func upsert(
        _ account: BankAccount,
        to storage: any AccountsLocalStorageProtocol
    ) async throws {
        do {
            try await storage.update(account)
        } catch {
            try await storage.create(account)
        }
    }

    private static func upsert(
        _ category: Category,
        to storage: any CategoriesLocalStorageProtocol
    ) async throws {
        do {
            try await storage.update(category)
        } catch {
            try await storage.create(category)
        }
    }

    private static func upsert(
        _ trx: Transaction,
        to storage: any TransactionsLocalStorageProtocol
    ) async throws {
        do {
            try await storage.update(trx)
        } catch {
            try await storage.create(trx)
        }
    }
}
