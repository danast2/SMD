//
//  View+hideKeyboard.swift
//  FinApp
//
//  Created by Даниил Дементьев on 03.07.2025.
//

import SwiftUI

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                        to: nil, from: nil, for: nil)
    }
}
