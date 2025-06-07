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

    func makeSampleTransaction() -> Transaction {
        guard
            let accountBalance = Decimal(string: "1000.00"),
            let amount = Decimal(string: "500.00"),
            let date = isoFormatter.date(from: "2025-06-12T07:13:22Z")
        else {
            XCTFail("Failed to create required test data")
            return Transaction(
                id: -1,
                account: AccountBrief(id: -1, name: "Ошибка", balance: 0, currency: "XXX"),
                category: Category(id: -1, name: "Ошибка", emoji: "❌", direction: .income),
                amount: 0,
                transactionDate: Date(),
                comment: "Ошибка создания",
                createdAt: Date(),
                updatedAt: Date()
            )
        }

        return Transaction(
            id: 42,
            account: AccountBrief(id: 1,
                                  name: "Основной счёт",
                                  balance: accountBalance,
                                  currency: "RUB"),
            category: Category(id: 2,
                               name: "Зарплата",
                               emoji: "💰",
                               direction: .income),
            amount: amount,
            transactionDate: date,
            comment: "Зарплата за месяц",
            createdAt: date,
            updatedAt: date
        )
    }

    func testJSONObjectIsValidJSONObject() {
        let transaction = makeSampleTransaction()
        let json = transaction.jsonObject
        XCTAssertTrue(JSONSerialization.isValidJSONObject(json),
                      "jsonObject должен быть корректным JSON")
    }

    func testParseValidJSONObjectReturnsTransaction() {
        let transaction = makeSampleTransaction()
        guard let json = transaction.jsonObject as? [String: Any] else {
            XCTFail("jsonObject должен быть Dictionary")
            return
        }

        let parsed = Transaction.parse(jsonObject: json)
        XCTAssertNotNil(parsed, "parse(jsonObject:) должен вернуть непустой объект")
        XCTAssertEqual(parsed?.id, transaction.id)
        XCTAssertEqual(parsed?.amount, transaction.amount)
        XCTAssertEqual(parsed?.account.name, transaction.account.name)
        XCTAssertEqual(parsed?.category.name, transaction.category.name)
    }

    func testsJSONObjectParseRoundTrip() {
        let original = makeSampleTransaction()
        let json = original.jsonObject
        let parsed = Transaction.parse(jsonObject: json)
        XCTAssertEqual(parsed, original,
                       "parse(jsonObject:) должен возвращать идентичный объект после jsonObject")
    }

    func testParseInvalidJSONObjectReturnsNil() {
        let badJSON: Any = ["wrongKey": "value"]
        let result = Transaction.parse(jsonObject: badJSON)
        XCTAssertNil(result, "parse должен возвращать nil при некорректных данных")
    }
}
