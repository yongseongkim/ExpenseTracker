//
//  Calendar+Extension.swift
//  ExpenseTracker
//
//  Created by yongseongkim on 2021/05/16.
//

import Foundation

extension Calendar {
    func firstDateOfMonth(date: Date) -> Date {
        let components = Calendar.current.dateComponents([.year, .month], from: date)
        return Calendar.current.date(from: components)!
    }

    func lastDateOfMonth(date: Date) -> Date {
        let components = DateComponents(month: 1, day: -1)
        return Calendar.current.date(byAdding: components, to: firstDateOfMonth(date: date))!
    }
}
