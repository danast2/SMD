//
//  TransactionsStoryFilterCard.swift
//  FinApp
//
//  Created by Даниил Дементьев on 20.06.2025.
//

import SwiftUI

struct TransactionsStoryFilterCard: View {
    @ObservedObject var viewModel: TransactionsStoryViewModel

    var body: some View {
        VStack(spacing: 0) {
            DatePicker("title.start".localized,
                       selection: $viewModel.startDate,
                       displayedComponents: .date)
                .onChange(of: viewModel.startDate) { newStart in
                    if newStart > viewModel.endDate {
                        viewModel.endDate = newStart
                    }
                    Task { await viewModel.reloadData() }
                }
                .padding(.vertical, 5)

            Divider()

            DatePicker("title.end".localized,
                       selection: $viewModel.endDate,
                       displayedComponents: .date)
                .onChange(of: viewModel.endDate) { newEnd in
                    if newEnd < viewModel.startDate {
                        viewModel.startDate = newEnd
                    }
                    Task { await viewModel.reloadData() }
                }
                .padding(.vertical, 5)

            Divider()

            Picker("title.sort".localized, selection: $viewModel.selectedSortOption) {
                ForEach(TransactionsStoryViewModel.SortOption.allCases, id: \.self) { option in
                    Text(option.localizedTitle)
                }
            }
            .pickerStyle(.segmented)
            .padding(.vertical, 8)

            Divider()

            HStack {
                Text("title.summ".localized)
                Spacer()
                Text(viewModel.totalAmount.formatted(.currency(code: "RUB")))
            }
            .padding(.vertical, 8)
        }
        .padding(.horizontal)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(10)
    }
}
