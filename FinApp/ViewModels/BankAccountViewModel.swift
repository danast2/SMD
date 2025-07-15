//
//  BankAccountViewModel.swift
//  FinApp
//
//  Created by Даниил Дементьев on 23.06.2025.
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class BankAccountViewModel: ObservableObject {

    @Published var account: BankAccount?
    @Published var isEditing = false
    @Published var isBalanceHidden = false
    @Published var balanceInput = ""
    @Published var selectedCurrency: String = Currency.rub.rawValue
    @Published var error: Error?
    @Published var isLoading = false

    let didLoad = PassthroughSubject<Void, Never>()

    private let service: any BankAccountServiceProtocol
    private var bag = Set<AnyCancellable>()

    init(service: any BankAccountServiceProtocol) {
        self.service = service
        Task { await loadAccount() }

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
        withAnimation(.easeInOut(duration: 0.3)) {
            isBalanceHidden.toggle()
        }
    }

    func reload() {
        Task { await loadAccount() }
    }

    func toggleEditMode() {
        if isEditing {
            saveChanges()
        } else {
            isEditing = true
            if let account { balanceInput = "\(account.balance)" }
        }
    }

    func loadAccount() async {
        isLoading = true
        defer { isLoading = false }
        do {
            account = try await service.fetchAccount()
            selectedCurrency = account?.currency ?? Currency.rub.rawValue
            didLoad.send()
        } catch {
            self.error = error
        }
    }

    private func saveChanges() {
        guard let oldAccount = account else { return }

        let cleaned = balanceInput
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: ",", with: ".")

        let validPattern = #"^-?\d*\.?\d*$"#
        guard
            cleaned.range(of: validPattern, options: .regularExpression) != nil,
            let newBalance = Decimal(string: cleaned)
        else { return }

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
                await loadAccount()
                isEditing = false
            } catch {
                self.error = error
            }
        }
    }
}
