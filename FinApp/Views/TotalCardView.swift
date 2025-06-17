//
//  TotalCardView.swift
//  FinApp
//
//  Created by Даниил Дементьев on 18.06.2025.
//

import SwiftUI

struct TotalCardView: View {
    let totalAmount: Decimal

    var body: some View {
        HStack {
            Text(String("Всего"))
                .font(.system(size: 17))

            Spacer()

            VStack(alignment: .leading, spacing: 4) {
                Text(totalAmount.formatted(.currency(code: "RUB")))
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(.primary)
            }
        }
        .padding(.vertical, 12)
    }
}
