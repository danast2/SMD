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
        let decoderContainer = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try decoderContainer.decode(Int.self, forKey: .id)
        self.name = try decoderContainer.decode(String.self, forKey: .name)

        let emojiStr = try decoderContainer.decode(String.self, forKey: .emoji)
        guard let first = emojiStr.first else {
            throw DecodingError.dataCorruptedError(forKey: .emoji, in: decoderContainer, debugDescription: "предупреждение: строка с emoji пустая")
        }
        self.emoji = first

        let IsIncome = try decoderContainer.decode(Bool.self, forKey: .isIncome)
        if IsIncome{
            self.isIncome = .income
        } else {
            self.isIncome = .outcome
        }
    }

    func encode(to encoder: Encoder) throws {
        var encoderContainer = encoder.container(keyedBy: CodingKeys.self)
        try encoderContainer.encode(id, forKey: .id)
        try encoderContainer.encode(name, forKey: .name)
        try encoderContainer.encode(String(emoji), forKey: .emoji)
        try encoderContainer.encode(isIncome == .income, forKey: .isIncome)
    }

    init(id: Int, name: String, emoji: Character, isIncome: Direction) {
        self.id = id
        self.name = name
        self.emoji = emoji
        self.isIncome = isIncome
    }
}
