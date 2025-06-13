//
//  BankAccount.swift
//  FinApp
//
//  Created by Даниил Дементьев on 08.06.2025.
//

import Foundation

struct BankAccount: Identifiable, Codable, Hashable {
    let id: Int
    let userId: Int
    let name: String
    let balance: Decimal
    let currency: String
    let createdAt: Date
    let updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case userId
        case name
        case balance
        case currency
        case createdAt
        case updatedAt
    }

    init(id: Int, userId: Int, name: String, balance: Decimal,
         currency: String, createdAt: Date, updatedAt: Date) {
        self.id = id
        self.userId = userId
        self.name = name
        self.balance = balance
        self.currency = currency
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.userId = try container.decode(Int.self, forKey: .userId)
        self.name = try container.decode(String.self, forKey: .name)
        self.balance = try container.decodeDecimalString(forKey: .balance)
        self.currency = try container.decode(String.self, forKey: .currency)
        self.createdAt = try container.decode(Date.self, forKey: .createdAt)
        self.updatedAt = try container.decode(Date.self, forKey: .updatedAt)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.userId, forKey: .userId)
        try container.encode(self.name, forKey: .name)
        try container.encodeDecimalString(self.balance, forKey: .balance)
        try container.encode(self.currency, forKey: .currency)
        try container.encode(self.createdAt, forKey: .createdAt)
        try container.encode(self.updatedAt, forKey: .updatedAt)
    }
}
