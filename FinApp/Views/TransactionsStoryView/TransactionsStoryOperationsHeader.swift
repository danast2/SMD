//
//  TransactionsStoryOperationsHeader.swift
//  FinApp
//
//  Created by Даниил Дементьев on 20.06.2025.
//

import SwiftUI

struct TransactionsStoryOperationsHeader: View {
    var body: some View {
        Text("title.operations".localized)
            .font(.caption)
            .foregroundColor(.secondary)
            .padding(.top, 12)
            .padding(.bottom, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 10)
    }
}
