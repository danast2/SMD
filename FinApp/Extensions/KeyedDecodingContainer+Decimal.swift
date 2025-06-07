//
//  KeyedDecodingContainer+Decimal.swift
//  FinApp
//
//  Created by Даниил Дементьев on 13.06.2025.
//

import Foundation

extension KeyedDecodingContainer {
    func decodeDecimalString(forKey key: Key) throws -> Decimal {
        let string = try self.decode(String.self, forKey: key)
        guard let decimal = Decimal(string: string) else {
            throw DecodingError.dataCorruptedError(forKey: key,
                in: self,
                debugDescription: "Cannot convert string to Decimal")
        }
        return decimal
    }
}
