//
//  String+localized.swift
//  FinApp
//
//  Created by Даниил Дементьев on 20.06.2025.
//

import Foundation

extension String {
    var localized: String {
        NSLocalizedString(self, comment: "")
    }
}
