//
//  FloatingActionButton.swift
//  FinApp
//
//  Created by Даниил Дементьев on 11.07.2025.
//

import SwiftUI

struct FloatingActionButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "plus")
                .font(.system(size: 28, weight: .medium))
                .foregroundStyle(.white)
                .frame(width: 56, height: 56)
                .background(Color("NewAccentColor"))
                .clipShape(Circle())
        }
        .shadow(radius: 4)
        .padding(.bottom, 34 + 12)
        .padding(.trailing, 20)
    }
}
