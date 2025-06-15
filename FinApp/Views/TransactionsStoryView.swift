//
//  TransactionsStoryView.swift
//  FinApp
//
//  Created by Даниил Дементьев on 15.06.2025.
//

import SwiftUI

struct TransactionsStoryView: View {
    let direction: Direction

    @State private var startDate = Calendar.current.date(
        byAdding: .month,
        value: -1,
        to: Date()) ?? Date()
    @State private var endDate = Date()
    @State private var transactions: [Transaction] = []
    @State private var totalAmount: Decimal = 0
    @State private var isLoading = false
    @State private var error: Error?

    enum SortOption: String, CaseIterable {
        case byDate = "По Дате"
        case byAmount = "По Сумме"
    }

    @State private var selectedSortOption: SortOption = .byDate

    private let transactionsService = TransactionsService()

    var body: some View {
        VStack {
            List {
                Section(header: Text("Фильтрация")) {
                    DatePicker("Начало", selection: $startDate, displayedComponents: .date)
                        .onChange(of: startDate) { newStart in
                            if newStart > endDate {
                                endDate = newStart
                            }
                        }

                    DatePicker("Конец", selection: $endDate, displayedComponents: .date)
                        .onChange(of: endDate) { newEnd in
                            if newEnd < startDate {
                                startDate = newEnd
                            }
                        }

                    Picker("Сортировка", selection: $selectedSortOption) {
                        ForEach(SortOption.allCases, id: \.self) { option in
                            Text(option.rawValue)
                        }
                    }
                    .pickerStyle(.segmented)

                    HStack {
                        Text("Сумма")
                        Spacer()
                        Text(totalAmount.formatted(.currency(code: "RUB")))
                    }

                }

                Section(header: Text("Список операций")) {
                    ForEach(sortedTransactions) { transaction in
                        HStack {
                            Text(String(transaction.category.emoji))
                                .font(.largeTitle)
                                .padding(.trailing, 8)

                            VStack(alignment: .leading) {
                                Text(transaction.category.name)
                                    .font(.headline)

                                if let comment = transaction.comment, !comment.isEmpty {
                                    Text(comment)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                            }

                            Spacer()

                            Text(transaction.amount.formatted(
                                .currency(code: transaction.account.currency)))
                            .foregroundColor(direction == .income ? .green : .red)
                        }
                    }
                }
            }
        }
        .listStyle(.grouped)
        .task(id: startDate) {
            isLoading = true
            error = nil

            do {
                let calendar = Calendar.current
                let startOfPeriod = calendar.startOfDay(for: startDate)
                var components = DateComponents()
                components.day = 1
                let endOfPeriod = calendar.startOfDay(for: endDate)
                let periodEnd = calendar.date(
                    byAdding: .day,
                    value: 1,
                    to: endOfPeriod
                ) ?? endOfPeriod

                let all = try await transactionsService.fetchTransactions(
                    from: startOfPeriod,
                    to: periodEnd
                )
                transactions = all.filter { $0.category.direction == direction }
                totalAmount = transactions.reduce(0) { $0 + $1.amount }
            } catch {
                self.error = error
            }

            isLoading = false
        }
        .task(id: endDate) {
            isLoading = true
            error = nil

            do {
                let calendar = Calendar.current
                let startOfPeriod = calendar.startOfDay(for: startDate)
                var components = DateComponents()
                components.day = 1
                let endOfPeriod = calendar.startOfDay(for: endDate)
                let periodEnd = calendar.date(
                    byAdding: .day,
                    value: 1,
                    to: endOfPeriod) ?? endOfPeriod

                let all = try await transactionsService.fetchTransactions(
                    from: startOfPeriod,
                    to: periodEnd)
                transactions = all.filter { $0.category.direction == direction }
                totalAmount = transactions.reduce(0) { $0 + $1.amount }
            } catch {
                self.error = error
            }

            isLoading = false
        }
    }

    var sortedTransactions: [Transaction] {
        transactions.sorted(by: { lhs, rhs in
            switch selectedSortOption {
            case .byDate:
                return lhs.transactionDate < rhs.transactionDate
            case .byAmount:
                return lhs.amount > rhs.amount
            }
        })
    }
}

struct TransactionsStoryView_Previews: PreviewProvider {
    static var previews: some View {
        TransactionsStoryView(direction: .income)
    }
}
