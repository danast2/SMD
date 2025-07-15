//
//  AccountBackupStorage.swift
//  FinApp
//
//  Created by Даниил Дементьев on 19.07.2025.
//

import Foundation
import SwiftData

@MainActor
final class AccountBackupStorage: AccountBackupStorageProtocol, JSONCodingSupport {

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

    func all() async throws -> [BackupAccountOperation] {
        try context.fetch(FetchDescriptor<BackupAccountEntity>())
            .compactMap { entity in
                guard
                    let account = try? decoder.decode(BankAccount.self, from: entity.json),
                    let action  = BackupAccountAction(rawValue: entity.actionRaw)
                else { return nil }
                return BackupAccountOperation(account: account, action: action)
            }
    }

    func add(_ operation: BackupAccountOperation) async throws {
        let descriptor = FetchDescriptor<BackupAccountEntity>(
            predicate: #Predicate { $0.id == operation.id }
        )
        let data = try encoder.encode(operation.account)

        if let entity = try context.fetch(descriptor).first {
            entity.actionRaw = operation.action.rawValue
            entity.json      = data
        } else {
            let entity = BackupAccountEntity(id: operation.id,
                                             actionRaw: operation.action.rawValue,
                                             json: data)
            context.insert(entity)
        }
        try context.save()
    }

    func remove(by accountId: Int) async throws {
        let descriptor = FetchDescriptor<BackupAccountEntity>(
            predicate: #Predicate { $0.id == accountId }
        )
        for entity in try context.fetch(descriptor) {
            context.delete(entity)
        }
        try context.save()
    }
}
