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

struct Category: Identifiable, Codable, Hashable {
    let id: Int
    let name: String
    let emoji: Character
    let direction: Direction

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case emoji
        case isIncome
    }

    init(id: Int, name: String, emoji: Character, direction: Direction) {
        self.id = id
        self.name = name
        self.emoji = emoji
        self.direction = direction
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        let emojiString = try container.decode(String.self, forKey: .emoji)
        guard emojiString.unicodeScalars.count == 1,
              let first = emojiString.first
        else {
            throw DecodingError.dataCorruptedError(
                forKey: .emoji, in: container,
                debugDescription: "Emoji must contain exactly 1 scalar")
        }
        self.emoji = first
        let isIncome = try container.decode(Bool.self, forKey: .isIncome)
        self.direction = isIncome ? .income : .outcome
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.name, forKey: .name)
        try container.encode(String(self.emoji), forKey: .emoji)
        try container.encode(self.direction == .income, forKey: .isIncome)
    }
}
