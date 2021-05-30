//
//  MonthSelectorView.swift
//  ExpenseTracker
//
//  Created by yongseongkim on 2021/05/27.
//

import SwiftUI

struct MonthSelectorView: View {
    @ObservedObject var model: ViewModel
    let listener: Listener

    var body: some View {
        List(model.months, id: \.self, selection: $model.selectedMonth) { month in
            Button(
                action: { listener.onSelected(month) },
                label: {
                    HStack(spacing: 10) {
                        Image(symbol: .checkmark)
                            .visibleOrGone(month == model.currentMonth)
                        Text(model.dateFormatter.string(from: month))
                    }
                }
            )
            .frame(height: 55)
        }
    }
}

extension MonthSelectorView {
    class ViewModel: ObservableObject {
        let months: [Date]
        let currentMonth: Date
        let dateFormatter = DateFormatter().apply { $0.dateFormat = "LLLL, yyyy" }

        @Published var selectedMonth: Date?

        init(from: Date, to: Date = Date(), current: Date) {
            var months: [Date] = []
            var index = Calendar.current.firstDateOfMonth(date: to)
            repeat {
                months.append(index)
                index = Calendar.current.date(byAdding: DateComponents(month: -1), to: index)
                    ?? Calendar.current.firstDateOfMonth(date: from)
            } while from < index
            self.months = months
            self.currentMonth = Calendar.current.firstDateOfMonth(date: current)
        }
    }

    struct Listener {
        let onSelected: (Date) -> Void
    }
}

//struct MonthSelectorView_Previews: PreviewProvider {
//    static var previews: some View {
//        MonthSelectorView()
//    }
//}
