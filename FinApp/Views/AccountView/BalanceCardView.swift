//
//  BalanceCardView.swift
//  FinApp
//
//  Created by Даниил Дементьев on 23.06.2025.
//

import SwiftUI

struct BalanceCardView: View {
    let balance: Decimal
    let currencyCode: String
    let isHidden: Bool

    private var currencySymbol: String {
        Currency(rawValue: currencyCode)?.symbol ?? currencyCode
    }

    @State private var localHidden: Bool = false

    private static let balanceFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 5
        return formatter
    }()

    var body: some View {
        HStack {
            Text("💰 " + "title.balance".localized)
                .font(.system(size: 17, weight: .regular))
            Spacer()

            let formattedBalance = BalanceCardView.balanceFormatter.string(
                from: balance as NSDecimalNumber
            ) ?? "0"

            Text("\(formattedBalance) \(currencySymbol)")
                .spoiler(isOn: .constant(isHidden))
                .accessibilityHidden(isHidden)
                .font(.system(size: 17, weight: .regular))
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 44, idealHeight: 44)
        .background(Color("NewAccentColor"))
        .cornerRadius(10)
    }
}
