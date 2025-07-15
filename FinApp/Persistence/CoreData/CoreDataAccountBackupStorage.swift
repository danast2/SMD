//
//  CoreDataAccountBackupStorage.swift
//  FinApp
//
//  Created by Даниил Дементьев on 19.07.2025.
//

import Foundation
import CoreData

@MainActor
final class CoreDataAccountBackupStorage: AccountBackupStorageProtocol, JSONCodingSupport {

    private let context: NSManagedObjectContext

    init() {
        guard let ctx = try? CoreDataContainer.make().viewContext else {
            fatalError("Не удалось создать viewContext для CoreDataAccountBackupStorage")
        }
        self.context = ctx
    }

    func all() async throws -> [BackupAccountOperation] {
        let req = NSFetchRequest<NSManagedObject>(entityName: "BackupAccountCD")
        return try context.fetch(req).compactMap {
            guard
                let data = $0.value(forKey: "json") as? Data,
                let actionRaw = $0.value(forKey: "actionRaw") as? String,
                let action = BackupAccountAction(rawValue: actionRaw),
                let model = try? decoder.decode(BankAccount.self, from: data)
            else { return nil }
            return BackupAccountOperation(account: model, action: action)
        }
    }

    func add(_ op: BackupAccountOperation) async throws {
        let req = NSFetchRequest<NSManagedObject>(entityName: "BackupAccountCD")
        req.predicate = NSPredicate(format: "id == %lld", op.id)
        let obj = try context.fetch(req).first
            ?? NSEntityDescription.insertNewObject(forEntityName: "BackupAccountCD",
                                                   into: context)

        obj.setValue(Int64(op.id), forKey: "id")
        obj.setValue(op.action.rawValue, forKey: "actionRaw")
        obj.setValue(try encoder.encode(op.account), forKey: "json")
        try context.save()
    }

    func remove(by accountId: Int) async throws {
        let req = NSFetchRequest<NSManagedObject>(entityName: "BackupAccountCD")
        req.predicate = NSPredicate(format: "id == %lld", accountId)
        for obj in try context.fetch(req) { context.delete(obj) }
        try context.save()
    }
}
