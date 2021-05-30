//
//  Int+Extension.swift
//  ExpenseTracker
//
//  Created by yongseongkim on 2021/05/27.
//

import Foundation

extension Int: Identifiable {
    public var id: Int { self }
}

extension Int {
    func currencyFormat(code: String) -> String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = code
        formatter.currencySymbol = ""
        return formatter.string(from: NSNumber(value: self))
    }

    var krwCurrencyFormat: String {
        currencyFormat(code: "KRW") ?? ""
    }

    var wonFormat: String {
        return "\(abs(self).krwCurrencyFormat) 원"
    }

    var wonFormatWithSign: String {
        let sign = self < 0 ? "-" : "+"
        return "\(sign) \(abs(self).krwCurrencyFormat) 원"
    }
}
