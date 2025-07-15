//
//  TransactionsBackupStorage.swift
//  FinApp
//
//  Created by Даниил Дементьев on 19.07.2025.
//

import Foundation
import SwiftData

@MainActor
final class TransactionsBackupStorage: TransactionsBackupStorageProtocol, JSONCodingSupport {

    private let container: ModelContainer
    private let context: ModelContext

    init() {
        do {
            container = try SwiftDataContainer.make()
            context   = ModelContext(container)
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    func all() async throws -> [BackupTransactionOperation] {
        try context.fetch(FetchDescriptor<BackupTransactionEntity>())
            .compactMap { entity in
                guard
                    let trx    = try? decoder.decode(Transaction.self, from: entity.json),
                    let action = BackupAction(rawValue: entity.actionRaw)
                else { return nil }
                return BackupTransactionOperation(transaction: trx, action: action)
            }
    }

    func add(_ operation: BackupTransactionOperation) async throws {
        let descriptor = FetchDescriptor<BackupTransactionEntity>(
            predicate: #Predicate { $0.id == operation.id }
        )
        let data = try encoder.encode(operation.transaction)

        if let entity = try context.fetch(descriptor).first {
            entity.actionRaw = operation.action.rawValue
            entity.json      = data
        } else {
            let entity = BackupTransactionEntity(id: operation.id,
                                                 actionRaw: operation.action.rawValue,
                                                 json: data)
            context.insert(entity)
        }
        try context.save()
    }

    func remove(by transactionId: Int) async throws {
        let descriptor = FetchDescriptor<BackupTransactionEntity>(
            predicate: #Predicate { $0.id == transactionId }
        )
        for entity in try context.fetch(descriptor) {
            context.delete(entity)
        }
        try context.save()
    }
}
