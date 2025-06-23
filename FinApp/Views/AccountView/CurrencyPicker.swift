//
//  CurrencyPicker.swift
//  FinApp
//
//  Created by Даниил Дементьев on 23.06.2025.
//

import SwiftUI

struct CurrencyPicker: View {
    @Binding var selected: String
    @State private var showingActionSheet = false

    private var selectedCurrency: Currency? {
        Currency(rawValue: selected)
    }

    var body: some View {
        HStack {
            Text("title.currency".localized)
                .font(.system(size: 17, weight: .regular))
            Spacer()

            HStack(spacing: 4) {
                if let currency = selectedCurrency {
                    Text(currency.symbol)
                        .font(.system(size: 17, weight: .regular))
                }

                Image(systemName: "chevron.right")
                    .foregroundColor(.primary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 44, idealHeight: 44)
        .background(Color(.systemGroupedBackground))
        .cornerRadius(10)
        .contentShape(Rectangle())
        .onTapGesture {
            showingActionSheet = true
        }
        .customActionSheet(
            isPresented: $showingActionSheet,
            title: "title.currency".localized,
            items: Currency.allCases.map { currency in
                ActionSheetItem(title: currency.displayTitle) {
                    if selected != currency.rawValue {
                        selected = currency.rawValue
                    }
                }
            },
            tintColor: .systemIndigo
        )
    }
}
