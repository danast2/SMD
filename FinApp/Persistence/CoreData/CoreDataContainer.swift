//
//  CoreDataContainer.swift
//  FinApp
//
//  Created by Даниил Дементьев on 19.07.2025.
//

import Foundation
import CoreData

enum CoreDataContainer {

    static func make(inMemory: Bool = false) throws -> NSPersistentContainer {
        guard
            let modelURL = Bundle.main.url(forResource: "StorageModel", withExtension: "momd"),
            let model    = NSManagedObjectModel(contentsOf: modelURL)
        else { throw NSError(domain: "CoreData",
                             code: 1,
                             userInfo: [NSLocalizedDescriptionKey: "Model not found"]) }

        let container = NSPersistentContainer(name:
                                                "StorageModel", managedObjectModel: model)

        if inMemory {
            let store = NSPersistentStoreDescription()
            store.type = NSInMemoryStoreType
            container.persistentStoreDescriptions = [store]
        }

        var loadError: Error?
        container.loadPersistentStores { _, err in loadError = err }
        if let loadError { throw loadError }

        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.automaticallyMergesChangesFromParent = true

        return container
    }
}
