//
//  RootContentsView.swift
//  ExpenseTracker
//
//  Created by yongseongkim on 2021/11/15.
//

import SwiftUI

struct RootContentsView: View {
    @ObservedObject var model: RootView.ViewModel

    var body: some View {
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
                .listRowSeparator(.hidden)
            }

            Section {
                // MARK: Chart
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
                .listRowSeparator(.hidden)
                .background(Color.systemWhite)

                // MARK: Categorized Expenses
                ForEach(Array(model.items.prefix(4))) { item in
                    ZStack {
                        MonthlyCategoryStatisticsListItemView(item: item)
                        NavigationLink(
                            destination: MonthlyCategorizedTransactionListView(
                                model: .init(category: item.category, transactionStorage: model.transactionStorage)
                            ),
                            label: { EmptyView() }
                        )
                        .opacity(0) // To hide navigation link arrow.
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
                    .background(Color.systemWhite)
                }

                NavigationLink(
                    destination: MonthlyCategoryStatisticsListView(
                        model: .init(
                            items: model.items,
                            transactionStorage: model.transactionStorage
                        )
                    )
                ) {
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
                // MARK: Calendar
                MonthlyGridView(
                    year: model.currentYearMonth.year,
                    month: model.currentYearMonth.month,
                    transactions: model.transactions,
                    selectedDate: $model.selectedDate
                )
                .listRowInsets(EdgeInsets(top: 20, leading: 0, bottom: 0, trailing: 0))
                .listRowSeparator(.hidden)

                // MARK: Transaction List
                ForEach(model.transactionsBySelectedDate.keys.sorted(by: { $0 > $1})) { date in
                    TransactionListItemDateView(date: date)
                        .frame(height: 50)
                        .listRowInsets(EdgeInsets())
                        .background(Color.systemWhite)

                    if let transactions = model.transactionsBySelectedDate[date], !transactions.isEmpty {
                        ForEach(transactions) { transaction in
                            TransactionListItemView(transaction: transaction)
                                .listRowInsets(EdgeInsets())
                                .listRowSeparator(.hidden)
                                .background(Color.systemWhite)
                                .onTapGesture {
                                    model.editViewPresentation = .edit(
                                        transaction: transaction,
                                        listener: .init(
                                            onCancelled: { model.editViewPresentation = nil },
                                            onConfirmed: {
                                                model.transactionStorage.upsert(transaction: $0)
                                                model.editViewPresentation = nil
                                            }
                                        )
                                    )
                                }
                        }
                        .onDelete { indexSet in
                            indexSet.forEach { model.delete(transaction: transactions[$0]) }
                        }
                    }
                }

                // MARK: Extra Space
                Color.systemWhite.opacity(0)
                    .frame(height: 50)
            }
        }
        .listStyle(PlainListStyle())
        .listRowSeparator(.hidden)
    }
}

struct RootContentsView_Previews: PreviewProvider {
    static var previews: some View {
        RootContentsView(model: .init())
    }
}
