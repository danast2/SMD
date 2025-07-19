//
//  KeyedDecodingContainer+Decimal.swift
//  FinApp
//
//  Created by Даниил Дементьев on 13.06.2025.
//

import Foundation

extension KeyedDecodingContainer {
    func decodeDecimalString(forKey key: Key) throws -> Decimal {
        if let str = try? decode(String.self, forKey: key),
           let decimal = Decimal(string: str.replacingOccurrences(of: ",", with: ".")) {
            return decimal
        }
        if let dbl = try? decode(Double.self, forKey: key) {
            return Decimal(dbl)
        }
        if let intVal = try? decode(Int.self, forKey: key) {
            return Decimal(intVal)
        }
        throw DecodingError.dataCorruptedError(
            forKey: key,
            in: self,
            debugDescription: "Value for key \(key) can't be converted to Decimal"
        )
    }
}
