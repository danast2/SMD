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
            Text("title.total".localized)
                .fontWeight(.regular)
                .padding(.leading, 16)
            Spacer()
            Text("\(totalAmount) ₽")
                .fontWeight(.regular)
                .padding(.trailing, 16)
        }
        .padding(.vertical, 8)
        .frame(height: 44)
        .background(Color.white)
        .cornerRadius(10)
    }
}
