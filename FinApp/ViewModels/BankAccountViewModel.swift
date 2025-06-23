//
//  BankAccountViewModel.swift
//  FinApp
//
//  Created by Даниил Дементьев on 23.06.2025.
//

import Foundation
import SwiftUI

final class BankAccountViewModel: ObservableObject {
    @Published var account: BankAccount?
    @Published var isEditing = false
    @Published var isBalanceHidden = false
    @Published var balanceInput = ""
    @Published var selectedCurrency: String = Currency.rub.rawValue
    @Published var error: Error?

    private let service: BankAccountServiceMock

    init(service: BankAccountServiceMock) {
        self.service = service

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didShake),
            name: .deviceDidShakeNotification,
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(
            self,
            name: .deviceDidShakeNotification,
            object: nil
        )
    }

    @objc private func didShake() {
        handleShake()
    }

    func loadAccount() {
        Task {
            do {
                let fetched = try await service.fetchAccount()

                await MainActor.run {
                    self.account = fetched
                    self.selectedCurrency = fetched.currency
                }
            } catch {
                await MainActor.run {
                    self.error = error
                }
            }
        }
    }

    func saveChanges() {
        guard let oldAccount = account else { return }

        let cleaned = balanceInput
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: ",", with: ".")

        let validNumberPattern = #"^-?\d*\.?\d*$"#
        if cleaned.range(of: validNumberPattern, options: .regularExpression) != nil,
           let newBalance = Decimal(string: cleaned) {
            let updated = BankAccount(
                id: oldAccount.id,
                userId: oldAccount.userId,
                name: oldAccount.name,
                balance: newBalance,
                currency: selectedCurrency,
                createdAt: oldAccount.createdAt,
                updatedAt: Date()
            )

            Task {
                do {
                    try await service.updateAccount(updated)

                    await MainActor.run {
                        self.account = updated
                        self.isEditing = false
                    }
                } catch {
                    await MainActor.run {
                        self.error = error
                    }
                }
            }
        }
    }

    func toggleEditMode() {
        if isEditing {
            saveChanges()
        } else {
            isEditing = true
            if let account = account {
                balanceInput = "\(account.balance)"
            }
        }
    }

    func handleShake() {
        withAnimation(.easeInOut(duration: 0.3)) {
            isBalanceHidden.toggle()
        }
    }
}
