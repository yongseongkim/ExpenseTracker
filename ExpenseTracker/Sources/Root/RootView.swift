//
//  RootView.swift
//  ExpenseTracker
//
//  Created by yongseongkim on 2021/03/07.
//

import Combine
import SwiftUI

struct RootView: View {
    @ObservedObject var model: ViewModel

    var body: some View {
        NavigationView {
            ZStack {
                RootContentsView(model: model)
                RootFloatingButtonView(model: model)
            }
            .navigationBarHidden(true)
        }
        .accentColor(.systemBlack)
        .background(
            EmptyView()
                .sheet(isPresented: $model.isMonthSelectorPresented) {
                    MonthSelectorView(
                        model: .init(
                            from: model.fromDateForMonthSelector,
                            current: model.firstDateOfMonth
                        ),
                        listener: .init(
                            onSelected: { model.select(month: $0) },
                            onCanceled: { model.isMonthSelectorPresented = false }
                        )
                    )
                }
        )
        .background(
            EmptyView()
                .fullScreenCover(item: $model.editViewPresentation) {
                    TransactionEditView(model: $0.viewModel)
                }
        )
    }
}

extension RootView {
    static var statisticsColors: [Color] = [.blue, .systemGray, .systemGray3, .systemGray5]

    class ViewModel: ObservableObject {
        @Published var firstDateOfMonth: Date = Calendar.current.firstDateOfMonth(date: Date())
        @Published var transactions: [Transaction] = []
        @Published var selectedDate: Date?
        @Published var editViewPresentation: TransactionEditView.Presentation?
        @Published var isMonthSelectorPresented: Bool = false

        @Published var totalExpenseText: String = 0.wonFormatWithSign
        @Published var totalIncomeText: String = 0.wonFormatWithSign
        @Published var slideData: [PieChartSlide.Data] = []
        @Published var items: [MonthlyCategoryStatisticsListItem] = []

        var titleText: String { titleDateFormatter.string(from: firstDateOfMonth) }
        var currentYearMonth: (year: UInt, month: UInt) {
            let components = Calendar.current.dateComponents([.year, .month], from: firstDateOfMonth)
            return (year: UInt(components.year ?? 0), month: UInt(components.month ?? 0))
        }
        var transactionsBySelectedDate: [Date: [Transaction]] {
            let transactionsByDate = transactions.arrangedByDate()
            if let selectedDate = self.selectedDate {
                return [selectedDate: transactionsByDate[selectedDate]?.sorted(by: { $0.tradedAt > $1.tradedAt }) ?? []]
            } else {
                return transactionsByDate
            }
        }
        var fromDateForMonthSelector: Date {
            Calendar.current.date(byAdding: DateComponents(year: -4), to: Date()) ?? Date()
        }

        let transactionStorage: TransactionStorage
        private let titleDateFormatter = DateFormatter().apply { $0.dateFormat = "LLLL, yyyy" }
        private var cancellables: [AnyCancellable] = []

        init() {
            self.transactionStorage = TransactionStorage(persistentController: PersistentController.shared)
            self.transactionStorage.transactions.sink { [weak self] transactions in
                guard let self = self else { return }
                self.transactions = transactions

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
                    let color = RootView.statisticsColors[index % RootView.statisticsColors.count]
                    let startDegrees = slideData.last?.endDegrees ?? 0
                    slideData.append(.init(startDegrees: startDegrees, endDegrees: startDegrees + 360 * ratio, color: color))
                    listItems.append(MonthlyCategoryStatisticsListItem(percent: Int(ratio * 100), expense: expense, category: category, color: color))
                }
                self.slideData = slideData
                self.items = listItems
            }
            .store(in: &cancellables)
        }

        func select(month: Date) {
            firstDateOfMonth = month
            isMonthSelectorPresented = false
            transactionStorage.fetchRange = .init(
                from: Calendar.current.firstDateOfMonth(date: month),
                to: Calendar.current.date(byAdding: DateComponents(month: 1), to: month) ?? month
            )
        }

        func delete(transaction: Transaction) {
            transactionStorage.delete(id: transaction.id)
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            RootView(model: .init())
                .environment(\.colorScheme, .light)
            RootView(model: .init())
                .environment(\.colorScheme, .dark)
        }
    }
}
