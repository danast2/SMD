//
//  StorageEngine.swift
//  FinApp
//
//  Created by Даниил Дементьев on 19.07.2025.
//

import Foundation

enum StorageEngine: String {
    case swiftdata
    case coredata
}

@inline(__always)
func currentEngine() -> StorageEngine {
    let raw = UserDefaults.standard.string(forKey: "storageType") ?? "swiftdata"
    return StorageEngine(rawValue: raw) ?? .swiftdata
}
