//
//  MonthlyGridView.swift
//  ExpenseTracker
//
//  Created by yongseongkim on 2021/03/07.
//

import Combine
import SwiftUI

struct MonthlyGridView: View {
    // weekdays applied Calendar's firstWeekDay like "Sun, Mon, ..., Sat" or "Mon, Tue, ..., Sun"
    let weekdays: [String]
    let items: [[MonthlyGridItem]]

    @Binding var selectedDate: Date?

    init(year: UInt, month: UInt, transactions: [Transaction], selectedDate: Binding<Date?>) {
        let weekdaySymbols = DateFormatter().shortWeekdaySymbols!
        let numberOfWeekdays = weekdaySymbols.count
        // firstWeekday: For Gregorian and ISO 8601 calendars, 1 is Sunday.
        self.weekdays = (0..<numberOfWeekdays).map { idx in
            weekdaySymbols[(idx + Calendar.current.firstWeekday - 1) % numberOfWeekdays]
        }
        // Make items like below
        // [space, space, day1, day2, day3, day4, day5]
        // [day6, day7, day8, day9, day10, day11, day12]
        // ...
        // [day31, space, space, space, space, space, space]
        let dateComponents = DateComponents(calendar: Calendar.current, year: Int(year), month: Int(month))
        let date = Calendar.current.date(from: dateComponents)!
        // (1 is Sunday, 2 is Monday ...) >> (Sunday is 0, Monday is 1 ...)
        let beginingOfWeekday = Calendar.current.component(.weekday, from: date) - 1
        let numberOfDays = Calendar.current.range(of: .day, in: .month, for: date)!.count
        let numberOfRows = Int(ceil(Double(numberOfDays + beginingOfWeekday) / 7))
        let transactionsByDate = transactions.arrangedByDate()
        self.items = (0..<numberOfRows).map { row -> [MonthlyGridItem] in
            return (0..<numberOfWeekdays)
                .map { column -> MonthlyGridItem in
                    let day = (row * numberOfWeekdays) + column - beginingOfWeekday + 1
                    if 0 < day, day <= numberOfDays,
                       // Actually Calendar.current.date starts from 1th, so add (day - 1).
                       let date = Calendar.current.date(byAdding: .day, value: day - 1, to: date) {
                        let totalExpense = transactionsByDate[date]?.filter { $0.isExpense }.map { abs($0.value) }.reduce(0, +) ?? 0
                        let totalIncome = transactionsByDate[date]?.filter { $0.isIncome }.map { abs($0.value) }.reduce(0, +) ?? 0
                        return .day(
                            date: date,
                            expense: totalExpense,
                            income: totalIncome,
                            isToday: Calendar.current.isDateInToday(date)
                        )
                    }
                    return .space
                }
        }
        self._selectedDate = selectedDate
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                ForEach(self.weekdays) { weekday in
                    Text(weekday)
                        .font(.system(size: 11))
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.bottom, 7)
            VStack(spacing: 0) {
                ForEach(0..<self.items.count, id: \.self) { row in
                    HStack(spacing: 0) {
                        ForEach(0..<self.items[row].count, id: \.self) { column in
                            MonthlyGridItemView(
                                item: self.items[row][column],
                                isSelected: self.items[row][column].isSame(otherDate: self.selectedDate)
                            )
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .onTapGesture { select(item: self.items[row][column]) }
                        }
                    }
                }
            }
        }
        .foregroundColor(Color.systemBlack)
        .background(Color.systemWhite)
    }

    private func select(item: MonthlyGridItem) {
        if case .day(let date, _, _, _) = item {
            if self.selectedDate == date {
                self.selectedDate = nil
            } else {
                self.selectedDate = date
            }
        }
    }
}

struct MonthlyGridView_Previews: PreviewProvider {
    static let mockTransactions: [Transaction] = [
        .init(
            value: Int.random(in: -100000..<0),
            currencyCode: "KRW",
            category: Category.allCases.randomElement()?.rawValue,
            title: "title",
            detail: "detail",
            tradedAt: DateComponents(calendar: Calendar.current, year: 2021, month: 2, day: 5).date
        ),
        .init(
            value: Int.random(in: 0..<100000),
            currencyCode: "KRW",
            category: Category.allCases.randomElement()?.rawValue,
            title: "title",
            detail: "detail",
            tradedAt: DateComponents(calendar: Calendar.current, year: 2021, month: 2, day: 5).date
        ),
        .init(
            value: Int.random(in: -100000..<0),
            currencyCode: "KRW",
            category: Category.allCases.randomElement()?.rawValue,
            title: "title",
            detail: "detail",
            tradedAt: DateComponents(calendar: Calendar.current, year: 2021, month: 2, day: 13).date
        ),
        .init(
            value: Int.random(in: 0..<100000),
            currencyCode: "KRW",
            category: Category.allCases.randomElement()?.rawValue,
            title: "title",
            detail: "detail",
            tradedAt: DateComponents(calendar: Calendar.current, year: 2021, month: 2, day: 13).date
        ),
        .init(
            value: Int.random(in: -100000..<0),
            currencyCode: "KRW",
            category: Category.allCases.randomElement()?.rawValue,
            title: "title",
            detail: "detail",
            tradedAt: DateComponents(calendar: Calendar.current, year: 2021, month: 2, day: 26).date
        ),
        .init(
            value: Int.random(in: 0..<100000),
            currencyCode: "KRW",
            category: Category.allCases.randomElement()?.rawValue,
            title: "title",
            detail: "detail",
            tradedAt: DateComponents(calendar: Calendar.current, year: 2021, month: 2, day: 18).date
        ),
        .init(
            value: Int.random(in: 0..<100000),
            currencyCode: "KRW",
            category: Category.allCases.randomElement()?.rawValue,
            title: "title",
            detail: "detail",
            tradedAt: DateComponents(calendar: Calendar.current, year: 2021, month: 2, day: 26).date
        )
    ]

    static var previews: some View {
        Group {
            MonthlyGridView(
                year: 2021,
                month: 2,
                transactions: MonthlyGridView_Previews.mockTransactions,
                selectedDate: .constant(DateComponents(calendar: Calendar.current, year: 2021, month: 2, day: 13).date ?? Date())
            )
            .previewLayout(.sizeThatFits)
            .environment(\.colorScheme, .light)
            MonthlyGridView(
                year: 2021,
                month: 5,
                transactions: MonthlyGridView_Previews.mockTransactions,
                selectedDate: .constant(DateComponents(calendar: Calendar.current, year: 2021, month: 5, day: 13).date ?? Date())
            )
            .previewLayout(.sizeThatFits)
            .environment(\.colorScheme, .dark)
        }
    }
}
