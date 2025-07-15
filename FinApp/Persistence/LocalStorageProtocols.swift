//
//  LocalStorageProtocols.swift
//  FinApp
//
//  Created by Даниил Дементьев on 18.07.2025.
//

import Foundation

protocol TransactionsLocalStorageProtocol {
    func all() async throws -> [Transaction]
    func create(_ transaction: Transaction) async throws
    func update(_ transaction: Transaction) async throws
    func delete(by id: Int) async throws
}

protocol AccountsLocalStorageProtocol {
    func all() async throws -> [BankAccount]
    func create(_ account: BankAccount) async throws
    func update(_ account: BankAccount) async throws
    func delete(by id: Int) async throws
}

protocol CategoriesLocalStorageProtocol {
    func all() async throws -> [Category]
    func create(_ category: Category) async throws
    func update(_ category: Category) async throws
    func delete(by id: Int) async throws
}
