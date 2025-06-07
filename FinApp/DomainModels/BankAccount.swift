//
//  BankAccount.swift
//  FinApp
//
//  Created by Даниил Дементьев on 08.06.2025.
//

import Foundation

struct BankAccount: Identifiable, Codable {
    let id: Int
    let userId: Int
    let name: String
    let balance: Decimal
    let currency: String
    let createdAt: Date
    let updatedAt: Date

    private enum CodingKeys: String, CodingKey {
        case id
        case userId
        case name
        case balance
        case currency
        case createdAt
        case updatedAt
    }

    init(from decoder: Decoder) throws {
        let decoderContainer = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try decoderContainer.decode(Int.self, forKey: .id)
        self.userId = try decoderContainer.decode(Int.self, forKey: .userId)
        self.name = try decoderContainer.decode(String.self, forKey: .name)
        let balanceString = try decoderContainer.decode(String.self, forKey: .balance)
        guard let tempBalance = Decimal(string: balanceString) else {
            throw DecodingError.dataCorruptedError(forKey: .balance, in: decoderContainer, debugDescription: "Invalid Decimal")
        }
        self.balance = tempBalance
        self.currency = try decoderContainer.decode(String.self, forKey: .currency)

        let iso = ISO8601DateFormatter()
        let createdAtString = try decoderContainer.decode(String.self, forKey: .createdAt)
        guard let createdAtData = iso.date(from: createdAtString) else {
            throw DecodingError.dataCorruptedError(forKey: .createdAt, in: decoderContainer, debugDescription: "Bad ISO-8601 date")
        }
        self.createdAt = createdAtData

        let updatedAtString = try decoderContainer.decode(String.self, forKey: .updatedAt)
        guard let updatedAtData = iso.date(from: updatedAtString) else {
            throw DecodingError.dataCorruptedError(forKey: .updatedAt, in: decoderContainer, debugDescription: "Bad ISO-8601 date")
        }
        self.updatedAt = updatedAtData
    }

    func encode(to encoder: Encoder) throws {
        var encoderContainer = encoder.container(keyedBy: CodingKeys.self)
        try encoderContainer.encode(userId, forKey: .userId)
        try encoderContainer.encode(name, forKey: .name)
        try encoderContainer.encode(balance, forKey: .balance)
        try encoderContainer.encode(currency, forKey: .currency)
        let iso = ISO8601DateFormatter()
        try encoderContainer.encode(iso.string(from: createdAt), forKey: .createdAt)
        try encoderContainer.encode(iso.string(from: updatedAt), forKey: .updatedAt)
    }

    init (id: Int, userId: Int, name: String, balance: Decimal, currency: String, createdAt: Date, updatedAt: Date) {
        self.id = id
        self.userId = userId
        self.name = name
        self.balance = balance
        self.currency = currency
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

