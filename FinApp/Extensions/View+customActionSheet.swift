//
//  View+customActionSheet.swift
//  FinApp
//
//  Created by Даниил Дементьев on 27.06.2025.
//

import SwiftUI

extension View {
    func customActionSheet(
        isPresented: Binding<Bool>,
        title: String,
        items: [ActionSheetItem],
        tintColor: UIColor = .systemBlue
    ) -> some View {
        self.modifier(
            ActionSheetHelperModifier(
                isPresented: isPresented,
                title: title,
                items: items,
                tintColor: tintColor
            )
        )
    }
}
