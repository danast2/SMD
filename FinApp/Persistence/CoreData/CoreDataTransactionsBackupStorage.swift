//
//  CoreDataTransactionsBackupStorage.swift
//  FinApp
//
//  Created by Даниил Дементьев on 19.07.2025.
//

import Foundation
import CoreData

@MainActor
final class CoreDataTransactionsBackupStorage: TransactionsBackupStorageProtocol,
                                               JSONCodingSupport {

    private let context: NSManagedObjectContext

    init() {
        guard let ctx = try? CoreDataContainer.make().viewContext else {
            fatalError("Не удалось создать viewContext для CoreDataTransactionsBackupStorage")
        }
        self.context = ctx
    }

    func all() async throws -> [BackupTransactionOperation] {
        let req = NSFetchRequest<NSManagedObject>(entityName: "BackupTransactionCD")
        return try context.fetch(req).compactMap {
            guard
                let data = $0.value(forKey: "json") as? Data,
                let actionRaw = $0.value(forKey: "actionRaw") as? String,
                let action = BackupAction(rawValue: actionRaw),
                let model = try? decoder.decode(Transaction.self, from: data)
            else { return nil }
            return BackupTransactionOperation(transaction: model, action: action)
        }
    }

    func add(_ op: BackupTransactionOperation) async throws {
        let req = NSFetchRequest<NSManagedObject>(entityName: "BackupTransactionCD")
        req.predicate = NSPredicate(format: "id == %lld", op.id)
        let obj = try context.fetch(req).first
            ?? NSEntityDescription.insertNewObject(forEntityName: "BackupTransactionCD",
                                                   into: context)

        obj.setValue(Int64(op.id), forKey: "id")
        obj.setValue(op.action.rawValue, forKey: "actionRaw")
        obj.setValue(try encoder.encode(op.transaction), forKey: "json")
        try context.save()
    }

    func remove(by transactionId: Int) async throws {
        let req = NSFetchRequest<NSManagedObject>(entityName: "BackupTransactionCD")
        req.predicate = NSPredicate(format: "id == %lld", transactionId)
        for obj in try context.fetch(req) { context.delete(obj) }
        try context.save()
    }
}
