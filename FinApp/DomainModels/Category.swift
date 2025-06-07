//
//  Category.swift
//  FinApp
//
//  Created by Даниил Дементьев on 08.06.2025.
//

enum Direction: String, Codable {
    case income
    case outcome
}

struct Category: Identifiable, Codable {
    let id: Int
    let name: String
    let emoji: Character
    let isIncome: Direction

    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case emoji
        case isIncome
    }

    init(from decoder: Decoder) throws {
        let s = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try s.decode(Int.self, forKey: .id)
        self.name = try s.decode(String.self, forKey: .name)

        let emojiStr = try s.decode(String.self, forKey: .emoji)
        guard let first = emojiStr.first else {
            throw DecodingError.dataCorruptedError(forKey: .emoji, in: s, debugDescription: "предупреждение: строка с emoji пустая")
        }
        self.emoji = first

        let IsIncome = try s.decode(Bool.self, forKey: .isIncome)
        if IsIncome{
            self.isIncome = .income
        } else {
            self.isIncome = .outcome
        }    }

    func encode(to encoder: Encoder) throws {
        var s = encoder.container(keyedBy: CodingKeys.self)
        try s.encode(id, forKey: .id)
        try s.encode(name, forKey: .name)
        try s.encode(String(emoji), forKey: .emoji)
        try s.encode(isIncome == .income, forKey: .isIncome)
    }
}
