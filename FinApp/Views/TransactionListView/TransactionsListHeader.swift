//
//  TransactionsListHeader.swift
//  FinApp
//
//  Created by Даниил Дементьев on 20.06.2025.
//

import SwiftUI

struct TransactionsListHeader: View {
    let direction: Direction

    var body: some View {
        HStack {
            Text(direction == .outcome
                 ? "title.todayExpenses".localized
                 : "title.todayIncome".localized)
                .font(.largeTitle)
                .bold()
            Spacer()
        }
        .padding(.top, 16)
    }
}
