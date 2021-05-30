//
//  TransactionListItemView.swift
//  ExpenseTracker
//
//  Created by yongseongkim on 2021/03/25.
//

import SwiftUI

struct TransactionListItemDateView: View {
    let date: Date
    let dateFormaater = DateFormatter().apply {
        $0.dateFormat = "dd, E"
    }

    var body: some View {
        HStack {
            Text("\(dateFormaater.string(from: date))")
                .font(.system(size: 15))
                .padding([.leading, .trailing], 25)
            Spacer()
        }
        .padding(.top, 20)
    }
}

struct TransactionListItemView: View {
    let transaction: Transaction

    var body: some View {
        HStack(spacing: 0) {
            Image(symbol: transaction.symbol)
                .frame(width: 24, height: 24)
                .padding(10)
                .padding(.trailing, 10)
            VStack(alignment: .leading, spacing: 0) {
                Text(transaction.value.wonFormatWithSign)
                    .font(.system(size: 16))
                    .fontWeight(.bold)
                    .padding(.bottom, 5)
                Text(transaction.title ?? "")
                    .font(.system(size: 13))
                    .padding(.bottom, 2)
                    .foregroundColor(.systemBlack)
                Text(transaction.detail ?? "")
                    .font(.system(size: 13))
            }
            Spacer()
        }
        .padding([.top, .bottom], 6)
        .padding([.leading, .trailing], 15)
    }
}


struct TransactionListItemView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            TransactionListItemView(
                transaction: .init(
                    value: -19900,
                    currencyCode: "KRW",
                    category: Category.entertainment.rawValue,
                    title: "라이엇 게임즈 코리아",
                    detail: "나만의 상점 스킨 구입",
                    tradedAt: DateComponents(calendar: .current, year: 2021, month: 3, day: 6, hour: 21, minute: 35).date!
                )
            )
            TransactionListItemView(
                transaction: .init(
                    value: 19710,
                    currencyCode: "KRW",
                    category: Category.etc.rawValue,
                    title: "읽어양득",
                    detail: "동아리 미션 완료금",
                    tradedAt: DateComponents(calendar: .current, year: 2021, month: 3, day: 1, hour: 22, minute: 40).date!
                )
            )
        }
    }
}
