//
//  TransactionsListContentView.swift
//  FinApp
//
//  Created by Даниил Дементьев on 20.06.2025.
//

import SwiftUI

struct TransactionsListContentView: View {
    @EnvironmentObject var viewModel: TransactionsListViewModel

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
                    .frame(maxHeight: .infinity)
            } else if let error = viewModel.error {
                Text("error.title".localized + ": \(error.localizedDescription)")
                    .multilineTextAlignment(.center)
                    .padding()
                    .frame(maxHeight: .infinity)
            } else {
                TransactionsListLoadedView()
            }
        }
        .background(Color(.systemGroupedBackground))
    }
}
