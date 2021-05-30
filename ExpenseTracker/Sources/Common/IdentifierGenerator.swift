//
//  IdentifierGenerator.swift
//  ExpenseTracker
//
//  Created by yongseongkim on 2021/05/22.
//

import Foundation

class IdentifierGenerator {
    static func generate() -> String {
        return "\(Int(Date().timeIntervalSince1970))-\(UUID().uuidString)"
    }
}
