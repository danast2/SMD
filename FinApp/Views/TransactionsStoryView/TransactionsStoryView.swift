//
//  TransactionsStoryView.swift
//  FinApp
//
//  Created by Даниил Дементьев on 15.06.2025.
//

import SwiftUI

struct TransactionsStoryView: View {
    @EnvironmentObject var viewModel: TransactionsStoryViewModel
    @State private var showAnalysis = false

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                TransactionsStoryFilterCard()
                TransactionsStoryOperationsHeader()
                TransactionsStoryOperationsList()
            }
            .padding(.horizontal)
            .padding(.bottom)

            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.001))
                    .allowsHitTesting(false)
            }
            if let error = viewModel.error {
                Text("error.title".localized + ": \(error.localizedDescription)")
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(8)
            }
        }
        .sheet(isPresented: $showAnalysis) {
            AnalysisView(viewModel: viewModel)
        }
        .navigationTitle("title.myHistory".localized)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button { showAnalysis = true } label: {
                    Image(systemName: "doc")
                        .foregroundColor(.indigo)
                }
            }
        }
        .background(Color(.systemGray6).ignoresSafeArea())
        .onAppear {
            Task { await viewModel.reloadData() }
        }
    }
}
