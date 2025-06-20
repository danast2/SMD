//
//  TransactionsStoryView.swift
//  FinApp
//
//  Created by Даниил Дементьев on 15.06.2025.
//

import SwiftUI

struct TransactionsStoryView: View {
    @EnvironmentObject var transactionsStoryViewModel: TransactionsStoryViewModel

    var body: some View {
        VStack(spacing: 0) {
            TransactionsStoryHeader()
            TransactionsStoryFilterCard()
            TransactionsStoryOperationsHeader()
            TransactionsStoryOperationsList()
        }
        .padding()
        .background(Color(.systemGray6).ignoresSafeArea())
        .overlay {
            if transactionsStoryViewModel.isLoading {
                ProgressView()
            }
            if let error = transactionsStoryViewModel.error {
                Text("error.title".localized + ": \(error.localizedDescription)")
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(8)
            }
        }
    }
}
