//
//  Array+Extension.swift
//  ExpenseTracker
//
//  Created by yongseongkim on 2021/07/18.
//

import Foundation

extension Array where Element == Transaction {
    func arrangedByDate() -> [Date: [Transaction]] {
        var transactionsByDate: [Date: [Transaction]] = [:]
        self
            .map { (Calendar.current.startOfDay(for: $0.tradedAt), $0) }
            .forEach { transactionsByDate[$0.0, default: []].append($0.1) }
        return transactionsByDate
    }
}
