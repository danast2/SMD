//
//  ActionSheetItem.swift
//  FinApp
//
//  Created by Даниил Дементьев on 27.06.2025.
//

import Foundation

struct ActionSheetItem: Identifiable {
    let id = UUID()
    let title: String
    let action: () -> Void
}
