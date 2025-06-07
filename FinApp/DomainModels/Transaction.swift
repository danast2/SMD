//
//  Transaction.swift
//  FinApp
//
//  Created by Даниил Дементьев on 08.06.2025.
//

import Foundation

struct Transaction: Identifiable {
    let id: Int
    let accountId: Int
    let categoryId: Int
    let amount: Decimal
    let transactionDate: Date
    let comment: String?
    let createdAt: Date
    let updatedAt: Date
}
