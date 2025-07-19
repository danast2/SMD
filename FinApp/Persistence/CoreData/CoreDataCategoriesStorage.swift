//
//  CoreDataCategoriesStorage.swift
//  FinApp
//
//  Created by Даниил Дементьев on 19.07.2025.
//

import Foundation
import CoreData

@MainActor
final class CoreDataCategoriesStorage: CategoriesLocalStorageProtocol, JSONCodingSupport {

    private let context: NSManagedObjectContext

    init() {
        guard let ctx = try? CoreDataContainer.make().viewContext else {
            fatalError("Не удалось создать viewContext для CoreDataCategoriesStorage")
        }
        self.context = ctx
    }

    func all() async throws -> [Category] {
        let req = NSFetchRequest<NSManagedObject>(entityName: "CategoryCD")
        return try context.fetch(req).compactMap {
            guard let data = $0.value(forKey: "json") as? Data
            else { return nil }
            return try? decoder.decode(Category.self, from: data)
        }
    }

    func create(_ category: Category) async throws {
        let obj = NSEntityDescription.insertNewObject(forEntityName: "CategoryCD", into: context)
        obj.setValue(Int64(category.id), forKey: "id")
        obj.setValue(try encoder.encode(category), forKey: "json")
        try context.save()
    }

    func update(_ category: Category) async throws {
        let req = NSFetchRequest<NSManagedObject>(entityName: "CategoryCD")
        req.predicate = NSPredicate(format: "id == %lld", category.id)
        if let obj = try context.fetch(req).first {
            obj.setValue(try encoder.encode(category), forKey: "json")
            try context.save()
        }
    }

    func delete(by id: Int) async throws {
        let req = NSFetchRequest<NSManagedObject>(entityName: "CategoryCD")
        req.predicate = NSPredicate(format: "id == %lld", id)
        for obj in try context.fetch(req) { context.delete(obj) }
        try context.save()
    }
}
