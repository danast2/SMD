//
//  KeyedEncodingContainer+Decimal.swift
//  FinApp
//
//  Created by Даниил Дементьев on 13.06.2025.
//

import Foundation

extension KeyedEncodingContainer {
    mutating func encodeDecimalString(_ value: Decimal,
                                      forKey key: KeyedEncodingContainer<K>.Key) throws {
        try encode(NSDecimalNumber(decimal: value).stringValue, forKey: key)
    }
}
