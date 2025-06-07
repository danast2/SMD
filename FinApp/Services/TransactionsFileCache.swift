//
//  TransactionsFileCache.swift
//  FinApp
//
//  Created by Даниил Дементьев on 08.06.2025.
//

import Foundation

final class TransactionsFileCache {
    private let fileURL: URL
    private var storage: [Int: Transaction] = [:]
    private var transactions: [Transaction] {
        Array(storage.values).sorted { $0.id < $1.id }
    }

    init(fileName: String = "transactions.json") {
        let docs = FileManager.default.urls(for: .documentDirectory,
                                            in: .userDomainMask).first!
        self.fileURL = docs.appendingPathComponent(fileName)
    }

    func remove(id: Int) {
        storage.removeValue(forKey: id)
    }

    func removeAll() {
        storage.removeAll()
    }

    func save(to url: URL? = nil) throws -> URL {
        let path = url ?? fileURL
        let objects = transactions.map { $0.jsonObject }
        let data = try JSONSerialization.data(withJSONObject: objects, options: [.prettyPrinted])
        try data.write(to: path, options: .atomic)
        return path
    }

    func load(from url: URL? = nil) throws -> Int {
        let path = url ?? fileURL
        guard FileManager.default.fileExists(atPath: path.path) else { return 0 }

        let data = try Data(contentsOf: path)
        let json = try JSONSerialization.jsonObject(with: data)

        guard let array = json as? [Any] else {
            throw NSError(domain: "TransactionsFileCache", code: 1, userInfo: [NSLocalizedDescriptionKey: "Root JSON is not array"])
        }

        var loaded = 0
        for obj in array {
            if let tx = Transaction.parse(jsonObject: obj) {
                storage[tx.id] = tx
                loaded += 1
            }
        }
        return loaded
    }

    func add(_ transaction: Transaction) {
        storage[transaction.id] = transaction
    }
}
