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
            headerView
            filterCard
            operationsHeader
            operationsList
        }
        .padding()
        .background(Color(.systemGray6).ignoresSafeArea())
        .overlay {
            if transactionsStoryViewModel.isLoading {
                ProgressView()
            }
            if let error = transactionsStoryViewModel.error {
                Text("Ошибка: \(error.localizedDescription)")
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(8)
            }
        }
    }

    private var headerView: some View {
        HStack {
            Text("Моя история")
                .font(.system(size: 34, weight: .bold))
            Spacer()
        }
        .padding(.top, 16)
    }

    private var filterCard: some View {
        VStack(spacing: 0) {
            DatePicker("Начало",
                       selection: $transactionsStoryViewModel.startDate,
                       displayedComponents: .date)
                .onChange(of: transactionsStoryViewModel.startDate) { newStart in
                    if newStart > transactionsStoryViewModel.endDate {
                        transactionsStoryViewModel.endDate = newStart
                    }
                    Task { await transactionsStoryViewModel.reloadData() }
                }
                .padding(.top, 5)
                .padding(.bottom, 5)

            Divider()

            DatePicker("Конец",
                       selection: $transactionsStoryViewModel.endDate,
                       displayedComponents: .date)
                .onChange(of: transactionsStoryViewModel.endDate) { newEnd in
                    if newEnd < transactionsStoryViewModel.startDate {
                        transactionsStoryViewModel.startDate = newEnd
                    }
                    Task { await transactionsStoryViewModel.reloadData() }
                }
                .padding(.top, 5)
                .padding(.bottom, 5)

            Divider()

            Picker("Сортировка",
                   selection: $transactionsStoryViewModel.selectedSortOption) {
                ForEach(TransactionsStoryViewModel.SortOption.allCases, id: \.self) { option in
                    Text(option.rawValue)
                }
            }
            .pickerStyle(.segmented)
            .padding(.vertical, 8)

            Divider()

            HStack {
                Text("Сумма")
                Spacer()
                Text(transactionsStoryViewModel.totalAmount
                        .formatted(.currency(code: "RUB")))
            }
            .padding(.bottom, 3)
            .padding(.vertical, 8)
        }
        .padding(.horizontal)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(10)

    }

    private var operationsHeader: some View {
        Text("ОПЕРАЦИИ")
            .font(.caption)
            .foregroundColor(.secondary)
            .padding(.top, 12)
            .padding(.bottom, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 10)
    }

    private var operationsList: some View {
        List {
            ForEach(Array(transactionsStoryViewModel
                            .sortedTransactions
                            .enumerated()), id: \.element.id) { index, transaction in
                TransactionRowView(
                    transaction: transaction,
                    direction: transactionsStoryViewModel.direction
                )
                .listRowInsets(EdgeInsets())
                .listRowBackground(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.white)
                        .padding(.top, index == 0 ? 0 : -16)
                        .padding(.bottom,
                                 index == transactionsStoryViewModel.sortedTransactions.count - 1
                                 ? 0
                                 : -16)
                        .clipShape(Rectangle())
                )
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Color(.systemGray6))
    }
}
