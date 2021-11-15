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
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Text("월 선택하기")
                    .font(.system(size: 21, weight: .bold))
                Spacer()
                Button(
                    action: { listener.onCanceled() },
                    label: {
                        Image(symbol: .xmark)
                            .foregroundColor(.systemBlack)
                    }
                )
            }
            .frame(height: 70)
            .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
            Divider()
            ScrollViewReader { proxy in
                List(model.months, id: \.self, selection: $model.selectedMonth) { month in
                    Button(
                        action: { listener.onSelected(month) },
                        label: {
                            HStack(spacing: 10) {
                                Text(model.dateFormatter.string(from: month))
                                    .font(.system(size: 18))
                                Spacer()
                                Image(symbol: .checkmark)
                                    .visibleOrGone(month == model.currentMonth)
                            }
                            .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 30))
                        }
                    )
                    .frame(height: 60)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets())
                }
                .listStyle(PlainListStyle())
                .onAppear {
                    proxy.scrollTo(model.currentMonth, anchor: .center)
                }
            }
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
        let onCanceled: () -> Void
    }
}

struct MonthSelectorView_Previews: PreviewProvider {
    static var previews: some View {
        MonthSelectorView(
            model: .init(
                from: Calendar.current.date(byAdding: .day, value: -365, to: Date()) ?? Date(),
                current: Date()),
            listener: .init(
                onSelected: { _ in },
                onCanceled: { }
            )
        )
    }
}
