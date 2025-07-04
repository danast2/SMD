//
//  CategoriesViewModel.swift
//  FinApp
//
//  Created by Даниил Дементьев on 03.07.2025.
//

import SwiftUI

final class CategoriesViewModel: ObservableObject {
    @Published var allCategories: [Category] = []
    @Published var filteredCategories: [Category] = []
    @Published var searchQuery: String = "" {
        didSet {
            filterCategories()
        }
    }
    @Published var error: Error?

    private let service: CategoriesService

    init(service: CategoriesService) {
        self.service = service
        loadCategories()
    }

    func loadCategories() {
        Task {
            do {
                let fetched = try await service.categories()
                await MainActor.run {
                    self.allCategories = fetched
                    self.filteredCategories = fetched
                }
            } catch {
                await MainActor.run {
                    self.error = error
                }
            }
        }
    }

    private func filterCategories() {
        let query = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        guard !query.isEmpty else {
            DispatchQueue.main.async {
                self.filteredCategories = self.allCategories
            }
            return
        }

        let filtered = allCategories.filter { category in
            fuzzyMatch(query: query, text: category.name.lowercased())
        }

        DispatchQueue.main.async {
            self.filteredCategories = filtered
        }
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
