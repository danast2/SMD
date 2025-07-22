//
//  AccountTabView.swift
//  FinApp
//
//  Created by Даниил Дементьев on 20.06.2025.
//

import SwiftUI

struct AccountTabView: View {
    @EnvironmentObject private var viewModel: BankAccountViewModel

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    switch (viewModel.account, viewModel.error) {
                    case let (account?, _):
                        mainContent(for: account)
                    case let (_, error?):
                        Text(error.localizedDescription)
                            .foregroundColor(.red)
                    default:
                        EmptyView()
                    }
                }
                .padding(.vertical)
            }
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle("title.myAccount".localized)
            .toolbar { editToolbar }
            .refreshable {
                viewModel.reload()
            }
            .task {
                viewModel.reload()
            }
            .alert("Ошибка",
                   isPresented:
                    .constant(viewModel.error != nil),
                   presenting: viewModel.error) { _ in
                Button("OK", role: .cancel) { }
            } message: { error in
                Text(error.localizedDescription)
            }
        }
        .loading(viewModel.isLoading)
        .tabItem {
            Label {
                Text(TabType.account.title)
            } icon: {
                TabType.account.icon
            }
        }
    }

    @ViewBuilder
    private func mainContent(for account: BankAccount) -> some View {
        VStack(spacing: 16) {
            if viewModel.isEditing {
                EditableBalanceCard(balanceText: $viewModel.balanceInput)
                CurrencyPicker(selected: $viewModel.selectedCurrency)
            } else {
                BalanceCardView(
                    balance: account.balance,
                    currencyCode: account.currency,
                    isHidden: viewModel.isBalanceHidden
                )
                CurrencyCardView(currencyCode: account.currency)
            }
        }
        .padding(.horizontal)
    }

    private var editToolbar: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button(action: { viewModel.toggleEditMode() }) {
                Text(
                    viewModel.isEditing
                    ? "title.save".localized
                    : "title.edit".localized
                )
                .foregroundColor(.indigo)
            }
        }
    }
}
