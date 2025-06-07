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

extension Transaction {
    private static let backendDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()

    static func parse(jsonObject: Any) -> Transaction? {
        guard let dict = jsonObject as? [String: Any] else {
            return nil
        }

        guard
            let id = dict["id"] as? Int,
            let accountId = dict["accountId"] as? Int,
            let categoryId = dict["categoryId"] as? Int,
            let amountString = dict["amount"] as? String,
            let amount = Decimal(string: amountString),
            let transactionDateString = dict["transactionDate"] as? String,
            let createdAtString = dict["createdStr"] as? String,
            let updatedAtString = dict["updatedStr"] as? String
        else {
            return nil
        }

        guard
            let transactionDate = backendDateFormatter.date(from: transactionDateString),
            let createdAt = backendDateFormatter.date(from: createdAtString),
            let updatedAt = backendDateFormatter.date(from: updatedAtString)
        else {
            return nil
        }

        return Transaction(
            id: id,
            accountId: accountId,
            categoryId: categoryId,
            amount: amount,
            transactionDate: transactionDate,
            comment: dict["comment"] as? String,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }

    var jsonObject: Any {
        var dict: [String: Any] = [
            "id": id,
            "accountId": accountId,
            "categoryId": categoryId,
            "amount": amount.description,
            "transactionDate": Self.backendDateFormatter.string(from: transactionDate),
            "createdAt": Self.backendDateFormatter.string(from: createdAt),
            "updatedAt": Self.backendDateFormatter.string(from: updatedAt)
        ]

        if let comment = comment {
            dict["comment"] = comment
        }

        return dict
    }
}
