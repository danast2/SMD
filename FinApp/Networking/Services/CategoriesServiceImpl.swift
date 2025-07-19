//
//  CategoriesServiceImpl.swift
//  FinApp
//
//  Created by Даниил Дементьев on 15.07.2025.
//

import Foundation

@MainActor
final class CategoriesServiceImpl: CategoriesServiceProtocol {

    private let networkClient: NetworkClient
    private let localStorage: CategoriesLocalStorageProtocol

    init(
        networkClient: NetworkClient,
        localStorage: CategoriesLocalStorageProtocol
    ) {
        self.networkClient = networkClient
        self.localStorage = localStorage
    }

    func categories() async throws -> [Category] {
        do {
            let remoteCategories: [Category] = try await networkClient.request(.categories)
            try await persist(remoteCategories)
            return remoteCategories
        } catch {
            let cachedCategories = try await localStorage.all()
            guard !cachedCategories.isEmpty else { throw error }
            return cachedCategories
        }
    }

    func categories(for direction: Direction) async throws -> [Category] {
        let allCategories = try await categories()
        return allCategories.filter { $0.direction == direction }
    }

    private func persist(_ categories: [Category]) async throws {
        let existing = try await localStorage.all().reduce(into: [Int: Category]()) {
            $0[$1.id] = $1
        }
        for category in categories {
            if existing[category.id] == nil {
                try await localStorage.create(category)
            } else {
                try await localStorage.update(category)
            }
        }
    }
}
