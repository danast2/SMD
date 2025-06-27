//
//  EditableBalanceCard.swift
//  FinApp
//
//  Created by Даниил Дементьев on 23.06.2025.
//

import SwiftUI

struct EditableBalanceCard: View {
    @Binding var balanceText: String

    var body: some View {
        HStack {
            Text("💰 " + "title.balance".localized)
                .font(.system(size: 17, weight: .regular))
            Spacer()
            TextField("0", text: $balanceText)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .font(.system(size: 17, weight: .regular))
                .onChange(of: balanceText) { newValue in
                    
                    let replaced = newValue.replacingOccurrences(of: ",", with: ".")
                    var filtered = replaced.filter { "0123456789.-".contains($0) }
                    if filtered.contains("-") {
                        filtered.removeAll { $0 == "-" }
                        filtered.insert("-", at: filtered.startIndex)
                    }

                    var dotCount = 0
                    filtered = filtered.reduce(into: "") { result, char in
                        if char == "." {
                            dotCount += 1
                            if dotCount == 1 {
                                result.append(char)
                            }
                        } else {
                            result.append(char)
                        }
                    }

                    balanceText = filtered
                }
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 44, idealHeight: 44)
        .background(Color(.systemGroupedBackground))
        .cornerRadius(10)
    }
}
