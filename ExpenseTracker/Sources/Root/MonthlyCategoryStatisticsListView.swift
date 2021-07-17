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

struct MonthlyCategoryStatisticsListView: View {
    let items: [MonthlyCategoryStatisticsListItem]
    let listener: Listener

    var body: some View {
        VStack(spacing: 0) {
            ForEach(items) { item in
                MonthlyCategoryStatisticsListItemView(item: item)
                    .onTapGesture { listener.onTapped(item) }
            }
        }
    }
}

extension MonthlyCategoryStatisticsListView {
    struct Listener {
        let onTapped: (MonthlyCategoryStatisticsListItem) -> Void
    }
}

struct MonthlyCategoryStatisticsListView_Previews: PreviewProvider {
    static var previews: some View {
        MonthlyCategoryStatisticsListView(items: [], listener: .init(onTapped: { _ in }))
    }
}
