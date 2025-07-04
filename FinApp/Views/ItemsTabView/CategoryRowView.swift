//
//  CategoryRowView.swift
//  FinApp
//
//  Created by Даниил Дементьев on 03.07.2025.
//

import SwiftUI

struct CategoryRowView: View {
    let category: Category

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color("NewAccentColor").opacity(0.65))
                    .frame(width: 30, height: 30)
                Text(String(category.emoji))
                    .font(.system(size: 14))
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(category.name)
                    .font(.system(size: 17))
                    .foregroundColor(.black)
            }

            Spacer()
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .frame(height: 44)
        .contentShape(Rectangle())
    }
}
