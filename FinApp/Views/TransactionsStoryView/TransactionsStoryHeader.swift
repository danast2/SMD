//
//  TransactionsStoryHeader.swift
//  FinApp
//
//  Created by Даниил Дементьев on 20.06.2025.
//

import SwiftUI

struct TransactionsStoryHeader: View {
    var body: some View {
        HStack {
            Text("title.myHistory".localized)
                .font(.largeTitle)
                .bold()
            Spacer()
        }
        .padding(.top, 16)
        .padding(.bottom, 16)
    }
}
