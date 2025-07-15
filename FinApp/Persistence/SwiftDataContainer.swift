//
//  SwiftDataContainer.swift
//  FinApp
//
//  Created by Даниил Дементьев on 19.07.2025.
//

import Foundation
import SwiftData

protocol JSONCodingSupport { }

extension JSONCodingSupport {
    var encoder: JSONEncoder {
        let jsonEncoder = JSONEncoder()
        jsonEncoder.dateEncodingStrategy = .iso8601
        return jsonEncoder
    }

    var decoder: JSONDecoder {
        let jsonDecoder = JSONDecoder()
        jsonDecoder.dateDecodingStrategy = .iso8601
        return jsonDecoder
    }
}

enum BackupAction: String, Codable {
    case create, update, delete
}

struct BackupTransactionOperation: Identifiable, Codable {
    var id: Int { transaction.id }
    let transaction: Transaction
    let action: BackupAction
}

enum BackupAccountAction: String, Codable {
    case update
}

@Model
final class BankAccountEntity {
    var id: Int
    var json: Data

    init(id: Int, json: Data) {
        self.id = id
        self.json = json
    }
}

@Model
final class CategoryEntity {
    var id: Int
    var json: Data

    init(id: Int, json: Data) {
        self.id = id
        self.json = json
    }
}

@Model
final class TransactionEntity {
    var id: Int
    var json: Data

    init(id: Int, json: Data) {
        self.id = id
        self.json = json
    }
}

@Model
final class BackupAccountEntity {
    var id: Int
    var actionRaw: String
    var json: Data

    init(id: Int, actionRaw: String, json: Data) {
        self.id = id
        self.actionRaw = actionRaw
        self.json = json
    }
}

@Model
final class BackupTransactionEntity {
    var id: Int
    var actionRaw: String
    var json: Data

    init(id: Int, actionRaw: String, json: Data) {
        self.id = id
        self.actionRaw = actionRaw
        self.json = json
    }
}

struct BackupAccountOperation: Identifiable, Codable {
    var id: Int { account.id }
    let account: BankAccount
    let action: BackupAccountAction
}

enum SwiftDataContainer {
    private static var schema: Schema = {
        Schema([
            BankAccountEntity.self,
            CategoryEntity.self,
            TransactionEntity.self,
            BackupAccountEntity.self,
            BackupTransactionEntity.self
        ])
    }()

    static func make() throws -> ModelContainer {
        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )
        return try ModelContainer(for: schema, configurations: [configuration])
    }
}
