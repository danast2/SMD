//
//  TransactionRowView.swift
//  FinApp
//
//  Created by Даниил Дементьев on 18.06.2025.
//

import SwiftUI

struct TransactionRowView: View {
    let transaction: Transaction
    let direction: Direction

    var body: some View {
        HStack(spacing: 12) {
            Text(String(transaction.category.emoji))
                .font(.system(size: 17))

            VStack(alignment: .leading, spacing: 2) {
                Text(transaction.category.name)
                    .font(.system(size: 17))
                    .foregroundColor(.primary)

                if let comment = transaction.comment, !comment.isEmpty {
                    Text(comment)
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                }
            }

            Spacer()

            Text(transaction.amount.formatted(.currency(code: "RUB")))
                .font(.system(size: 17))
                .foregroundColor(.black)
        }
        .padding(.vertical, 12)
    }
}
