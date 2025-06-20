//
//  TransactionsStoryFilterCard.swift
//  FinApp
//
//  Created by Даниил Дементьев on 20.06.2025.
//

import SwiftUI

struct TransactionsStoryFilterCard: View {
    @EnvironmentObject var viewModel: TransactionsStoryViewModel

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("title.start".localized)
                    .font(.system(size: 16))
                Spacer()
                DatePicker(
                    "",
                    selection: $viewModel.startDate,
                    displayedComponents: .date
                )
                .datePickerStyle(.compact)
                .labelsHidden()
                .frame(minWidth: 100)
                .background(Color("NewAccentColor").opacity(0.65))
                .cornerRadius(8)
                .foregroundColor(.black)
                .onChange(of: viewModel.startDate) { newStart in
                    if newStart > viewModel.endDate {
                        viewModel.endDate = newStart
                    }
                    Task { await viewModel.reloadData() }
                }
            }
            .padding(.vertical, 5)

            Divider()

            HStack {
                Text("title.end".localized)
                    .font(.system(size: 16))
                Spacer()
                DatePicker(
                    "",
                    selection: $viewModel.endDate,
                    displayedComponents: .date
                )
                .datePickerStyle(.compact)
                .labelsHidden()
                .frame(minWidth: 100)
                .background(Color("NewAccentColor").opacity(0.65))
                .cornerRadius(8)
                .foregroundColor(.black)
                .onChange(of: viewModel.endDate) { newEnd in
                    if newEnd < viewModel.startDate {
                        viewModel.startDate = newEnd
                    }
                    Task { await viewModel.reloadData() }
                }
            }
            .padding(.vertical, 5)

            Divider()

            Picker("title.sort".localized,
                   selection: $viewModel.selectedSortOption) {
                ForEach(TransactionsStoryViewModel.SortOption.allCases,
                        id: \.self) { option in
                    Text(option.localizedTitle)
                }
            }
            .pickerStyle(.segmented)
            .padding(.vertical, 8)

            Divider()

            HStack {
                Text("title.summ".localized)
                    .font(.system(size: 16))
                Spacer()
                Text(viewModel.totalAmount
                        .formatted(.currency(code: "RUB")))
                    .font(.system(size: 16))
            }
            .padding(.vertical, 8)
        }
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(10)
    }
}
