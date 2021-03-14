//
//  String+Extension.swift
//  ExpenseTracker
//
//  Created by yongseongkim on 2021/03/17.
//

import Foundation

extension String {
    var digits: String {
        return components(separatedBy: CharacterSet.decimalDigits.inverted)
            .joined()
    }
}

extension String: Identifiable {
    public var id: String { self }
}
