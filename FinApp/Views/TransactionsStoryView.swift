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
        VStack(spacing: 0) {
            HStack {
                Text("Моя история")
                    .font(.system(size: 34, weight: .bold))
                    .padding(.top, 20)
                Spacer()
            }
            .padding(.horizontal)
            .background(Color(.systemGroupedBackground))

            List {
                Section(header: Text("Фильтрация")) {
                    DatePicker("Начало",
                               selection: $transactionsStoryViewModel.startDate,
                               displayedComponents: .date)
                    .onChange(of: transactionsStoryViewModel.startDate) { newStart in
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
                    .onChange(of: transactionsStoryViewModel.endDate) { newEnd in
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
                        TransactionRowView(
                            transaction: transaction,
                            direction: transactionsStoryViewModel.direction
                        )
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color(.systemBackground))
                    }
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(Color(.systemGroupedBackground))
        }
        .background(Color(.systemGroupedBackground))
        .overlay {
            if transactionsStoryViewModel.isLoading {
                ProgressView()
            }
            if let error = transactionsStoryViewModel.error {
                Text("Ошибка: \(error.localizedDescription)")
                    .padding()
                    .background(Color.white)
                    .cornerRadius(8)
            }
        }
    }
}
