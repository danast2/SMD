//
//  AnalisysView.swift
//  FinApp
//
//  Created by Даниил Дементьев on 10.07.2025.
//

import SwiftUI

struct AnalysisView: UIViewControllerRepresentable {
    @ObservedObject var viewModel: TransactionsStoryViewModel

    func makeUIViewController(context: Context) -> AnalysisViewController {
        AnalysisViewController(viewModel: viewModel)
    }

    func updateUIViewController(_ uiViewController: AnalysisViewController, context: Context) { }
}
