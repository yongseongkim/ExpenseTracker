//
//  MonthlyGridView.swift
//  ExpenseTracker
//
//  Created by yongseongkim on 2021/03/07.
//

import SwiftUI

extension DateFormatter: KotlinCompatible {}

extension String: Identifiable {
    public var id: String { self }
}

struct MonthlyGridItem {
    let date: Date?
}

struct MonthlyGridItemView: View {
    let date: Date
    let expense: Int
    let income: Int
    let formatter: DateFormatter

    init(date: Date, expense: Int = 0, income: Int = 0) {
        self.date = date
        self.expense = expense
        self.income = income
        self.formatter = DateFormatter().apply { $0.dateFormat = "dd" }
    }

    var body: some View {
        VStack {
            Text(formatter.string(from: date))
                .font(.system(size: 13))
                .fontWeight(.bold)
            Spacer()
            content()
            Spacer()
        }
    }

    private func content() -> some View {
        Group {
            if expense == 0 && income == 0 {
                Text("•")
            } else {
                VStack {
                    if expense > 0 {
                        Text("-\(expense)")
                            .lineLimit(1)
                            .font(.system(size: 9))
                    }
                    if income > 0 {
                        Text("+\(income)")
                            .lineLimit(1)
                            .font(.system(size: 9))
                            .foregroundColor(.blue)
                    }
                }
                .padding([.leading, .trailing], 3)
                .frame(maxWidth: .infinity)
            }
        }
    }
}

struct MonthlyGridView<EmptyView, ItemView>: View where EmptyView: View, ItemView: View {
    private let emptyView: () -> EmptyView
    private let itemView: (Date) -> ItemView
    private let weekdays: [String]
    private let items: [[MonthlyGridItem]]

    init(
        year: Int, month: Int,
        @ViewBuilder emptyView: @escaping () -> EmptyView,
        @ViewBuilder itemView: @escaping (Date) -> ItemView
    ) {
        self.emptyView = emptyView
        self.itemView = itemView
        let weekdays = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        let numberOfWeekdays = weekdays.count
        self.weekdays = (0..<numberOfWeekdays).map { idx in
            weekdays[(idx + Calendar.current.firstWeekday - 1) % numberOfWeekdays]
        }
        let components = DateComponents(
            calendar: Calendar.current,
            year: year,
            month: month
        )
        let date = Calendar.current.date(from: components)!
        // 1 is Sunday, 2 is Monday ... >> Sunday is 0, Monday is 1 ...
        let beginingOfWeekday = Calendar.current.component(.weekday, from: date) - 1
        let numberOfDays = Calendar.current.range(of: .day, in: .month, for: date)!.count
        let numberOfRows = Int(ceil(Double(numberOfDays + beginingOfWeekday) / 7))
        self.items = (0..<numberOfRows).map { row -> [MonthlyGridItem] in
            return (0..<7).map { column -> MonthlyGridItem in
                let idx = row * 7 + column
                if beginingOfWeekday <= idx,
                   idx < numberOfDays + beginingOfWeekday,
                   let date = Calendar.current.date(byAdding: .day, value: idx - beginingOfWeekday, to: date) {
                    return MonthlyGridItem(date: date)
                }
                return MonthlyGridItem(date: nil)
            }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                ForEach(weekdays) { weekday in
                    Text("\(weekday)")
                        .font(.system(size: 11))
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.bottom, 10)
            VStack(spacing: 0) {
                ForEach(0..<items.count) { row in
                    HStack(spacing: 0) {
                        ForEach(0..<items[row].count) { column in
                            Group {
                                if let item = items[row][column], let date = item.date {
                                    itemView(date)
                                } else {
                                    emptyView()
                                }
                            }
                            .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
            }
        }
    }
}

struct MonthlyGridView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MonthlyGridView(
                year: 2021,
                month: 2,
                emptyView: { Color.white },
                itemView: { date in
                    MonthlyGridItemView(
                        date: date,
                        expense: Int.random(in: 0...1000000),
                        income: Int.random(in: 0...1000000)
                    )
                }
            )
            .previewLayout(.sizeThatFits)
            MonthlyGridView(
                year: 2021,
                month: 3,
                emptyView: { Color.white },
                itemView: { date in
                    MonthlyGridItemView(
                        date: date,
                        expense: Int.random(in: 0...1000000),
                        income: Int.random(in: 0...1000000)
                    )
                }
            )
            .previewLayout(.sizeThatFits)
            MonthlyGridView(
                year: 2021,
                month: 4,
                emptyView: { Color.white },
                itemView: { date in
                    MonthlyGridItemView(
                        date: date,
                        expense: Int.random(in: 0...1000000),
                        income: Int.random(in: 0...1000000)
                    )
                }
            )
            .previewLayout(.sizeThatFits)
        }
    }
}
