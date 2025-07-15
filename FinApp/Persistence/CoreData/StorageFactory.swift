//
//  StorageFactory.swift
//  FinApp
//
//  Created by Даниил Дементьев on 19.07.2025.
//

import Foundation

enum StorageFactory {

    @MainActor static func makeAccounts(engine: StorageEngine = currentEngine())
        -> AccountsLocalStorageProtocol {
        switch engine {
        case .swiftdata: return SwiftDataAccountsStorage()
        case .coredata:  return CoreDataAccountsStorage()
        }
    }

    @MainActor static func makeCategories(engine: StorageEngine = currentEngine())
        -> CategoriesLocalStorageProtocol {
        switch engine {
        case .swiftdata: return SwiftDataCategoriesStorage()
        case .coredata:  return CoreDataCategoriesStorage()
        }
    }

    @MainActor static func makeTransactions(engine: StorageEngine = currentEngine())
        -> TransactionsLocalStorageProtocol {
        switch engine {
        case .swiftdata: return SwiftDataTransactionsStorage()
        case .coredata:  return CoreDataTransactionsStorage()
        }
    }

    @MainActor static func makeAccountBackup(engine: StorageEngine = currentEngine())
        -> AccountBackupStorageProtocol {
        switch engine {
        case .swiftdata: return AccountBackupStorage()
        case .coredata:  return CoreDataAccountBackupStorage()
        }
    }

    @MainActor static func makeTransactionsBackup(engine: StorageEngine = currentEngine())
        -> TransactionsBackupStorageProtocol {
        switch engine {
        case .swiftdata: return TransactionsBackupStorage()
        case .coredata:  return CoreDataTransactionsBackupStorage()
        }
    }
}
