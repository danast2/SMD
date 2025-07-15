//
//  CategoriesViewModel.swift
//  FinApp
//
//  Created by Даниил Дементьев on 03.07.2025.
//

import SwiftUI

@MainActor
final class CategoriesViewModel: ObservableObject {
    @Published var allCategories: [Category] = []
    @Published var filteredCategories: [Category] = []
    @Published var searchQuery: String = "" {
        didSet {
            filterCategories()
        }
    }
    @Published var error: Error?
    @Published var isLoading = false

    private let service: any CategoriesServiceProtocol

    init(service: any CategoriesServiceProtocol) {
        self.service = service
        Task { await loadCategories() }
    }

    func loadCategories() async {
        isLoading = true
        do {
            let fetched = try await service.categories()
            allCategories = fetched
            filteredCategories = fetched
            isLoading = false
        } catch {
            self.error = error
            self.isLoading = false
        }
    }

    private func filterCategories() {
        let query = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        guard !query.isEmpty else {
            filteredCategories = allCategories
            return
        }

        let filtered = allCategories.filter { category in
            fuzzyMatch(query: query, text: category.name.lowercased())
        }

        filteredCategories = filtered
    }

    private func fuzzyMatch(query: String, text: String) -> Bool {
        if query.isEmpty { return true }

        var queryIndex = query.startIndex
        var textIndex = text.startIndex

        while queryIndex != query.endIndex && textIndex != text.endIndex {
            if query[queryIndex] == text[textIndex] {
                query.formIndex(after: &queryIndex)
            }
            text.formIndex(after: &textIndex)
        }

        return queryIndex == query.endIndex
    }
}
