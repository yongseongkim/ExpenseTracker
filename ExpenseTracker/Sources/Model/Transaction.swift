//
//  Transaction.swift
//  ExpenseTracker
//
//  Created by yongseongkim on 2021/04/30.
//

import Foundation

struct Transaction: Identifiable {
    let id: String
    let value: Int
    let currencyCode: String?
    let category: String?
    let title: String?
    let detail: String?
    let tradedAt: Date
    let createdAt: Date

    init(
        id: String? = nil,
        value: Int,
        currencyCode: String?,
        category: String?,
        title: String?,
        detail: String?,
        tradedAt: Date?
    ) {
        self.id = id ?? IdentifierGenerator.generate()
        self.value = value
        self.currencyCode = currencyCode
        self.category = category
        self.title = title
        self.detail = detail
        self.tradedAt = tradedAt ?? Date()
        self.createdAt = Date()
    }

    init(with mo: TransactionMO) {
        self.id = mo.id
        self.value = mo.value
        self.currencyCode = mo.currencyCode
        self.category = mo.category
        self.title = mo.title
        self.detail = mo.detail
        self.tradedAt = mo.tradedAt
        self.createdAt = mo.createdAt
    }
}

extension Transaction {
    var isExpense: Bool { value < 0 }
    var isIncome: Bool { value > 0 }

    var symbol: SFSymbol {
        guard let raw = category else { return Category.etc.symbol }
        return Category(rawValue: raw)?.symbol ?? Category.etc.symbol
    }
}

extension Transaction: CustomStringConvertible {
    var description: String {
        "\(String(describing: category)) \(value) at \(tradedAt): \(String(describing: title)), \(String(describing: detail))"
    }
}
