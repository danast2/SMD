//
//  TransactionsFileCache.swift
//  FinApp
//
//  Created by Даниил Дементьев on 08.06.2025.
//

import Foundation

enum TransactionsFileCacheError: Error {
    case serializationFailed
    case invalidJSONStructure
}

final class TransactionsFileCache {
    private let fileURL: URL
    private(set) var transactions: [Transaction] = []

    init(fileURL: URL) {
        self.fileURL = fileURL
    }

    func add(_ transaction: Transaction) {
        transactions.removeAll { $0.id == transaction.id }
        transactions.append(transaction)
    }

    func remove(by id: Int) {
        transactions.removeAll { $0.id == id }
    }

    func save() throws {
        let objects = transactions.map { $0.jsonObject }

        guard JSONSerialization.isValidJSONObject(objects),
              let data = try? JSONSerialization.data(withJSONObject: objects) else {
            throw TransactionsFileCacheError.serializationFailed
        }

        try data.write(to: fileURL)
    }

    func load() throws {
        let data = try Data(contentsOf: fileURL)
        let json = try JSONSerialization.jsonObject(with: data)

        guard let array = json as? [Any] else {
            throw TransactionsFileCacheError.invalidJSONStructure
        }

        var uniqueTransactions: [Transaction] = []
        for item in array {
            if let transaction = Transaction.parse(jsonObject: item),
               !uniqueTransactions.contains(where: { $0.id == transaction.id }) {
                uniqueTransactions.append(transaction)
            }
        }

        transactions = uniqueTransactions
    }
}
