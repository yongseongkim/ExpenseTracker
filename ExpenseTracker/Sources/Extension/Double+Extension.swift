//
//  Double+Extension.swift
//  ExpenseTracker
//
//  Created by yongseongkim on 2021/05/16.
//

import Foundation

extension Double {
    func roundTo(place: Int) -> Double {
        let divisor = pow(10, Double(place))
        return ((self * divisor).rounded()) / divisor
    }

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
