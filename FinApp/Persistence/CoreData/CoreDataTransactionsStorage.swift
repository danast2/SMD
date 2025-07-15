//
//  CoreDataTransactionsStorage.swift
//  FinApp
//
//  Created by Даниил Дементьев on 19.07.2025.
//

import Foundation
import CoreData

@MainActor
final class CoreDataTransactionsStorage: TransactionsLocalStorageProtocol, JSONCodingSupport {

    private let context: NSManagedObjectContext

    init() {
        guard let ctx = try? CoreDataContainer.make().viewContext else {
            fatalError("Не удалось создать viewContext для CoreDataTransactionsStorage")
        }
        self.context = ctx
    }

    func all() async throws -> [Transaction] {
        let req = NSFetchRequest<NSManagedObject>(entityName: "TransactionCD")
        return try context.fetch(req).compactMap {
            guard let data = $0.value(forKey: "json") as? Data
            else { return nil }
            return try? decoder.decode(Transaction.self, from: data)
        }
    }

    func create(_ transaction: Transaction) async throws {
        let obj = NSEntityDescription.insertNewObject(forEntityName: "TransactionCD", into: context)
        obj.setValue(Int64(transaction.id), forKey: "id")
        obj.setValue(try encoder.encode(transaction), forKey: "json")
        try context.save()
    }

    func update(_ transaction: Transaction) async throws {
        let req = NSFetchRequest<NSManagedObject>(entityName: "TransactionCD")
        req.predicate = NSPredicate(format: "id == %lld", transaction.id)
        if let obj = try context.fetch(req).first {
            obj.setValue(try encoder.encode(transaction), forKey: "json")
            try context.save()
        }
    }

    func delete(by id: Int) async throws {
        let req = NSFetchRequest<NSManagedObject>(entityName: "TransactionCD")
        req.predicate = NSPredicate(format: "id == %lld", id)
        for obj in try context.fetch(req) { context.delete(obj) }
        try context.save()
    }
}
