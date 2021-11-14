//
//  MonthlyCategorizedTransactionListView.swift
//  ExpenseTracker
//
//  Created by yongseongkim on 2021/06/24.
//

import Combine
import SwiftUI

struct MonthlyCategorizedTransactionListView: View {
    @ObservedObject var model: ViewModel

    var body: some View {
        List {
            ForEach(model.transactionsByDate.keys.sorted(by: { $0 > $1})) { date in
                TransactionListItemDateView(date: date)
                    .frame(height: 50)
                    .listRowInsets(EdgeInsets())
                    .background(Color.systemWhite)

                if let transactions = model.transactionsByDate[date], !transactions.isEmpty {
                    ForEach(transactions) { transaction in
                        TransactionListItemView(transaction: transaction)
                            .listRowInsets(EdgeInsets())
                            .listRowSeparator(.hidden)
                            .background(Color.systemWhite)
                    }
                }
            }
        }
    }
}

extension MonthlyCategorizedTransactionListView {
    class ViewModel: ObservableObject {
        @Published var transactionsByDate: [Date: [Transaction]] = [:]

        let category: Category
        let transactionStorage: TransactionStorage
        var cancellables: [AnyCancellable] = []

        init(category: Category, transactionStorage: TransactionStorage) {
            self.category = category
            self.transactionStorage = transactionStorage
            self.transactionStorage.transactions
                .map { transactions in transactions.filter { Category.from(raw: $0.category) == category } }
                .sink { [weak self] transactions in
                    guard let self = self else { return }
                    self.transactionsByDate = transactions.arrangedByDate()
                }
                .store(in: &cancellables)
        }
    }
}

struct MonthlyCategorizedTransactionListView_Previews: PreviewProvider {
    static var previews: some View {
        MonthlyCategorizedTransactionListView(
            model: .init(category: .etc, transactionStorage: .shared)
        )
    }
}
