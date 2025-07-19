//
//  CoreDataAccountsStorage.swift
//  FinApp
//
//  Created by Даниил Дементьев on 19.07.2025.
//

import Foundation
import CoreData

@MainActor
final class CoreDataAccountsStorage: AccountsLocalStorageProtocol, JSONCodingSupport {

    private let context: NSManagedObjectContext

    init() {
        do {
            context = try CoreDataContainer.make().viewContext
        } catch {
            fatalError("CoreData init error: \(error)")
        }
    }

    // MARK: – CRUD

    func all() async throws -> [BankAccount] {
        let req = NSFetchRequest<NSManagedObject>(entityName: "BankAccountCD")
        return try context.fetch(req).compactMap {
            guard let data = $0.value(forKey: "json") as? Data
            else { return nil }
            return try? decoder.decode(BankAccount.self, from: data)
        }
    }

    func create(_ account: BankAccount) async throws {
        let obj = NSEntityDescription.insertNewObject(forEntityName: "BankAccountCD",
                                                      into: context)
        obj.setValue(Int64(account.id), forKey: "id")
        obj.setValue(try encoder.encode(account), forKey: "json")
        try context.save()
    }

    func update(_ account: BankAccount) async throws {
        let req = NSFetchRequest<NSManagedObject>(entityName: "BankAccountCD")
        req.predicate = NSPredicate(format: "id == %lld", account.id)
        if let obj = try context.fetch(req).first {
            obj.setValue(try encoder.encode(account), forKey: "json")
            try context.save()
        }
    }

    func delete(by id: Int) async throws {
        let req = NSFetchRequest<NSManagedObject>(entityName: "BankAccountCD")
        req.predicate = NSPredicate(format: "id == %lld", id)
        for obj in try context.fetch(req) {
            context.delete(obj)
        }
        try context.save()
    }
}
