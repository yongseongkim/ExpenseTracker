//
//  MonthlyCategoryStatisticsListView.swift
//  ExpenseTracker
//
//  Created by yongseongkim on 2021/07/17.
//

import SwiftUI

struct MonthlyCategoryStatisticsListItem: Identifiable, Equatable {
    let id = UUID()
    let percent: Int
    let expense: Int
    let category: Category
    let color: Color
}

struct MonthlyCategoryStatisticsListItemView: View {
    let item: MonthlyCategoryStatisticsListItem

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

struct MonthlyCategoryStatisticsListItemView_Previews: PreviewProvider {
    static var previews: some View {
        MonthlyCategoryStatisticsListItemView(item: .init(percent: 30, expense: 17900, category: .beauty, color: .blue))
    }
}

struct MonthlyCategoryStatisticsListView: View {
    @ObservedObject var model: ViewModel

    var body: some View {
        List {
            ForEach(model.items) { item in
                ZStack {
                    MonthlyCategoryStatisticsListItemView(item: item)
                    NavigationLink(
                        destination: MonthlyCategorizedTransactionListView(
                            model: .init(
                                category: item.category,
                                transactionStorage: model.transactionStorage
                            )
                        ),
                        label: { EmptyView() }
                    )
                    .opacity(0) // To hide navigation link arrow.
                }
                .listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)
                .background(Color.systemWhite)
            }

        }
        .listStyle(PlainListStyle())
        .navigationTitle("이달의 소비 카테고리")
    }
}

extension MonthlyCategoryStatisticsListView {
    class ViewModel: ObservableObject {
        let items: [MonthlyCategoryStatisticsListItem]
        let transactionStorage: TransactionStorage

        init(items: [MonthlyCategoryStatisticsListItem], transactionStorage: TransactionStorage) {
            print(items.count)
            self.items = items
            self.transactionStorage = transactionStorage
        }
    }
}
