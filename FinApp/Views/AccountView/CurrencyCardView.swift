//
//  CurrencyCardView.swift
//  FinApp
//
//  Created by Даниил Дементьев on 23.06.2025.
//

import SwiftUI

struct CurrencyCardView: View {
    let currencyCode: String

    private var currencySymbol: String {
        Currency(rawValue: currencyCode)?.symbol ?? currencyCode
    }

    var body: some View {
        HStack {
            Text("title.currency".localized)
                .font(.system(size: 17, weight: .regular))
            Spacer()
            Text(currencySymbol)
                .font(.system(size: 17, weight: .regular))
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 44, idealHeight: 44)
        .background(Color("NewAccentColor").opacity(0.3))
        .cornerRadius(10)
    }
}
