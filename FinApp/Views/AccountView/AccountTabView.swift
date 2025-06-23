//
//  AccountTabView.swift
//  FinApp
//
//  Created by Даниил Дементьев on 20.06.2025.
//

import SwiftUI

struct AccountTabView: View {
    @EnvironmentObject var viewModel: BankAccountViewModel

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    if let account = viewModel.account {
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
                    } else if let error = viewModel.error {
                        Text(error.localizedDescription)
                            .foregroundColor(.red)
                    } else {
                        ProgressView()
                    }
                }
                .padding(.vertical)
            }
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle("title.myAccount".localized)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        viewModel.toggleEditMode()
                    }) {
                        Group {
                            if viewModel.isEditing {
                                Text("title.save".localized)
                            } else {
                                Text("title.edit".localized)
                            }
                        }
                        .foregroundColor(.indigo)
                    }
                }
            }
            .refreshable {
                viewModel.loadAccount()
            }
            .onAppear {
                viewModel.loadAccount()
            }
            .onDisappear {
                NotificationCenter.default.removeObserver(
                    self,
                    name: .deviceDidShakeNotification,
                    object: nil
                )
            }
        }
        .tabItem {
            Label {
                Text(TabType.account.title)
            } icon: {
                TabType.account.icon
            }
        }
    }
}
