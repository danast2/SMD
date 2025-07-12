//
//  TransactionFormViewModel.swift
//  FinApp
//
//  Created by Даниил Дементьев on 17.06.2025.
//

import Foundation
import SwiftUI

final class TransactionFormViewModel: ObservableObject {

    @Published var categories: [Category] = []
    @Published var selectedCategory: Category?
    @Published var amountString = ""
    @Published var day = Calendar.current.startOfDay(for: Date())
    @Published var time = Date()
    @Published var comment = ""
    @Published var showValidationAlert = false
    @Published var error: Error?
    @Published private(set) var accountBrief: AccountBrief?

    let mode: TransactionFormMode
    let direction: Direction

    private let transactionsService: TransactionsService
    private let categoriesService = CategoriesService()
    private let bankAccountService: BankAccountServiceMock
    private let original: Transaction?
    private let originalCategoryID: Int?

    init(
        mode: TransactionFormMode,
        original: Transaction? = nil,
        direction: Direction,
        transactionsService: TransactionsService,
        bankAccountService: BankAccountServiceMock
    ) {
        self.mode = mode
        self.direction = direction
        self.transactionsService = transactionsService
        self.bankAccountService = bankAccountService
        self.original = original
        self.originalCategoryID = original?.category.id

        if let tr = original {
            amountString = String(describing: tr.amount)
            let cal = Calendar.current
            day = cal.startOfDay(for: tr.transactionDate)
            time = tr.transactionDate
            comment = tr.comment ?? ""
            accountBrief = tr.account
        } else {
            Task { await loadAccount() }
        }

        Task { await loadCategories() }
    }

    private var decSep: String { Locale.current.decimalSeparator ?? "." }

    var isValid: Bool {
        selectedCategory != nil
            && Decimal(string: amountString.replacingOccurrences(of: decSep, with: ".")) != nil
    }

    @MainActor
    func save() async throws {
        guard isValid else {
            showValidationAlert = true
            return
        }

        guard
            let baseCat = selectedCategory,
            let amount = Decimal(string: amountString.replacingOccurrences(of: decSep, with: ".")),
            let account = accountBrief
        else {
            return
        }

        let cal = Calendar.current
        let comps = cal.dateComponents([.hour, .minute, .second], from: time)
        let fullDate = cal.date(
            bySettingHour: comps.hour ?? 0,
            minute: comps.minute ?? 0,
            second: comps.second ?? 0,
            of: day
        ) ?? day

        let trimmed = comment.trimmingCharacters(in: .whitespacesAndNewlines)
        let finalComment = trimmed.isEmpty ? nil : trimmed

        let tx = Transaction(
            id: original?.id ?? Int.random(in: 1...Int.max),
            account: account,
            category: baseCat,
            amount: amount,
            transactionDate: fullDate,
            comment: finalComment,
            createdAt: original?.createdAt ?? Date(),
            updatedAt: Date()
        )

        if mode == .create {
            try await transactionsService.createTransaction(tx)
        } else {
            try await transactionsService.updateTransaction(tx)
        }
    }

    @MainActor
    func delete() async throws {
        guard let id = original?.id else { return }
        try await transactionsService.deleteTransaction(by: id)
    }

    @MainActor
    private func loadCategories() async {
        do {
            let fetched = try await categoriesService.categories(for: direction)
            categories = fetched
            if let origID = originalCategoryID {
                selectedCategory = fetched.first { $0.id == origID }
            }
        } catch {
            self.error = error
        }
    }

    @MainActor
    private func loadAccount() async {
        do {
            let bankAcc = try await bankAccountService.fetchAccount()
            accountBrief = AccountBrief(
                id: bankAcc.id,
                name: bankAcc.name,
                balance: bankAcc.balance,
                currency: bankAcc.currency
            )
        } catch {
            self.error = error
        }
    }
}
