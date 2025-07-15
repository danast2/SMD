//
//  SwiftDataTransactionsStorage.swift
//  FinApp
//
//  Created by Даниил Дементьев on 19.07.2025.
//

import Foundation
import SwiftData

@MainActor
final class SwiftDataTransactionsStorage: TransactionsLocalStorageProtocol, JSONCodingSupport {

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

    func all() async throws -> [Transaction] {
        try context.fetch(FetchDescriptor<TransactionEntity>())
            .compactMap { try? decoder.decode(Transaction.self, from: $0.json) }
    }

    func create(_ transaction: Transaction) async throws {
        let entity = TransactionEntity(id: transaction.id,
                                       json: try encoder.encode(transaction))
        context.insert(entity)
        try context.save()
    }

    func update(_ transaction: Transaction) async throws {
        let descriptor = FetchDescriptor<TransactionEntity>(
            predicate: #Predicate { $0.id == transaction.id }
        )
        if let entity = try context.fetch(descriptor).first {
            entity.json = try encoder.encode(transaction)
            try context.save()
        }
    }

    func delete(by id: Int) async throws {
        let descriptor = FetchDescriptor<TransactionEntity>(
            predicate: #Predicate { $0.id == id }
        )
        for entity in try context.fetch(descriptor) {
            context.delete(entity)
        }
        try context.save()
    }
}
