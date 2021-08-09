//
//  MonthlyGridItemView.swift
//  ExpenseTracker
//
//  Created by yongseongkim on 2021/03/14.
//

import SwiftUI

enum MonthlyGridItem {
    case space
    case day(date: Date, expense: Int, income: Int, isToday: Bool)

    func isSame(otherDate: Date?) -> Bool {
        switch self {
        case .day(let date, _, _, _):
            return otherDate == date
        default:
            return false
        }
    }
}

struct MonthlyGridItemView: View {
    let item: MonthlyGridItem
    let isSelected: Bool
    let formatter = DateFormatter().apply { $0.dateFormat = "dd" }

    init(item: MonthlyGridItem, isSelected: Bool = false) {
        self.item = item
        self.isSelected = isSelected
    }

    var body: some View {
        switch item {
        case .space:
            Color.systemWhite.opacity(0)
        case .day(let date, let expense, let income, let isToday):
            VStack(alignment: .center, spacing: 0) {
                ZStack {
                    if isSelected {
                        Color.blue
                            .cornerRadius(13)
                    }
                    Text(formatter.string(from: date))
                        .font(.system(size: 13))
                        .fontWeight(.bold)
                        .foregroundColor((isToday && !isSelected) ? .blue : .systemBlack)
                }
                .frame(width: 26, height: 26)
                Spacer(minLength: 0)
                content(date: date, expense: expense, income: income)
                Spacer(minLength: 0)
            }
        }
    }

    private func content(date: Date, expense: Int, income: Int) -> some View {
        Group {
            if expense == 0 && income == 0 {
                Text("•")
            } else {
                VStack(alignment: .center, spacing: 1) {
                    if expense != 0 {
                        Text("-\(expense.krwCurrencyFormat)")
                            .lineLimit(1)
                            .font(.system(size: 9))
                    }
                    if income != 0 {
                        Text("+\(income.krwCurrencyFormat)")
                            .lineLimit(1)
                            .font(.system(size: 9))
                            .foregroundColor(.blue)
                    }
                }
                .padding([.leading, .trailing], 3)
            }
        }
    }
}

struct MonthlyGridItemView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MonthlyGridItemView(
                item: .day(
                    date: Date(),
                    expense: 10000,
                    income: 10000,
                    isToday: false
                )
            )
            .previewLayout(.fixed(width: 50, height: 56))
            MonthlyGridItemView(
                item: .day(
                    date: Date(),
                    expense: 10000,
                    income: 10000,
                    isToday: true
                )
            )
            .previewLayout(.fixed(width: 50, height: 56))
            MonthlyGridItemView(
                item: .day(
                    date: Date(),
                    expense: 10000,
                    income: 10000,
                    isToday: false
                ),
                isSelected: true
            )
            .previewLayout(.fixed(width: 50, height: 56))
        }
    }
}
