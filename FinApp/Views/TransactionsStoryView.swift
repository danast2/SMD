//
//  TransactionsStoryView.swift
//  FinApp
//
//  Created by Даниил Дементьев on 15.06.2025.
//

import SwiftUI

struct TransactionsStoryView: View {
    @ObservedObject var transactionsStoryViewModel: TransactionsStoryViewModel

    var body: some View {
        VStack {
            List {
                Section(header: Text("Фильтрация")) {
                    DatePicker("Начало",
                               selection: $transactionsStoryViewModel.startDate,
                               displayedComponents: .date)
                    .onChange(of:
                                transactionsStoryViewModel.startDate) { newStart in
                        if newStart > transactionsStoryViewModel.endDate {
                            transactionsStoryViewModel.endDate = newStart
                        }
                        Task {
                            await transactionsStoryViewModel.reloadData()
                        }
                    }

                    DatePicker("Конец",
                               selection: $transactionsStoryViewModel.endDate,
                               displayedComponents: .date)
                    .onChange(of:
                                transactionsStoryViewModel.endDate) { newEnd in
                        if newEnd < transactionsStoryViewModel.startDate {
                            transactionsStoryViewModel.startDate = newEnd
                        }
                        Task {
                            await transactionsStoryViewModel.reloadData()
                        }
                    }

                    Picker("Сортировка",
                           selection: $transactionsStoryViewModel.selectedSortOption) {
                        ForEach(
                            TransactionsStoryViewModel.SortOption.allCases,
                            id: \.self) { option in
                                Text(option.rawValue)
                            }
                    }
                           .pickerStyle(.segmented)

                    HStack {
                        Text("Сумма")
                        Spacer()
                        Text(
                            transactionsStoryViewModel.totalAmount.formatted(
                                .currency(code: "RUB")))
                    }
                }

                Section(header: Text("Список операций")) {
                    ForEach(transactionsStoryViewModel.sortedTransactions) { transaction in
                        TransactionRow(
                            transaction: transaction,
                            direction: transactionsStoryViewModel.direction
                        )
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color(.systemBackground))
                    }
                }

            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Операции")
        .overlay {
            if transactionsStoryViewModel.isLoading {
                ProgressView()
            }
            if let error = transactionsStoryViewModel.error {
                Text("Ошибка: \(error.localizedDescription)").padding()
            }
        }
    }
}
