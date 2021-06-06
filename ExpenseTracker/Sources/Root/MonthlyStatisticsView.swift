//
//  MonthlyStatisticsView.swift
//  ExpenseTracker
//
//  Created by yongseongkim on 2021/06/02.
//

import SwiftUI

struct MonthlyStatisticsListItem: Identifiable, Equatable {
    let id = UUID()
    let percent: Int
    let expense: Int
    let category: Category
    let color: Color
}

struct MonthlyStatisticsView: View {
    static var colors: [Color] = [.blue, .systemGray, .systemGray3, .systemGray5]

    let totalExpenseText: String
    let totalIncomeText: String
    let slideData: [PieChartSlide.Data]
    let listItems: [MonthlyStatisticsListItem]

    init(transactions: [Transaction], maxNumberOfCategories: Int = 4) {
        let totalExpense = transactions.filter { $0.isExpense }.map { $0.value }.reduce(0, +)
        let totalIncome = transactions.filter { $0.isIncome }.map { $0.value }.reduce(0, +)
        self.totalExpenseText = totalExpense.wonFormatWithSign
        self.totalIncomeText = totalIncome.wonFormatWithSign
        var totalExpensesByCategory: [Category: Int] = [:]
        transactions
            .filter { $0.isExpense }
            .forEach { transaction in
                totalExpensesByCategory[Category.from(raw: transaction.category), default: 0] += transaction.value
            }
        var slideData: [PieChartSlide.Data] = []
        var listItems: [MonthlyStatisticsListItem] = []
        for (index, element) in totalExpensesByCategory.sorted { $0.value < $1.value }.prefix(maxNumberOfCategories).enumerated() {
            let category = element.key
            let expense = element.value
            let ratio = (Double(expense) / Double(totalExpense)).roundTo(place: 2)
            let color = MonthlyStatisticsView.colors[index % MonthlyStatisticsView.colors.count]
            let startDegrees = slideData.last?.endDegrees ?? 0
            slideData.append(.init(startDegrees: startDegrees, endDegrees: startDegrees + 360 * ratio, color: color))
            listItems.append(MonthlyStatisticsListItem(percent: Int(ratio * 100), expense: expense, category: category, color: color))
        }
        self.slideData = slideData
        self.listItems = listItems
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                VStack {
                    DonutChart(
                        slideData: slideData,
                        placeholderColor: .systemGray6,
                        innerCircleColor: .systemWhite
                    )
                    .frame(width: 160, height: 160)
                }
                .frame(minWidth: 0, maxWidth: .infinity)
                VStack(spacing: 5) {
                    Text(totalExpenseText)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.systemBlack)
                    Text(totalIncomeText)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.blue)
                }
                .frame(minWidth: 0, maxWidth: .infinity)
            }
            .padding([.top, .bottom], 15)
            ForEach(listItems) {
                MonthlyStatisticsListItemView(item: $0)
            }
        }
    }
}

struct MonthlyStatisticsListItemView: View {
    let item: MonthlyStatisticsListItem

    var body: some View {
        HStack(alignment: .center, spacing: 15) {
            item.color
                .cornerRadius(4)
                .frame(width: 16, height: 16)
            VStack(alignment: .leading, spacing: 1) {
                Text(item.category.displayName)
                    .font(.system(size: 16, weight: .bold))
                Text("\(item.percent)% | \(item.expense.wonFormat)")
                    .font(.system(size: 15))
            }
            Spacer()
        }
        .padding([.leading, .trailing], 20)
        .padding([.top, .bottom], 10)
    }
}

struct MonthlyStatisticsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MonthlyStatisticsView(transactions: TransactionListView_Previews.mockList)
                .previewLayout(.sizeThatFits)
            MonthlyStatisticsListItemView(
                item: .init(
                    percent: 40,
                    expense: 1681940,
                    category: .entertainment,
                    color: .systemGray2
                )
            )
            .previewLayout(.sizeThatFits)
        }
    }
}
