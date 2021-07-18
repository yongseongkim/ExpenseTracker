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
                contentsLayer
                floatingButtonLayer
            }
            .navigationBarHidden(true)
        }
        .background(
            EmptyView()
                .sheet(isPresented: $model.isMonthSelectorPresented) {
                    MonthSelectorView(
                        model: .init(
                            from: model.fromDateForMonthSelector,
                            current: model.firstDateOfMonth
                        ),
                        listener: .init(
                            onSelected: { model.select(month: $0) }
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

    var contentsLayer: some View {
        List {
            Section {
                HStack(spacing: 0) {
                    Text(model.titleText)
                        .font(.system(size: 24))
                        .fontWeight(.bold)
                        .padding(.leading, 20)
                        .onTapGesture { model.isMonthSelectorPresented = true }
                    Spacer()
                }
                .listRowInsets(EdgeInsets())
                .padding(EdgeInsets(top: 20, leading: 0, bottom: 10, trailing: 0))
            }

            Section {
                HStack {
                    VStack {
                        DonutChart(
                            slideData: Array(model.slideData.prefix(4)),
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
                .listRowInsets(EdgeInsets())
                .background(Color.systemWhite)

                ForEach(Array(model.items.prefix(4))) { item in
                    ZStack {
                        MonthlyCategoryStatisticsListItemView(item: item)
                        NavigationLink(
                            destination: MonthlyCategorizedTransactionListView(
                                model: .init(category: item.category, transactionStorage: .shared)
                            ),
                            label: { EmptyView() }
                        )
                        .opacity(0) // To hide navigation link arrow.
                    }
                    .listRowInsets(EdgeInsets())
                    .background(Color.systemWhite)
                }

                NavigationLink(destination: MonthlyCategorizedTransactionListView(model: .init(category: .etc, transactionStorage: .shared))) {
                    HStack {
                        Spacer()
                        Text("자세히 보기")
                            .font(.system(size: 14))
                    }
                }
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 20))
                .buttonStyle(PlainButtonStyle())
            }

            Section {
                MonthlyGridView(
                    year: model.currentYearMonth.year,
                    month: model.currentYearMonth.month,
                    transactions: model.transactions,
                    selectedDate: $model.selectedDate
                )
                .listRowInsets(EdgeInsets(top: 20, leading: 0, bottom: 0, trailing: 0))

                ForEach(model.transactionsBySelectedDate.keys.sorted(by: { $0 > $1})) { date in
                    TransactionListItemDateView(date: date)
                        .frame(height: 50)
                        .listRowInsets(EdgeInsets())
                        .background(Color.systemWhite)

                    if let transactions = model.transactionsBySelectedDate[date], !transactions.isEmpty {
                        ForEach(transactions) { transaction in
                            TransactionListItemView(transaction: transaction)
                                .listRowInsets(EdgeInsets())
                                .background(Color.systemWhite)
                                .onTapGesture {
                                    model.editViewPresentation = .edit(
                                        transaction: transaction,
                                        listener: .init(
                                            onCancelled: { model.editViewPresentation = nil },
                                            onConfirmed: { _ in model.editViewPresentation = nil }
                                        )
                                    )
                                }
                        }
                        .onDelete { indexSet in
                            indexSet.forEach { model.delete(transaction: transactions[$0]) }
                        }
                    }
                }
            }
        }
        .listStyle(PlainListStyle())
    }

    var floatingButtonLayer: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Image(symbol: .plus)
                    .resizable()
                    .frame(width: 24, height: 24)
                    .padding(10)
                    .background(Color.gray)
                    .cornerRadius(22)
                    .onTapGesture {
                        let currentTime = Calendar.current.dateComponents([.hour, .minute, .second], from: Date())
                        model.editViewPresentation = .new(
                            tradedAt: Calendar.current.date(
                                bySettingHour: currentTime.hour ?? 0,
                                minute: currentTime.minute ?? 0,
                                second: currentTime.second ?? 0,
                                of: model.selectedDate ?? Date()
                            ) ?? Date(),
                            listener: .init(
                                onCancelled: { model.editViewPresentation = nil },
                                onConfirmed: { _ in model.editViewPresentation = nil }
                            )
                        )
                    }
            }
            .padding(EdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 20))
        }
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
