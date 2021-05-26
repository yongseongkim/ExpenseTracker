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
            List {
                VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        Text(model.titleText)
                            .font(.system(size: 24))
                            .fontWeight(.bold)
                            .padding(.leading, 20)
                        Spacer()
                        VStack(spacing: 5) {
                            Text(model.totalExpenseText)
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.systemBlack)
                            Text(model.totalIncomeText)
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.blue)
                        }
                        .padding(.trailing, 30)
                    }
                    .padding(EdgeInsets(top: 30, leading: 0, bottom: 20, trailing: 0))
                    MonthlyGridView(
                        year: model.currentYearMonth.year,
                        month: model.currentYearMonth.month,
                        transactionsByDay: model.transactionsByDay,
                        selectedDate: $model.selectedDate
                    )
                }
                .listRowInsets(EdgeInsets())
                .background(Color.systemWhite)

                ForEach(Array(model.transactionsBySelectedDate.keys.sorted(by: { $0 > $1 }))) { key in
                    TransactionListItemDateView(date: key)
                        .frame(height: 50)
                        .listRowInsets(EdgeInsets())
                        .background(Color.systemWhite)
                    if let transactions = model.transactionsByDate[key], !transactions.isEmpty {
                        ForEach(transactions) { transaction in
                            TransactionListItemView(transaction: transaction)
                                .listRowInsets(EdgeInsets())
                                .background(Color.systemWhite)
                                .onTapGesture {
                                    model.editViewPresentation = .edit(
                                        transaction: transaction,
                                        listener: .init(
                                            onFinished: { _ in model.editViewPresentation = nil }
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
                                createdAt: Calendar.current.date(
                                    bySettingHour: currentTime.hour ?? 0,
                                    minute: currentTime.minute ?? 0,
                                    second: currentTime.second ?? 0,
                                    of: model.selectedDate ?? Date()
                                ) ?? Date(),
                                listener: .init(
                                    onFinished: { _ in model.editViewPresentation = nil }
                                )
                            )
                        }
                        .sheet(item: $model.editViewPresentation, content: {
                            TransactionEditView(model: $0.viewModel)
                        })
                }
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 20))
            }
        }
    }
}

extension RootView {
    class ViewModel: ObservableObject {
        @Published var startDateComponentsOfCurrent: DateComponents
        @Published var transactionsByDay: [Int: [Transaction]]
        @Published var transactionsByDate: [Date: [Transaction]]
        @Published var selectedDate: Date?
        @Published var editViewPresentation: TransactionEditView.Presentation?

        var titleText: String {
            titleDateFormatter.string(from: startDateComponentsOfCurrent.date ?? Date())
        }
        var currentYearMonth: (year: UInt, month: UInt) {
            (year: UInt(startDateComponentsOfCurrent.year ?? 0), month: UInt(startDateComponentsOfCurrent.month ?? 0))
        }
        var totalExpenseText: String {
            transactionsByDay.values.flatMap { $0 }.filter { $0.isExpense }.map { $0.value }.reduce(0, +).wonFormatWithSign
        }
        var totalIncomeText: String {
            transactionsByDay.values.flatMap { $0 }.filter { $0.isIncome }.reduce(0, { $0 + abs($1.value) }).wonFormatWithSign
        }
        var transactionsBySelectedDate: [Date: [Transaction]] {
            if let selectedDate = self.selectedDate, let day = Calendar.current.dateComponents([.year, .month, .day], from: selectedDate).day {
                return [selectedDate: transactionsByDay[day]?.sorted(by: { $0.createdAt > $1.createdAt }) ?? []]
            } else {
                return transactionsByDate
            }
        }

        private let titleDateFormatter = DateFormatter().apply { $0.dateFormat = "LLLL, yyyy" }
        private var cancellables: [AnyCancellable] = []

        init() {
            self.startDateComponentsOfCurrent = Calendar.current.dateComponents([.year, .month], from: Date())
            self.transactionsByDay = [:]
            self.transactionsByDate = [:]

            TransactionStorage.shared.transactions.sink { [weak self] transactions in
                var transactionsByDay: [Int: [Transaction]] = [:]
                transactions
                    .compactMap { t -> (day: Int, transaction: Transaction)? in
                        let components = Calendar.current.dateComponents([.year, .month, .day], from: t.createdAt)
                        guard let day = components.day else { return nil }
                        return (day: day, transaction: t)
                    }
                    .forEach { transactionsByDay[$0.day, default: []].append($0.transaction) }
                self?.transactionsByDay = transactionsByDay

                var transactionsByDate: [Date: [Transaction]] = [:]
                transactions.forEach { t in
                    transactionsByDate[Calendar.current.startOfDay(for: t.createdAt), default: []].append(t)
                }
                self?.transactionsByDate = transactionsByDate
            }
            .store(in: &cancellables)
        }

        func delete(transaction: Transaction) {
            TransactionStorage.shared.delete(id: transaction.id)
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
