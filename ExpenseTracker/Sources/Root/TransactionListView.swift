//
//  TransactionListView.swift
//  ExpenseTracker
//
//  Created by yongseongkim on 2021/03/14.
//

import Combine
import SwiftUI

struct TransactionListView: View {
    let transactionsByDate: [Date: [Transaction]]
    let listener: Listener

    init(transactions: [Transaction], listener: Listener) {
        var transactionsByDate: [Date: [Transaction]] = [:]
        transactions.forEach { t in
            transactionsByDate[Calendar.current.startOfDay(for: t.tradedAt), default: []].append(t)
        }
        self.transactionsByDate = transactionsByDate
        self.listener = listener
    }

    var body: some View {
        List {
            ForEach(Array(transactionsByDate.keys)) { key in
                TransactionListItemDateView(date: key)
                    .frame(height: 50)
                    .listRowInsets(EdgeInsets())
                    .background(Color.systemWhite)
                if let transactions = transactionsByDate[key], !transactions.isEmpty {
                    ForEach(transactions) { transaction in
                        TransactionListItemView(transaction: transaction)
                            .listRowInsets(EdgeInsets())
                            .background(Color.systemWhite)
                            .onTapGesture { listener.onItemSelected(transaction) }
                    }
                    .onDelete { indexSet in
                        indexSet.forEach { listener.onItemDeleted(transactions[$0]) }
                    }
                } else {
                    // TODO: Add Empty view
                }
            }
        }
        .listStyle(PlainListStyle())
        .background(Color.systemWhite)
    }
}

extension TransactionListView {
    struct Listener {
        let onItemSelected: (Transaction) -> Void
        let onItemDeleted: (Transaction) -> Void
    }
}

extension Date: Identifiable {
    public var id: TimeInterval {
        return timeIntervalSince1970
    }
}

struct TransactionListView_Previews: PreviewProvider {
    static var mockList: [Transaction] {
        [
            .init(
                value: -19900,
                currencyCode: "KRW",
                category: Category.gift.rawValue,
                title: "라이엇 게임즈 코리아",
                detail: "나만의 상점 스킨 구입",
                tradedAt: DateComponents(calendar: .current, year: 2021, month: 3, day: 6, hour: 21, minute: 35).date!
            ),
            .init(
                value: -22474,
                currencyCode: "KRW",
                category: Category.gift.rawValue,
                title: "to 김건우",
                detail: "farewell 만찬 더치페이",
                tradedAt: DateComponents(calendar: .current, year: 2021, month: 3, day: 14, hour: 15, minute: 17).date!
            ),
            .init(
                value: -19710,
                currencyCode: "KRW",
                category: Category.etc.rawValue,
                title: "읽어양득",
                detail: "동아리 미션 완료금",
                tradedAt: DateComponents(calendar: .current, year: 2021, month: 3, day: 1, hour: 22, minute: 40).date!
            ),
            .init(
                value: 10000,
                currencyCode: "KRW",
                category: Category.etc.rawValue,
                title: "제스티살룬",
                detail: "와사비 새우 버거 2 + 갈릭 치즈 버거 + 치즈 프라이",
                tradedAt: DateComponents(calendar: .current, year: 2021, month: 3, day: 12, hour: 13, minute: 16).date!
            )
        ]
    }

    static var previews: some View {
        Group {
            TransactionListView(
                transactions: mockList,
                listener: .init(
                    onItemSelected: { _ in },
                    onItemDeleted: { _ in }
                )
            )
            .previewLayout(.sizeThatFits)
            .environment(\.colorScheme, .light)
            TransactionListView(
                transactions: mockList,
                listener: .init(
                    onItemSelected: { _ in },
                    onItemDeleted: { _ in }
                )
            )
            .previewLayout(.sizeThatFits)
            .environment(\.colorScheme, .dark)
        }
    }
}
