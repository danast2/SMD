//
//  ActionSheetHelperViewModifier.swift
//  FinApp
//
//  Created by Даниил Дементьев on 27.06.2025.
//

import SwiftUI

struct ActionSheetHelperModifier: ViewModifier {
    @Binding var isPresented: Bool
    let title: String
    let items: [ActionSheetItem]
    let tintColor: UIColor

    func body(content: Content) -> some View {
        content.background(
            ActionSheetHelper(
                isPresented: $isPresented,
                title: title,
                items: items,
                tintColor: tintColor
            )
        )
    }
}
