//
//  MonthlyStatisticsView.swift
//  ExpenseTracker
//
//  Created by yongseongkim on 2021/06/02.
//

import Combine
import SwiftUI

struct MonthlyStatisticsView: View {
    static var colors: [Color] = [.blue, .systemGray, .systemGray3, .systemGray5]

    @ObservedObject var model: ViewModel

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                VStack {
                    DonutChart(
                        slideData: Array(model.slideData.prefix(model.maxNumberOfVisibleListItems)),
                        placeholderColor: .systemGray6,
                        innerCircleColor: .systemWhite
                    )
                    .frame(width: 160, height: 160)
                }
                .frame(minWidth: 0, maxWidth: .infinity)
                VStack(spacing: 5) {
                    Text(model.totalExpenseText)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.systemBlack)
                    Text(model.totalIncomeText)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.blue)
                }
                .frame(minWidth: 0, maxWidth: .infinity)
            }
            .padding([.top, .bottom], 15)
            MonthlyCategoryStatisticsListView(
                items: Array(model.items.prefix(model.maxNumberOfVisibleListItems)),
                listener: .init(onTapped: { model.selectedItem = $0 })
            )
            HStack {
                Spacer()
                Text("자세히 보기")
                    .font(.system(size: 16))
                    .onTapGesture { model.showDetail.toggle() }
            }
        }
        .background(
            EmptyView()
                .sheet(item: $model.selectedItem) { item in
                    MonthlyCategorizedTransactionListView(
                        model: .init(category: item.category, transactionStorage: model.transactionStorage)
                    )
                }
        )
        .background(
            EmptyView()
                .sheet(
                    isPresented: $model.showDetail,
                    content: {
                        MonthlyCategoryStatisticsListView(
                            items: model.items,
                            listener: .init(onTapped: { _ in })
                        )
                    }
                )
        )
    }
}

extension MonthlyStatisticsView {
    class ViewModel: ObservableObject {
        @Published var totalExpenseText: String = 0.wonFormatWithSign
        @Published var totalIncomeText: String = 0.wonFormatWithSign
        @Published var slideData: [PieChartSlide.Data] = []
        @Published var items: [MonthlyCategoryStatisticsListItem] = []
        @Published var selectedItem: MonthlyCategoryStatisticsListItem?
        @Published var showDetail: Bool = false

        let transactionStorage: TransactionStorage
        let maxNumberOfVisibleListItems: Int
        var cancellables: [AnyCancellable] = []

        init(transactionStorage: TransactionStorage, maxNumberOfVisibleListItems: Int = Category.allCases.count) {
            self.transactionStorage = transactionStorage
            self.maxNumberOfVisibleListItems = maxNumberOfVisibleListItems
            self.transactionStorage.transactions
                .sink { [weak self] transactions in
                    guard let self = self else { return }
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

                    // Create Donut chart and list.
                    var slideData: [PieChartSlide.Data] = []
                    var listItems: [MonthlyCategoryStatisticsListItem] = []
                    let sortedExpenses = totalExpensesByCategory
                        .sorted { $0.value < $1.value }
                    for (index, element) in sortedExpenses.enumerated() {
                        let category = element.key
                        let expense = element.value
                        let ratio = (Double(expense) / Double(totalExpense)).roundTo(place: 2)
                        let color = MonthlyStatisticsView.colors[index % MonthlyStatisticsView.colors.count]
                        let startDegrees = slideData.last?.endDegrees ?? 0
                        slideData.append(.init(startDegrees: startDegrees, endDegrees: startDegrees + 360 * ratio, color: color))
                        listItems.append(MonthlyCategoryStatisticsListItem(percent: Int(ratio * 100), expense: expense, category: category, color: color))
                    }
                    self.slideData = slideData
                    self.items = listItems
                }
                .store(in: &cancellables)
        }
    }
}

struct MonthlyStatisticsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MonthlyStatisticsView(model: .init(transactionStorage: .shared))
        }
    }
}
