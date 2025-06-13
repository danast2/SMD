//
//  FinAppTests.swift
//  FinAppTests
//
//  Created by Даниил Дементьев on 12.06.2025.
//

import XCTest
@testable import FinApp

final class TransactionTests: XCTestCase {

    private let isoFormatter = ISO8601DateFormatter()

    // MARK: - Test Data Setup

    func makeSampleTransaction(
        id: Int = 42,
        account: FinApp.AccountBrief? = nil,
        category: FinApp.Category? = nil,
        amount: Decimal? = nil,
        transactionDate: Date? = nil,
        comment: String? = "Зарплата за месяц",
        createdAt: Date? = nil,
        updatedAt: Date? = nil
    ) -> Transaction {
        guard let defaultDate = isoFormatter.date(from: "2025-06-12T07:13:22Z") else {
            XCTFail("Failed to create required test data")
            return Transaction(
                id: -1,
                account: AccountBrief(id: -1,
                                      name: "Ошибка",
                                      balance: 0,
                                      currency: "XXX"),
                category: Category(id: -1,
                                   name: "Ошибка",
                                   emoji: "❌",
                                   direction: .income),
                amount: 0,
                transactionDate: Date(),
                comment: "Ошибка создания",
                createdAt: Date(),
                updatedAt: Date()
            )
        }
        let defaultAccount = AccountBrief(
            id: 1,
            name: "Основной счёт",
            balance: Decimal(1000.00),
            currency: "RUB"
        )
        let defaultCategory = Category(
            id: 2,
            name: "Зарплата",
            emoji: "💰",
            direction: .income
        )

        return Transaction(
            id: id,
            account: account ?? defaultAccount,
            category: category ?? defaultCategory,
            amount: amount ?? Decimal(500.00),
            transactionDate: transactionDate ?? defaultDate,
            comment: comment,
            createdAt: createdAt ?? defaultDate,
            updatedAt: updatedAt ?? defaultDate
        )
    }

    // MARK: - JSON Object Tests

    func testJSONObjectValues() {
        let transaction = makeSampleTransaction()
        let json = transaction.jsonObject

        guard let dict = json as? [String: Any] else {
            XCTFail("jsonObject должен быть словарем")
            return
        }

        // Проверяем account
        if let accountDict = dict["account"] as? [String: Any] {
            XCTAssertEqual(accountDict["name"] as? String, transaction.account.name)
            XCTAssertEqual(accountDict["balance"] as? String,
                           String(describing: transaction.account.balance))
            XCTAssertEqual(accountDict["currency"] as? String, transaction.account.currency)
        } else {
            XCTFail("Отсутствует account")
        }

        // Проверяем category
        if let categoryDict = dict["category"] as? [String: Any] {
            XCTAssertEqual(categoryDict["id"] as? Int, transaction.category.id)
            XCTAssertEqual(categoryDict["name"] as? String, transaction.category.name)
            XCTAssertEqual(categoryDict["emoji"] as? String,
                           String(transaction.category.emoji))
            XCTAssertEqual(categoryDict["isIncome"] as? Bool,
                           transaction.category.direction == .income)
        } else {
            XCTFail("Отсутствует category")
        }
    }

    func testJSONObjectWithNilComment() {
        let transaction = makeSampleTransaction(comment: nil)
        let json = transaction.jsonObject

        guard let dict = json as? [String: Any] else {
            XCTFail("jsonObject должен быть словарем")
            return
        }

        XCTAssertNil(dict["comment"],
                     "comment должен быть nil")
    }

    // MARK: - Parsing Tests

    func testParseValidTransaction() {
        let transaction = makeSampleTransaction()
        guard let json = transaction.jsonObject as? [String: Any] else {
            XCTFail("jsonObject должен быть Dictionary")
            return
        }

        let parsed = Transaction.parse(jsonObject: json)
        XCTAssertNotNil(parsed,
                        "Должен парситься валидный JSON")

        XCTAssertEqual(parsed?.comment, transaction.comment)
        XCTAssertEqual(parsed?.createdAt, transaction.createdAt)
        XCTAssertEqual(parsed?.updatedAt, transaction.updatedAt)
    }

    func testParseWithEmptyComment() {
        let transaction = makeSampleTransaction(comment: nil)
        guard let json = transaction.jsonObject as? [String: Any] else {
            XCTFail("jsonObject должен быть Dictionary")
            return
        }

        let parsed = Transaction.parse(jsonObject: json)
        XCTAssertNil(parsed?.comment, "Комментарий должен быть nil")
    }

    func testParseWithDifferentAmountFormats() {
        let amounts = [
            "500.00",
            "500",
            "0.01",
            "999999.99",
            "1000000"
        ]

        for amountString in amounts {
            guard let amount = Decimal(string: amountString) else {
                XCTFail("Не удалось создать Decimal из \(amountString)")
                continue
            }

            let transaction = makeSampleTransaction(amount: amount)
            guard let json = transaction.jsonObject as? [String: Any] else {
                XCTFail("jsonObject должен быть Dictionary")
                return
            }

            let parsed = Transaction.parse(jsonObject: json)
            XCTAssertEqual(parsed?.amount, amount,
                         "Не совпадает amount для строки \(amountString)")
        }
    }

    // MARK: - Round Trip Testing

    func testJSONObjectParseRoundTrip() {
        let original = makeSampleTransaction()
        let json = original.jsonObject
        let parsed = Transaction.parse(jsonObject: json)
        XCTAssertEqual(parsed, original,
                     "parse(jsonObject:) должен возвращать идентичный объект после jsonObject")
    }

    func testRoundTripWithNilComment() {
        let original = makeSampleTransaction(comment: nil)
        let json = original.jsonObject
        let parsed = Transaction.parse(jsonObject: json)
        XCTAssertEqual(parsed, original,
                     "Должен корректно обрабатывать nil comment")
    }
}
