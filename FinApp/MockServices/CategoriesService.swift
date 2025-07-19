//
//  CategoriesService.swift
//  FinApp
//
//  Created by Даниил Дементьев on 09.06.2025.
//

import Foundation

final class CategoriesService {
    private let categories: [Category] = [
        Category(id: 1, name: "Зарплата", emoji: "💵", direction: Direction.income),
        Category(id: 2, name: "Подарок", emoji: "🎁", direction: Direction.income),
        Category(id: 3, name: "Продукты", emoji: "🛒", direction: Direction.outcome),
        Category(id: 4, name: "Развлечения", emoji: "🎮", direction: Direction.outcome)
    ]

    func categories() async throws -> [Category] {
        return categories
    }

    func categories(for direction: Direction) async throws -> [Category] {
        return categories.filter { $0.direction == direction }
    }
}
