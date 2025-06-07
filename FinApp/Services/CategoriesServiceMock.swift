//
//  CategoriesServiceMock.swift
//  FinApp
//
//  Created by Даниил Дементьев on 09.06.2025.
//

import Foundation

actor CategoriesServiceMock {

    private let allCategories: [Category] = [
        Category(id: 1, name: "Зарплата", emoji: "💰", isIncome: .income),
        Category(id: 2, name: "Фриланс",  emoji: "🧑‍💻", isIncome: .income),
        Category(id: 3, name: "Продукты", emoji: "🛒", isIncome: .outcome),
        Category(id: 4, name: "Кофе",     emoji: "☕️", isIncome: .outcome),
        Category(id: 5, name: "Путешествия", emoji: "✈️", isIncome: .outcome)
    ]

    func categories() async -> [Category] {
        return allCategories
    }

    func categories(isIncome: Direction) async -> [Category] {
        return allCategories.filter { $0.isIncome == isIncome }
    }
}
