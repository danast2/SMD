//
//  KeyedEncodingContainer+Decimal.swift
//  FinApp
//
//  Created by Даниил Дементьев on 13.06.2025.
//

import Foundation

extension KeyedEncodingContainer {
    mutating func encodeDecimalString(_ value: Decimal, forKey key: Key) throws {
        try self.encode(value.description, forKey: key)
    }
}
