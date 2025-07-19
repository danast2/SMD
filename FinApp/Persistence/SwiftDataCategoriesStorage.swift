//
//  SwiftDataCategoriesStorage.swift
//  FinApp
//
//  Created by Даниил Дементьев on 19.07.2025.
//

import Foundation
import SwiftData

@MainActor
final class SwiftDataCategoriesStorage: CategoriesLocalStorageProtocol, JSONCodingSupport {

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

    func all() async throws -> [Category] {
        try context.fetch(FetchDescriptor<CategoryEntity>())
            .compactMap { try? decoder.decode(Category.self, from: $0.json) }
    }

    func create(_ category: Category) async throws {
        let entity = CategoryEntity(id: category.id, json: try encoder.encode(category))
        context.insert(entity)
        try context.save()
    }

    func update(_ category: Category) async throws {
        let descriptor = FetchDescriptor<CategoryEntity>(
            predicate: #Predicate { $0.id == category.id }
        )
        if let entity = try context.fetch(descriptor).first {
            entity.json = try encoder.encode(category)
            try context.save()
        }
    }

    func delete(by id: Int) async throws {
        let descriptor = FetchDescriptor<CategoryEntity>(
            predicate: #Predicate { $0.id == id }
        )
        for entity in try context.fetch(descriptor) {
            context.delete(entity)
        }
        try context.save()
    }
}
