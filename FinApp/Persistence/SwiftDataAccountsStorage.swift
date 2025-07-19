//
//  SwiftDataAccountsStorage.swift
//  FinApp
//
//  Created by Даниил Дементьев on 19.07.2025.
//

import Foundation
import SwiftData

@MainActor
final class SwiftDataAccountsStorage: AccountsLocalStorageProtocol, JSONCodingSupport {

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

    func all() async throws -> [BankAccount] {
        try context.fetch(FetchDescriptor<BankAccountEntity>())
            .compactMap { try? decoder.decode(BankAccount.self, from: $0.json) }
    }

    func create(_ account: BankAccount) async throws {
        let entity = BankAccountEntity(id: account.id, json: try encoder.encode(account))
        context.insert(entity)
        try context.save()
    }

    func update(_ account: BankAccount) async throws {
        let descriptor = FetchDescriptor<BankAccountEntity>(
            predicate: #Predicate { $0.id == account.id }
        )
        if let entity = try context.fetch(descriptor).first {
            entity.json = try encoder.encode(account)
            try context.save()
        }
    }

    func delete(by id: Int) async throws {
        let descriptor = FetchDescriptor<BankAccountEntity>(
            predicate: #Predicate { $0.id == id }
        )
        for entity in try context.fetch(descriptor) {
            context.delete(entity)
        }
        try context.save()
    }
}
