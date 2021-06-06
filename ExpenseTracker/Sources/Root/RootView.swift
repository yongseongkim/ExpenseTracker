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
        ZStack {
            historyLayer
            floatingButtonLayer
        }
        .background(
            EmptyView()
                .sheet(isPresented: $model.isMonthSelectorPrenseted) {
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

    var historyLayer: some View {
        List {
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    HStack(spacing: 5) {
                        Text(model.titleText)
                            .font(.system(size: 24))
                            .fontWeight(.bold)
                        // TODO: update the image.
                        Image(symbol: .arrowtriangleDownFill)
                    }
                    .padding(.leading, 20)
                    .onTapGesture { model.isMonthSelectorPrenseted = true }
                    Spacer()
                }
                .padding(EdgeInsets(top: 30, leading: 0, bottom: 20, trailing: 0))
                MonthlyStatisticsView(transactions: model.transactions)
                    .padding(.bottom, 30)
                MonthlyGridView(
                    year: model.currentYearMonth.year,
                    month: model.currentYearMonth.month,
                    transactionsByDay: model.transactionsByDay,
                    selectedDate: $model.selectedDate
                )
            }
            .listRowInsets(EdgeInsets())
            .background(Color.systemWhite)

            ForEach(model.transactionsBySelectedDay.keys.sorted(by: { $0 > $1})) { day in
                TransactionListItemDateView(
                    date: Calendar.current.date(byAdding: DateComponents(day: day - 1), to: model.firstDateOfMonth) ?? Date()
                )
                .frame(height: 50)
                .listRowInsets(EdgeInsets())
                .background(Color.systemWhite)

                if let transactions = model.transactionsBySelectedDay[day], !transactions.isEmpty {
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
    class ViewModel: ObservableObject {
        @Published var firstDateOfMonth: Date
        @Published var transactions: [Transaction]
        @Published var selectedDate: Date?
        @Published var editViewPresentation: TransactionEditView.Presentation?
        @Published var isMonthSelectorPrenseted: Bool = false

        var titleText: String { titleDateFormatter.string(from: firstDateOfMonth) }
        var currentYearMonth: (year: UInt, month: UInt) {
            let components = Calendar.current.dateComponents([.year, .month], from: firstDateOfMonth)
            return (year: UInt(components.year ?? 0), month: UInt(components.month ?? 0))
        }
        var transactionsByDay: [Int: [Transaction]] {
            var transactionsByDay: [Int: [Transaction]] = [:]
            transactions
                .compactMap { t -> (day: Int, transaction: Transaction)? in
                    guard let day = Calendar.current.dateComponents([.day], from: t.tradedAt).day else { return nil }
                    return (day: day, transaction: t)
                }
                .forEach { transactionsByDay[$0.day, default: []].append($0.transaction) }
            return transactionsByDay
        }
        var transactionsBySelectedDay: [Int: [Transaction]] {
            if let selectedDate = self.selectedDate,
               let selectedDay = Calendar.current.dateComponents([.year, .month, .day], from: selectedDate).day {
                return [selectedDay: transactionsByDay[selectedDay]?.sorted(by: { $0.tradedAt > $1.tradedAt }) ?? []]
            } else {
                return transactionsByDay
            }
        }
        var fromDateForMonthSelector: Date {
            Calendar.current.date(byAdding: DateComponents(year: -4), to: Date()) ?? Date()
        }

        private let transactionStorage: TransactionStorage
        private let titleDateFormatter = DateFormatter().apply { $0.dateFormat = "LLLL, yyyy" }
        private var cancellables: [AnyCancellable] = []

        init() {
            self.transactionStorage = TransactionStorage(persistentController: PersistentController.shared)
            self.firstDateOfMonth = Calendar.current.firstDateOfMonth(date: Date())
            self.transactions = []
            transactionStorage.transactions.sink { [weak self] transactions in
                self?.transactions = transactions
                var expensesByCategory: [Category: Int] = [:]
                transactions
                    .filter { $0.isExpense }
                    .forEach { transaction in
                        expensesByCategory[Category.from(raw: transaction.category), default: 0] += transaction.value
                    }
            }
            .store(in: &cancellables)
        }

        func select(month: Date) {
            firstDateOfMonth = month
            isMonthSelectorPrenseted = false
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